// rename as main.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  // AudioPlayer.logEnabled = true;
  runApp(const MyApp());
}

Future<void> playSong(String path) async {
  final player = AudioCache(prefix: 'assets/');
  final url = await player.load(path);

  AudioPlayer audioPlayer = AudioPlayer();

  int result = await audioPlayer.play(url.path, isLocal: true);
  debugPrint("Result: $result");
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("TASK EXECUTION: $task");
    switch (task) {
      case simpleTaskKey:
        debugPrint(
            "simpleTaskKey $simpleTaskKey was executed. inputData = $inputData");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        debugPrint("Bool from prefs: ${prefs.getBool("test")}");
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          debugPrint(
              'rescheduledTaskKey has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          debugPrint('rescheduledTaskKey reschedule task');
          return false;
        }
      case failedTaskKey:
        debugPrint('failedTaskKey failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        debugPrint("simpleDelayedTask $simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        debugPrint("simplePeriodicTask $simplePeriodicTask was executed");
        playSong("sfx_alarm_loop6.wav").then((value) => null);
        break;
      case simplePeriodic1HourTask:
        debugPrint(
            "simplePeriodic1HourTask $simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        debugPrint("The iOS background fetch was triggered");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        debugPrint(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Play song",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  child: const Text("Play Test"),
                  onPressed: () {
                    playSong("sfx_alarm_loop6.wav").then((value) => null);
                  },
                ),
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  child: const Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  },
                ),
                const SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: const Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleTaskKey,
                      simpleTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Register rescheduled Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      rescheduledTaskKey,
                      rescheduledTaskKey,
                      inputData: <String, dynamic>{
                        'key': Random().nextInt(64000),
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Register failed Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      failedTaskKey,
                      failedTaskKey,
                    );
                  },
                ),
                //This task runs once
                //This wait at least 10 seconds before running
                ElevatedButton(
                    child: const Text("Register Delayed OneOff Task"),
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        simpleDelayedTask,
                        simpleDelayedTask,
                        initialDelay: const Duration(seconds: 10),
                      );
                    }),
                const SizedBox(height: 8),
                //This task runs periodically
                //It will wait at least 10 seconds before its first launch
                //Since we have not provided a frequency it will be the default 15 minutes
                ElevatedButton(
                    onPressed: Platform.isAndroid
                        ? () {
                            debugPrint("Registered 15min");
                            Workmanager().registerPeriodicTask(
                              simplePeriodicTask,
                              simplePeriodicTask,
                              initialDelay: const Duration(seconds: 10),
                            );
                          }
                        : null,
                    child: const Text("Register Periodic Task (Android)")),
                //This task runs periodically
                //It will run about every hour
                ElevatedButton(
                    onPressed: Platform.isAndroid
                        ? () {
                            Workmanager().registerPeriodicTask(
                              simplePeriodicTask,
                              simplePeriodic1HourTask,
                              frequency: const Duration(hours: 1),
                            );
                          }
                        : null,
                    child:
                        const Text("Register 1 hour Periodic Task (Android)")),
                const SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  child: const Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    debugPrint('Cancel all tasks completed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
