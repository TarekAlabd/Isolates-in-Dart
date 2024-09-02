import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Isolates Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = "Press the button to run a heavy task";
  bool isSolution = false;
  bool useIsolate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIF Freeze and Isolate Solution'),
        actions: [
          Switch(
            value: isSolution,
            onChanged: (value) {
              setState(() {
                isSolution = value;
                useIsolate = false;
              });
            },
            activeColor: Colors.green,
          ),
          Switch(
            value: useIsolate,
            onChanged: (value) {
              setState(() {
                useIsolate = value;
                isSolution = value;
              });
            },
            activeColor: Colors.blue,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(useIsolate
                ? 'Pure Isolate'
                : isSolution
                    ? 'Compute'
                    : 'Freeze'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/banana.gif'), // Display the GIF
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (useIsolate) {
                  _runAsynchronousTaskWithIsolate();
                } else if (isSolution) {
                  _runAsynchronousTaskWithCompute();
                } else {
                  _runSynchronousTask();
                  // _runAsynchronousTask();
                }
              },
              child: Text(useIsolate
                  ? 'Run Asynchronous Task (Pure Isolate)'
                  : isSolution
                      ? 'Run Asynchronous Task (Compute)'
                      : 'Run Synchronous Task (GIF freezes)'),
            ),
            const SizedBox(height: 20),
            Text(result),
          ],
        ),
      ),
    );
  }

  void _runSynchronousTask() {
    setState(() {
      result = "Running heavy task...";
    });

    // Synchronous heavy computation that freezes the UI
    int sum = _heavyComputation(4000000000);

    setState(() {
      result = "Task Completed. Sum: $sum";
    });
  }

  Future<void> _runAsynchronousTask() async {
    setState(() {
      result = "Running heavy task...";
    });

    // Synchronous heavy computation that freezes the UI
    int sum = _heavyComputation(4000000000);

    setState(() {
      result = "Task Completed. Sum: $sum";
    });
  }

  void _runAsynchronousTaskWithIsolate() async {
    setState(() {
      result = "Running heavy task in a pure isolate...";
    });

    // Create a ReceivePort to receive data from the isolate
    final receivePort = ReceivePort();

    // Spawn an isolate
    await Isolate.spawn(_heavyComputationInIsolate, receivePort.sendPort);

    // Send the count to the isolate and wait for the result
    final sendPort = await receivePort.first as SendPort;
    final response = ReceivePort();
    sendPort.send([2000000000, response.sendPort]);

    final sum = await response.first as int;

    setState(() {
      result = "Task Completed. Sum: $sum";
    });
  }

  // Static method for heavy computation, called within isolate
  static int _heavyComputation(int count) {
    int sum = 0;
    for (int i = 0; i < count; i++) {
      sum += i;
    }
    return sum;
  }

  // Top-level function for pure isolate
  static void _heavyComputationInIsolate(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (var message in port) {
      final int count = message[0];
      final SendPort replyTo = message[1];

      // Perform the heavy computation
      int sum = 0;
      for (int i = 0; i < count; i++) {
        sum += i;
      }

      // Send the result back to the main isolate
      replyTo.send(sum);
    }
  }

  void _runAsynchronousTaskWithCompute() async {
    setState(() {
      result = "Running heavy task in an isolate using compute...";
    });

    // Asynchronous heavy computation that keeps the UI responsive
    int sum = await compute(_heavyComputation, 2000000000);

    setState(() {
      result = "Task Completed. Sum: $sum";
    });
  }
}
