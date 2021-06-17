import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "./providers/BLEValuesProvider.dart";
import "./screens/ble_screen.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CWD BLE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: BLEValue(),
          ),
        ],
        child: BLEScreen(),
      ),
    );
  }
}
