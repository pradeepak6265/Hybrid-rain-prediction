import json
from datetime import datetime


# ============================================================
# INDRA-SHAKTI - STAGE 2 LIVE ANOMALY ENGINE
# ============================================================
# Input  : ESP8266 + BME280
# Output : Anomaly detection + Root Cause + Rain Prediction
#
# Stage 1 intelligence:
# Historical Safdarjung AWS baseline
#
# Stage 2:
# Historical baseline + real-time sensor + temporal behaviour
# ============================================================


# ============================================================
# ACTUAL STAGE-1 BASELINE
# Safdarjung AWS historical dataset
# INI0000VIDD_v3_1_final.csv
# ============================================================

BASELINE = {

    "temperature": {
        "mean": 25.231246,
        "std": 8.405688
    },

    "humidity": {
        "mean": 61.042507,
        "std": 23.145882
    },

    "pressure": {
        "mean": 1007.638548,
        "std": 7.811067
    }
}


# ============================================================
# Utility Functions
# ============================================================

def clamp(value, low=0.0, high=100.0):
    return max(low, min(high, float(value)))


def safe_float(value):

    try:
        return float(value)

    except (TypeError, ValueError):
        return None


# ============================================================
# Physical Sensor Validation
# ============================================================

def physical_check(temp, pressure, humidity):

    invalid = []

    # Real-world physical limits for live sensor
    if humidity < 0 or humidity > 100:
        invalid.append(
            "Humidity outside physical range"
        )

    if temp < -80 or temp > 70:
        invalid.append(
            "Temperature outside physical range"
        )

    if pressure < 850 or pressure > 1100:
        invalid.append(
            "Pressure outside physical range"
        )

    if invalid:

        return {
            "score": 100.0,
            "valid": False,
            "reasons": invalid
        }

    return {
        "score": 0.0,
        "valid": True,
        "reasons": []
    }


# ============================================================
# Historical Deviation
# ============================================================

def historical_score(temp, pressure, humidity):

    scores = []

    values = [

        (
            temp,
            BASELINE["temperature"]
        ),

        (
            humidity,
            BASELINE["humidity"]
        ),

        (
            pressure,
            BASELINE["pressure"]
        )

    ]

    for value, baseline in values:

        mean = baseline["mean"]
        std = baseline["std"]

        if std <= 0:
            continue

        z = abs(value - mean) / std

        # Convert z-score to anomaly evidence
        if z >= 4:
            score = 100.0

        elif z >= 3:
            score = 80.0

        elif z >= 2:
            score = 55.0

        elif z >= 1:
            score = 25.0

        else:
            score = 0.0

        scores.append(score)

    if not scores:
        return 0.0

    return max(scores)


# ============================================================
# Temporal Change
# ============================================================

def temporal_score(current, previous):

    if previous is None:
        return 0.0

    temp_change = abs(
        current["temp"] -
        previous["temp"]
    )

    pressure_change = abs(
        current["pres"] -
        previous["pres"]
    )

    humidity_change = abs(
        current["hum"] -
        previous["hum"]
    )

    score = 0.0

    # Temperature
    if temp_change > 5:
        score += 35

    elif temp_change > 2:
        score += 15

    # Pressure
    if pressure_change > 8:
        score += 35

    elif pressure_change > 4:
        score += 15

    # Humidity
    if humidity_change > 25:
        score += 30

    elif humidity_change > 15:
        score += 15

    return clamp(score)


# ============================================================
# Coupled Weather Behaviour
# ============================================================

def weather_signal(current, previous):

    if previous is None:
        return 0.0

    humidity_rising = (
        current["hum"] -
        previous["hum"]
    ) >= 5

    pressure_falling = (
        previous["pres"] -
        current["pres"]
    ) >= 2

    temperature_falling = (
        previous["temp"] -
        current["temp"]
    ) >= 1

    signal = 0.0

    if humidity_rising:
        signal += 35

    if pressure_falling:
        signal += 35

    if temperature_falling:
        signal += 30

    return clamp(signal)


# ============================================================
# Rain Prediction
# ============================================================

def calculate_rain_score(
    temp,
    humidity,
    pressure,
    previous
):

    rain_score = 0.0

    # Current humidity
    if humidity >= 85:
        rain_score += 40

    elif humidity >= 75:
        rain_score += 30

    elif humidity >= 65:
        rain_score += 15

    # Temporal behaviour
    if previous is not None:

        humidity_change = (
            humidity -
            previous["hum"]
        )

        pressure_change = (
            previous["pres"] -
            pressure
        )

        temperature_change = (
            previous["temp"] -
            temp
        )

        # Rising humidity
        if humidity_change >= 10:
            rain_score += 25

        elif humidity_change >= 5:
            rain_score += 15

        # Falling pressure
        if pressure_change >= 5:
            rain_score += 25

        elif pressure_change >= 2:
            rain_score += 15

        # Falling temperature
        if temperature_change >= 2:
            rain_score += 15

        elif temperature_change >= 1:
            rain_score += 10

    return clamp(rain_score)


# ============================================================
# Main Analysis
# ============================================================

_previous = None


