import 'package:flutter/material.dart';

class StateManagementDemo extends StatefulWidget {
  const StateManagementDemo({super.key});

  @override
  State<StateManagementDemo> createState() => _StateManagementDemoState();
}

class _StateManagementDemoState extends State<StateManagementDemo> {
  final colors = [
    Colors.blue,
    Colors.yellow,
    Colors.teal,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.red,
  ];
  // int colorIndex = 0;
  final colorIndexNotifier = ValueNotifier(0);

  // int number = 1;
  final numberNotifier = ValueNotifier<int>(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('State Management')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: colorIndexNotifier,
              builder: (context, colorIndex, child) {
                return Container(
                  color: colors[colorIndex],
                  width: 200,
                  height: 200,
                  child: Center(
                    child: ValueListenableBuilder(
                      valueListenable: numberNotifier,
                      builder: (context, value, child) {
                        return Text('$value', style: TextStyle(fontSize: 50));
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: changeColor, child: Text('Change color')),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: changeText, child: Text('Change text')),
          ],
        ),
      ),
    );
  }

  void changeColor() {
    colorIndexNotifier.value++;
    colorIndexNotifier.value = colorIndexNotifier.value % colors.length;
  }

  void changeText() {
    numberNotifier.value++;
  }
}