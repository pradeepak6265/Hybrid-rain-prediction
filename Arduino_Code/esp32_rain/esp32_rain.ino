#include <WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_BME280.h>
#include <Adafruit_Sensor.h>

// 🔹 WiFi credentials
const char* ssid = "realmenarzo30A";
const char* password = "00000000";

// 🔹 MQTT broker details
const char* mqtt_server = "broker.hivemq.com";
const int mqtt_port = 1883;
const char* mqtt_topic = "esp32/sensor";

// 🔹 Objects
WiFiClient espClient;
PubSubClient client(espClient);
Adafruit_BME280 bme;

unsigned long lastMsg = 0;

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("✅ WiFi connected");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void reconnect() {
  while (!client.connected()) {
    Serial.print("⚡ Attempting MQTT connection...");
    String clientId = "ESP32Client-";
    clientId += String(random(0xffff), HEX);

    if (client.connect(clientId.c_str())) {
      Serial.println("✅ connected");
    } else {
      Serial.print("❌ failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  // WiFi connect
  setup_wifi();

  // MQTT setup
  client.setServer(mqtt_server, mqtt_port);

  // BME280 setup
  if (!bme.begin(0x76)) {   // I2C address (0x76 or 0x77)
    Serial.println("❌ Could not find a valid BME280 sensor, check wiring!");
    while (1);
  }
}

void loop() {
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  unsigned long now = millis();
  if (now - lastMsg > 5000) {  // हर 5 sec में data भेजना
    lastMsg = now;

    float temperature = bme.readTemperature();
    float humidity = bme.readHumidity();
    float pressure = bme.readPressure() / 100.0F;

    // JSON data बनाना
    String payload = "{";
    payload += "\"temp\":"; payload += String(temperature, 2); payload += ",";
    payload += "\"hum\":"; payload += String(humidity, 2); payload += ",";
    payload += "\"pres\":"; payload += String(pressure, 2);
    payload += "}";

    Serial.print("📤 Publishing: ");
    Serial.println(payload);

    // MQTT publish
    client.publish(mqtt_topic, payload.c_str());
  }
}
