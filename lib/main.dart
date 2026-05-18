import 'package:flutter/material.dart';
import 'mqtt_service.dart';

void main() => runApp(
  const MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MQTTService mqttService = MQTTService();

  // room statet Variables
  String gasStr = "0",
      motionStr = "clear",
      doorStr = "closed",
      modeStr = "unlocked",
      loadStr = "off";

  @override
  void initState() {
    super.initState();
    setupMQTT();
  }

  void setupMQTT() async {
    await mqttService.connect();

    // listener for thr real tiem status updates (json packet)
    mqttService.onStatusReceived = (topic, data) {
      if (mounted) {
        setState(() {
          gasStr = data['gas'].toString();
          motionStr = data['motion'];
          doorStr = data['door'];
          modeStr = data['mode'];
          loadStr = data['loads'];
        });
      }
    };

    // Listener for critical alerts (Intruders or Gas leaks)
    mqttService.onAlertReceived = (message) {
      if (mounted) {
        if (message.contains("INTRUDER") || message.contains("GAS")) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              // here the page of te stuff int hus is also called as the main thing in theplace
              content: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              margin: const EdgeInsets.all(10),
            ),
          );
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Smart Room Center"),
        // even here the samee thing in the place of the app bar is the same thign
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _infoCard(
                    "Gas Level",
                    gasStr,
                    Icons.gas_meter,
                    int.parse(gasStr) > 3000 ? Colors.red : Colors.green,
                  ),
                  _infoCard(
                    "Motion",
                    motionStr,
                    Icons.sensors,
                    motionStr == "detected" ? Colors.orange : Colors.blue,
                  ),
                  _infoCard(
                    "Door",
                    doorStr,
                    Icons.door_back_door,
                    Colors.purple,
                  ),
                  _infoCard(
                    "Security",
                    modeStr,
                    Icons.shield,
                    modeStr == "locked" ? Colors.red : Colors.green,
                  ),
                ],
              ),
            ),
            // panel
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 8.0,
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => mqttService.publishMessage(
                        "smartroom/cmd/door",
                        "open",
                      ),
                      icon: const Icon(Icons.lock_open),
                      label: const Text("Open"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => mqttService.publishMessage(
                        "smartroom/cmd/door",
                        "close",
                      ),
                      icon: const Icon(Icons.lock),
                      label: const Text("Close"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => mqttService.publishMessage(
                        "smartroom/cmd/mode",
                        "locked",
                      ),
                      icon: const Icon(Icons.security),
                      label: const Text("Lock Room"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => mqttService.publishMessage(
                        "smartroom/cmd/panic",
                        "1",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.warning),
                      label: const Text(
                        "PANIC",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            value.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
