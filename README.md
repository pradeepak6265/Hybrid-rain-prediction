#  Hybrid Rain Prediction System

A **Hybrid Rain Prediction System** that combines **real-time environmental sensor data** with **weather API data** to predict rainfall conditions and provide localized weather insights.

The system uses an **ESP32/ESP8266 with a BME280 sensor** to collect local atmospheric data such as temperature, humidity, and pressure. This data is combined with external weather information to improve rainfall prediction for a specific location.

##  Key Features

*  Real-time temperature monitoring
*  Humidity monitoring
*  Atmospheric pressure monitoring
*  Weather data from OpenWeather API
*  Hybrid rainfall prediction using local + cloud data
*  IoT-based sensor data transmission
*  Flutter-based mobile application
*  Cloud/backend integration
*  Historical weather data storage
*  Real-time sensor data updates
*  Rain prediction for upcoming days

##  System Architecture

```text
        BME280 Sensor
             │
             ▼
      ESP32 / ESP8266
             │
             │ Sensor Data
             ▼
        MQTT Broker
             │
             ▼
       Backend Server
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
Local Sensor     Weather API
   Data          (OpenWeather)
      │             │
      └──────┬──────┘
             ▼
     Hybrid Prediction
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
 Mobile App      Database
```

##  Prediction Approach

The system combines two sources of information:

### 1. Local Sensor Data

The BME280 sensor provides:

* Temperature
* Relative Humidity
* Atmospheric Pressure

### 2. External Weather Data

Weather information is retrieved through the **OpenWeather API**, providing additional atmospheric and forecast information.

### 3. Hybrid Analysis

The local sensor measurements and external weather data are processed together to generate a localized rainfall prediction.

```text
Local Sensor Data
        +
Weather API Data
        ↓
Data Processing
        ↓
Hybrid Prediction
        ↓
Rainfall Probability / Prediction
```

##  Technology Stack

### Hardware

* ESP32 / ESP8266
* BME280
* Optional rain/soil sensors

### Software

* Python
* Flask
* Flutter
* C++ / Arduino
* MQTT
* MySQL / Google Sheets

### APIs & Services

* OpenWeather API
* MQTT Broker
* Cloud Backend

##  Mobile Application

The Flutter application provides a user interface for:

* Viewing live sensor readings
* Checking weather information
* Viewing rainfall predictions
* Accessing historical weather data
* Monitoring environmental conditions

##  Data Flow

```text
BME280
  ↓
ESP32 / ESP8266
  ↓
MQTT
  ↓
Backend
  ↓
Data Processing
  ↓
Hybrid Prediction
  ↓
Flutter Application
```

##  Objective

The primary objective of this project is to explore whether combining **localized IoT sensor measurements** with **cloud-based weather information** can provide more useful rainfall predictions than relying on a single data source.

##  Future Improvements

* Machine-learning-based rainfall prediction
* Automatic model retraining using historical data
* Support for multiple IoT weather stations
* Advanced anomaly detection
* Geographic/weather-station-based prediction
* Improved prediction accuracy using historical datasets
* Landslide and extreme-weather monitoring
* Deployment of a scalable cloud architecture

##  Project Status

🚧 **Under Development**

This project is being developed as an IoT + software + AI/ML project for real-world weather monitoring and rainfall prediction.

## 👨‍💻 Author

**Pradeep Kumar Patel**

---

⭐ If you find this project interesting, consider giving it a star.