def analyze(sensor_data):

    global _previous

    # --------------------------------------------------------
    # Validate input
    # --------------------------------------------------------

    if not isinstance(sensor_data, dict):

        return {
            "status": "ERROR",
            "message": "Invalid sensor data"
        }

    temp = safe_float(
        sensor_data.get("temp")
    )

    humidity = safe_float(
        sensor_data.get("hum")
    )

    pressure = safe_float(
        sensor_data.get("pres")
    )

    if (
        temp is None
        or humidity is None
        or pressure is None
    ):

        return {
            "status": "ERROR",
            "message":
                "Invalid sensor data. "
                "Required: temp, hum, pres"
        }

    # --------------------------------------------------------
    # Current reading
    # --------------------------------------------------------

    current = {

        "temp": temp,

        "hum": humidity,

        "pres": pressure

    }

    # --------------------------------------------------------
    # Physical validation
    # --------------------------------------------------------

    physical_result = physical_check(
        temp,
        pressure,
        humidity
    )

    physical = physical_result["score"]

    valid = physical_result["valid"]

    physical_reasons = (
        physical_result["reasons"]
    )

    # --------------------------------------------------------
    # Historical intelligence
    # --------------------------------------------------------

    hist = historical_score(
        temp,
        pressure,
        humidity
    )

    # --------------------------------------------------------
    # Temporal intelligence
    # --------------------------------------------------------

    temporal = temporal_score(
        current,
        _previous
    )

    # --------------------------------------------------------
    # Weather behaviour
    # --------------------------------------------------------

    weather = weather_signal(
        current,
        _previous
    )

    # --------------------------------------------------------
    # Combined anomaly score
    #
    # Physical      = 40%
    # Temporal      = 30%
    # Historical    = 30%
    # --------------------------------------------------------

    anomaly_score = (

        physical * 0.40

        + temporal * 0.30

        + hist * 0.30

    )

    anomaly_score = clamp(
        anomaly_score
    )

    # --------------------------------------------------------
    # Decision Engine
    # --------------------------------------------------------

    if not valid:

        decision = "SENSOR_FAULT"

        root_cause = (
            "Possible Sensor Fault"
        )

        confidence = 95.0

    elif (
        anomaly_score >= 50
        and weather < 60
    ):

        decision = "ANOMALY"

        root_cause = (
            "Possible Sensor/Local Data Anomaly"
        )

        confidence = clamp(
            anomaly_score + 20
        )

    elif (
        weather >= 60
        and anomaly_score >= 20
    ):

        decision = "GENUINE_WEATHER"

        root_cause = (
            "Likely Genuine Weather Event"
        )

        confidence = clamp(
            weather
        )

    elif anomaly_score >= 30:

        decision = "REVIEW"

        root_cause = (
            "Historical/Temporal Deviation"
        )

        confidence = clamp(
            anomaly_score
        )

    else:

        decision = "NORMAL"

        root_cause = (
            "No Significant Anomaly"
        )

        confidence = clamp(
            100 - anomaly_score
        )

    # --------------------------------------------------------
    # Rain prediction
    # --------------------------------------------------------

    rain_score = calculate_rain_score(
        temp,
        humidity,
        pressure,
        _previous
    )

    if rain_score >= 70:

        rain_prediction = (
            "HIGH CHANCE OF RAIN"
        )

    elif rain_score >= 40:

        rain_prediction = (
            "MODERATE CHANCE OF RAIN"
        )

    else:

        rain_prediction = (
            "LOW CHANCE OF RAIN"
        )

    # --------------------------------------------------------
    # Final result
    # --------------------------------------------------------

    result = {

        "status": "OK",

        "timestamp":
            datetime.now().isoformat(),

        "sensor": {

            "temperature":
                round(temp, 2),

            "humidity":
                round(humidity, 2),

            "pressure":
                round(pressure, 2)

        },

        "stage2": {

            "historical_score":
                round(hist, 2),

            "temporal_score":
                round(temporal, 2),

            "physical_score":
                round(physical, 2),

            "weather_evidence":
                round(weather, 2),

            "anomaly_score":
                round(anomaly_score, 2),

            "confidence":
                round(confidence, 2),

            "decision":
                decision,

            "root_cause":
                root_cause,

            "rain_score":
                round(rain_score, 2),

            "rain_prediction":
                rain_prediction

        },

        "physical_check": {

            "valid":
                valid,

            "reasons":
                physical_reasons

        }

    }

    # --------------------------------------------------------
    # Save current reading for next temporal comparison
    # --------------------------------------------------------

    _previous = current

    return result


# ============================================================
# Standalone Test
# ============================================================

if __name__ == "__main__":

    print("=" * 65)

    print(
        "INDRA-SHAKTI STAGE 2 "
        "LIVE ANOMALY ENGINE"
    )

    print("=" * 65)

    # First reading
    test_1 = {

        "temp": 29.88,

        "hum": 80.14,

        "pres": 964.58

    }

    print("\nTEST 1:")

    print(
        json.dumps(
            analyze(test_1),
            indent=2
        )
    )

    # Second reading
    test_2 = {

        "temp": 28.20,

        "hum": 88.50,

        "pres": 958.20

    }

    print("\nTEST 2:")

    print(
        json.dumps(
            analyze(test_2),
            indent=2
        )
    )
