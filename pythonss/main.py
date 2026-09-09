import os
import sys
import paho.mqtt.client as mqtt
import requests
import json
import time
import threading
from flask import Flask, jsonify, request


# ============================================================
# INDRA-SHAKTI / RAIN PREDICTION BACKEND
# ============================================================

# ------------------------------------------------------------
# Live anomaly engine path
# Works locally and on Render.
# ------------------------------------------------------------
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(
    os.path.join(CURRENT_DIR, "..", "..", "..")
)
LIVE_ENGINE_DIR = os.path.join(PROJECT_ROOT, "src", "live")

if os.path.isdir(LIVE_ENGINE_DIR):
    sys.path.insert(0, LIVE_ENGINE_DIR)

try:
    from live_anomaly_engine import analyze
    LIVE_ENGINE_AVAILABLE = True
except Exception as e:
    print("Live anomaly engine unavailable:", e)
    LIVE_ENGINE_AVAILABLE = False


# ============================================================
# Environment Variables
# ============================================================

OPENWEATHERMAP_API_KEY = os.getenv("OPENWEATHERMAP_API_KEY")
GOOGLE_SHEETS_WEB_APP_URL = os.getenv("GOOGLE_SHEETS_WEB_APP_URL")

CITY = os.getenv("CITY", "Jabalpur")

MQTT_BROKER_HOST = os.getenv(
    "MQTT_BROKER_HOST",
    "broker.hivemq.com"
)

MQTT_BROKER_PORT = int(
    os.getenv("MQTT_BROKER_PORT", 1883)
)

# Existing working topic — DO NOT CHANGE
MQTT_TOPIC = os.getenv(
    "MQTT_TOPIC",
    "esp32/sensor"
)


# ============================================================
# Global Variables
# ============================================================

latest_sensor_data = None
api_data = None

latest_anomaly_result = None


# ============================================================
# SENSOR VALIDATION
# ============================================================

def validate_sensor_data(data):

    if not isinstance(data, dict):
        return False

    required = ["temp", "hum", "pres"]

    for key in required:

        if key not in data:
            return False

        try:
            float(data[key])
        except (TypeError, ValueError):
            return False

    return True


# ============================================================
# MQTT CALLBACKS
# ============================================================

def on_connect(client, userdata, flags, rc):

    print(
        f"Connected to MQTT Broker with result code: {rc}"
    )

    client.subscribe(MQTT_TOPIC)

    print(
        f"Subscribed to MQTT topic: {MQTT_TOPIC}"
    )


def on_message(client, userdata, msg):

    global latest_sensor_data
    global latest_anomaly_result

    payload = msg.payload.decode(errors="ignore")

    print(
        f"MQTT message received: {payload}"
    )

    try:

        data = json.loads(payload)

        # ----------------------------------------------------
        # Ignore unrelated/random payloads.
        # Our ESP8266 payload MUST contain:
        # temp, hum, pres
        # ----------------------------------------------------

        if not validate_sensor_data(data):

            print(
                "Ignoring MQTT message: "
                "invalid sensor payload."
            )

            return

        latest_sensor_data = {
            "temp": float(data["temp"]),
            "hum": float(data["hum"]),
            "pres": float(data["pres"])
        }

        print(
            "Valid ESP8266 sensor data:",
            latest_sensor_data
        )

        # ----------------------------------------------------
        # Stage 2 live anomaly detection
        # ----------------------------------------------------

        if LIVE_ENGINE_AVAILABLE:

            try:

                latest_anomaly_result = analyze(
                    latest_sensor_data
                )

                print(
                    "Stage 2 anomaly result:",
                    latest_anomaly_result
                )

            except Exception as e:

                print(
                    "Live anomaly analysis error:",
                    e
                )

        else:

            print(
                "Live anomaly engine is not available."
            )

    except json.JSONDecodeError:

        print(
            "Ignoring MQTT message: invalid JSON."
        )


# ============================================================
# WEATHER API
# ============================================================

def get_weather_data(api_key, city):

    global api_data

    if not api_key:

        print(
            "OPENWEATHERMAP_API_KEY is not configured."
        )

        return None

    base_url = (
        "https://api.openweathermap.org/data/2.5/weather"
    )

    params = {
        "q": city,
        "appid": api_key,
        "units": "metric"
    }

    try:

        response = requests.get(
            base_url,
            params=params,
            timeout=15
        )

        response.raise_for_status()

        print(
            "Successfully fetched API data."
        )

        api_data = response.json()

        return api_data

    except requests.exceptions.RequestException as e:

        print(
            f"Error fetching weather data: {e}"
        )

        return None


# ============================================================
# GOOGLE SHEETS
# ============================================================

