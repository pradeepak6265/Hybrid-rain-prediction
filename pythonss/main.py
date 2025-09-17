import os
import paho.mqtt.client as mqtt
import requests
import json
import time
import threading
from flask import Flask, jsonify

# =========================
# Environment Variables
# =========================
OPENWEATHERMAP_API_KEY = os.getenv("OPENWEATHERMAP_API_KEY")
GOOGLE_SHEETS_WEB_APP_URL = os.getenv("GOOGLE_SHEETS_WEB_APP_URL")
CITY = os.getenv("CITY", "Jabalpur")  # default Jabalpur if not set

MQTT_BROKER_HOST = os.getenv("MQTT_BROKER_HOST", "broker.hivemq.com")
MQTT_BROKER_PORT = int(os.getenv("MQTT_BROKER_PORT", 1883))
MQTT_TOPIC = os.getenv("MQTT_TOPIC", "esp32/sensor")

# =========================
# Global Variables
# =========================
latest_sensor_data = None
api_data = None

# =========================
# MQTT Callbacks
# =========================
def on_connect(client, userdata, flags, rc):
    print(f"Connected to MQTT Broker with result code: {rc}")
    client.subscribe(MQTT_TOPIC)

def on_message(client, userdata, msg):
    global latest_sensor_data
    payload = msg.payload.decode()
    try:
        latest_sensor_data = json.loads(payload)
        print(f"Received and stored MQTT message: {latest_sensor_data}")
    except json.JSONDecodeError:
        print("Error decoding JSON from MQTT message.")

# =========================
# Weather API
# =========================
def get_weather_data(api_key, city):
    global api_data
    base_url = "https://api.openweathermap.org/data/2.5/weather"
    params = {"q": city, "appid": api_key, "units": "metric"}
    try:
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        print("Successfully fetched API data.")
        api_data = response.json()
        return api_data
    except requests.exceptions.RequestException as e:
        print(f"Error fetching weather data: {e}")
        return None

# =========================
# Send data to Google Sheets
# =========================
def send_data_to_google_sheets(sensor_data, api_data):
    if sensor_data is None or api_data is None:
        print("Data is incomplete, skipping send to Google Sheets.")
        return

    payload = {
        "sensor_data": {
            "temp": sensor_data.get("temp", 0),
            "hum": sensor_data.get("hum", 0),
            "pres": sensor_data.get("pres", 0),
        },
        "api_data": {
            "temp": api_data["main"].get("temp", 0),
            "hum": api_data["main"].get("humidity", 0),
            "pres": api_data["main"].get("pressure", 0),
            "weather": api_data["weather"][0].get("main", "N/A"),
        }
    }
    
    try:
        print("Attempting to send data to Google Sheets...")
        response = requests.post(GOOGLE_SHEETS_WEB_APP_URL, json=payload, timeout=10)
        response.raise_for_status()
        print(f"Data sent successfully to Google Sheets. Status Code: {response.status_code}")
        print(f"Response from Google Apps Script: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"Error sending data to Google Sheets: {e}")
        if 'response' in locals() and response:
            print(f"Response Content: {response.text}")

# =========================
# Background Task
# =========================
def background_task():
    global latest_sensor_data, api_data
    client = mqtt.Client(client_id="PythonLogger")
    client.on_connect = on_connect
    client.on_message = on_message
    
    print("Connecting to MQTT Broker...")
    client.connect(MQTT_BROKER_HOST, MQTT_BROKER_PORT, 60)
    client.loop_start()

    try:
        while True:
            print("-" * 20)
            print("New cycle started. Waiting for data...")
            
            api_data = get_weather_data(OPENWEATHERMAP_API_KEY, CITY)
            
            start_time = time.time()
            while latest_sensor_data is None and (time.time() - start_time) < 60:
                print("Waiting for MQTT message...")
                time.sleep(5)
            
            if latest_sensor_data and api_data:
                send_data_to_google_sheets(latest_sensor_data, api_data)
                latest_sensor_data = None
            else:
                print("Skipping send, one or both data sources are not available.")
            
            time.sleep(60)
    except Exception as e:
        print("Error in background task:", e)
    finally:
        client.loop_stop()
        client.disconnect()

# =========================
# Flask Web Service
# =========================
app = Flask(__name__)

@app.route('/')
def home():
    return "Rain Prediction Web Service is running!"

@app.route('/run', methods=['GET'])
def run_once():
    threading.Thread(target=background_task, daemon=True).start()
    return {"status": "Background task started"}

# =========================
# Main Execution
# =========================
if __name__ == "__main__":
    threading.Thread(target=background_task, daemon=True).start()
    app.run(host="0.0.0.0", port=5000)
