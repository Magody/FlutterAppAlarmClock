import 'dart:ui'; // PluginUtilities

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // MethodChannel

const MethodChannel channel = MethodChannel("com.example.app_alarm_clock/test");

/*
static void callbackDispatcherInit() {
   WidgetsFlutterBinding.ensureInitialized();
   debugPrint("Initialization!");
 }
 
 Future<void> initialize(final Function callbackDispatcher) async {
   final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
   await channel.invokeMethod('initialize', callback!.toRawHandle());
 }
 // await initialize(callbackDispatcherInit);
*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  //channel name, used in android code to invoke method

  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await channel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _showToast() async {
    await channel.invokeMethod('showToast', {
      'message':
          'This is a Toast from From Flutter to Android Native Code Yes, It is working'
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Battery Level'),
            Text(_batteryLevel),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Get Battery Level'),
            ),
            const Text("Show Toast"),
            ElevatedButton(
              onPressed: _showToast,
              child: const Text("Show Toast"),
            ),
          ],
        ),
      ),
    );
  }
}