def send_data_to_google_sheets(
    sensor_data,
    api_data
):

    if sensor_data is None or api_data is None:

        print(
            "Data incomplete, skipping Google Sheets."
        )

        return

    if not GOOGLE_SHEETS_WEB_APP_URL:

        print(
            "GOOGLE_SHEETS_WEB_APP_URL is not configured."
        )

        return

    payload = {

        "sensor_data": {

            "temp": sensor_data.get("temp", 0),
            "hum": sensor_data.get("hum", 0),
            "pres": sensor_data.get("pres", 0)

        },

        "api_data": {

            "temp": api_data["main"].get(
                "temp",
                0
            ),

            "hum": api_data["main"].get(
                "humidity",
                0
            ),

            "pres": api_data["main"].get(
                "pressure",
                0
            ),

            "weather": api_data["weather"][0].get(
                "main",
                "N/A"
            )

        }

    }

    try:

        print(
            "Attempting to send data to Google Sheets..."
        )

        response = requests.post(
            GOOGLE_SHEETS_WEB_APP_URL,
            json=payload,
            timeout=10
        )

        response.raise_for_status()

        print(
            "Data sent successfully to Google Sheets."
        )

        print(
            "Status Code:",
            response.status_code
        )

        print(
            "Response:",
            response.text
        )

    except requests.exceptions.RequestException as e:

        print(
            f"Error sending data to Google Sheets: {e}"
        )


# ============================================================
# BACKGROUND TASK
# ============================================================

def background_task():

    global latest_sensor_data
    global api_data

    client = mqtt.Client(
        client_id="PythonLogger"
    )

    client.on_connect = on_connect
    client.on_message = on_message

    print(
        "Connecting to MQTT Broker..."
    )

    client.connect(
        MQTT_BROKER_HOST,
        MQTT_BROKER_PORT,
        60
    )

    client.loop_start()

    try:

        while True:

            print("-" * 50)

            print(
                "New cycle started."
            )

            # ------------------------------------------------
            # Fetch weather API
            # ------------------------------------------------

            api_data = get_weather_data(
                OPENWEATHERMAP_API_KEY,
                CITY
            )

            # ------------------------------------------------
            # Wait for valid ESP8266 data
            # ------------------------------------------------

            start_time = time.time()

            while (
                latest_sensor_data is None
                and
                (time.time() - start_time) < 60
            ):

                print(
                    "Waiting for valid ESP8266 MQTT data..."
                )

                time.sleep(5)

            # ------------------------------------------------
            # Send valid sensor + API data
            # ------------------------------------------------

            if latest_sensor_data and api_data:

                send_data_to_google_sheets(
                    latest_sensor_data,
                    api_data
                )

                latest_sensor_data = None

            else:

                print(
                    "Skipping Google Sheets update."
                )

            time.sleep(40)

    except Exception as e:

        print(
            "Error in background task:",
            e
        )

    finally:

        client.loop_stop()
        client.disconnect()


# ============================================================
# FLASK WEB SERVICE
# ============================================================

app = Flask(__name__)


@app.route("/", methods=["GET"])
def home():

    return (
        "Indra-Shakti Rain Prediction "
        "Web Service is running!"
    )


# ------------------------------------------------------------
# Existing endpoint
# ------------------------------------------------------------

@app.route("/run", methods=["GET"])
def run_once():

    threading.Thread(
        target=background_task,
        daemon=True
    ).start()

    return jsonify({
        "status": "Background task started"
    })


# ------------------------------------------------------------
# NEW: LIVE ANOMALY ENDPOINT
# ------------------------------------------------------------

@app.route(
    "/live-anomaly",
    methods=["POST"]
)
def live_anomaly():

    global latest_anomaly_result

    if not LIVE_ENGINE_AVAILABLE:

        return jsonify({

            "status": "error",

            "message":
                "Live anomaly engine unavailable."

        }), 503

    try:

        sensor_data = request.get_json(
            silent=True
        )

        if not validate_sensor_data(
            sensor_data
        ):

            return jsonify({

                "status": "error",

                "message":
                    "Invalid sensor data. "
                    "Required: temp, hum, pres."

            }), 400

        sensor_data = {

            "temp":
                float(sensor_data["temp"]),

            "hum":
                float(sensor_data["hum"]),

            "pres":
                float(sensor_data["pres"])

        }

        result = analyze(
            sensor_data
        )

        latest_anomaly_result = result

        return jsonify(result)

    except Exception as e:

        return jsonify({

            "status": "error",

            "message": str(e)

        }), 500


# ------------------------------------------------------------
# NEW: GET LATEST LIVE RESULT
# ------------------------------------------------------------

@app.route(
    "/live-anomaly",
    methods=["GET"]
)
def get_live_anomaly():

    if latest_anomaly_result is None:

        return jsonify({

            "status": "waiting",

            "message":
                "No live ESP8266 anomaly result yet."

        })

    return jsonify(
        latest_anomaly_result
    )


# ------------------------------------------------------------
# NEW: SYSTEM STATUS
# ------------------------------------------------------------

@app.route(
    "/status",
    methods=["GET"]
)
def status():

    return jsonify({

        "service":
            "Indra-Shakti",

        "live_anomaly_engine":
            LIVE_ENGINE_AVAILABLE,

        "mqtt_broker":
            MQTT_BROKER_HOST,

        "mqtt_topic":
            MQTT_TOPIC,

        "sensor_connected":
            latest_sensor_data is not None,

        "anomaly_result_available":
            latest_anomaly_result is not None

    })


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    threading.Thread(
        target=background_task,
        daemon=True
    ).start()

    port = int(
        os.getenv("PORT", 5000)
    )

    app.run(
        host="0.0.0.0",
        port=port
    )
