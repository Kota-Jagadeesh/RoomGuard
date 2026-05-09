import 'dart:convert'; // required for parsing json packet
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;

  Function(String topic, Map<String, dynamic> data)? onStatusReceived;
  Function(String message)? onAlertReceived;

  Future<void> connect() async {
    client = MqttServerClient(
      'broker.hivemq.com',
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
    );

    client.port = 1883;
    client.keepAlivePeriod = 20;
    client.logging(on: false); //debugging purpose

    client.onConnected = () {
      print("Status: MQTT Connected Successfully");
    };

    client.onDisconnected = () {
      print("Status: MQTT Disconnected");
    };

    try {
      await client.connect();

      client.subscribe("smartroom/status", MqttQos.atMostOnce);
      client.subscribe("smartroom/alert", MqttQos.atMostOnce);

      client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        final topic = c[0].topic;

        print("Topic: $topic | Payload: $payload");

        if (topic == "smartroom/status") {
          try {
            // Decode the JSON string into a Dart Map
            Map<String, dynamic> data = jsonDecode(payload);
            if (onStatusReceived != null) {
              onStatusReceived!(topic, data);
            }
          } catch (e) {
            print("Error parsing JSON: $e");
          }
        } else if (topic == "smartroom/alert") {
          if (onAlertReceived != null) {
            onAlertReceived!(payload);
          }
        }
      });
    } catch (e) {
      print("MQTT Connection Error: $e");
      client.disconnect();
    }
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }
}
