import 'package:flutter/material.dart';
import 'mqtt_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Smart Room',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),

      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MQTTService mqttService = MQTTService();

  @override
  void initState() {
    super.initState();

    connectMQTT();
  }

  Future<void> connectMQTT() async {
    await mqttService.connect();
  }

  void openDoor() {
    mqttService.publishMessage("smartroom/cmd/door", "open");
  }

  void closeDoor() {
    mqttService.publishMessage("smartroom/cmd/door", "close");
  }

  void loadsOn() {
    mqttService.publishMessage("smartroom/cmd/loads", "on");
  }

  void loadsOff() {
    mqttService.publishMessage("smartroom/cmd/loads", "off");
  }

  void lockRoom() {
    mqttService.publishMessage("smartroom/cmd/mode", "locked");
  }

  void unlockRoom() {
    mqttService.publishMessage("smartroom/cmd/mode", "unlocked");
  }

  void panicMode() {
    mqttService.publishMessage("smartroom/cmd/panic", "1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Room Control")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            ElevatedButton(onPressed: openDoor, child: const Text("OPEN DOOR")),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: closeDoor,
              child: const Text("CLOSE DOOR"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: loadsOn, child: const Text("LOADS ON")),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: loadsOff, child: const Text("LOADS OFF")),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: lockRoom, child: const Text("LOCK ROOM")),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: unlockRoom,
              child: const Text("UNLOCK ROOM"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(onPressed: panicMode, child: const Text("PANIC")),
          ],
        ),
      ),
    );
  }
}
