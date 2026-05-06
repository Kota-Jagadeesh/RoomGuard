import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late MqttServerClient client;

  Future<void> connect() async {
    client = MqttServerClient('broker.hivemq.com', 'flutter_client');

    client.port = 1883;

    client.keepAlivePeriod = 20;

    try {
      await client.connect();

      print("MQTT Connected");
    } catch (e) {
      print("MQTT Connection Failed");

      print(e);
    }
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();

    builder.addString(message);

    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }
}
