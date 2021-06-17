import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart'
    show Guid, BluetoothService, BluetoothCharacteristic;

import 'package:cbor/cbor.dart';

class BLEValue extends ChangeNotifier {
  ///
  ///
  bool isBlueToothConnected = false;
  List<BluetoothService> _connectedDeviceServices;

  ///
  ///
  Map<Guid, List<int>> _bleValues = {};

  // List<Function> _bleReadAndNotifyCall = [];
  // List<Function> _bleReadCalls = [];
  // List<Function> _bleNotifyCalls = [];

  void setValueForUUID({Guid uuid, List<int> value}) {
    if (isBlueToothConnected) {
      _bleValues[uuid] = value;
      // if (value.length != 0) {
      //   if (!_shown) {
      //     cborValueFor(uuid: uuid, value: value);
      //   }
      // }
      notifyListeners();
    }
  }

  List<int> getValueForUUID({Guid uuid}) {
    return _bleValues[uuid];
  }

  void clearValues() {
    _bleValues.clear();
  }

  void setServies({List<BluetoothService> services}) {
    print("Added Services to Provider");
    _connectedDeviceServices = services;
    print("calling startReadNotifyCalls");
    Future.delayed(Duration(seconds: 1), () {
      startReadNotifyCalls();
    });
  }

  void startReadNotifyCalls() async {
    //

    List<int> timeDataForBLEWrite = [0x5, 0, 0, 0, 0, 0, 0, 0, 0];
    int timestampEpochInSeconds = DateTime.now().millisecondsSinceEpoch ~/
        Duration
            .millisecondsPerSecond; //  ~/ Duration.millisecondsPerSecond is 1000
    print("timestampEpochInSeconds - $timestampEpochInSeconds");
    // DateTime  date =
    //     new DateTime.fromMillisecondsSinceEpoch(timestampEpochInSeconds * 1000);
    // print("date - $date");

    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    // print("Timestamp (seconds): $​timestamp​");
    // print("As utf8 encoded Bytes: ${​utf8.encode(timestamp.toString())}​");
    ByteData sendValue = ByteData(9);
    sendValue.setUint8(0, 5);
    sendValue.setUint32(1, timestamp.toInt(), Endian.little);
    print("asUint8List");
    print(sendValue.buffer.asUint8List());
    print("sendValue");
    print(sendValue.lengthInBytes);

    // Uint8List bytes = Uint8List.fromList(data);

    //
    // for (BluetoothService service in _connectedDeviceServices) {
    //   for (BluetoothCharacteristic characteristic in service.characteristics) {
    //     if (characteristic.properties.read) {
    //       var sub = characteristic.value.listen((value) {
    //         setValueForUUID(uuid: characteristic.uuid, value: value);
    //       });
    //       try {
    //         await Future.delayed(Duration(seconds: 1));
    //         await characteristic.read();
    //       } catch (e) {
    //         print("Error getting Read Data form BLE");
    //       } finally {
    //         sub.cancel();
    //       }
    //     }
    //     if (characteristic.properties.write) {}
    //     if (characteristic.properties.notify) {
    //       characteristic.value.listen((value) {
    //         setValueForUUID(uuid: characteristic.uuid, value: value);
    //       });
    //       try {
    //         await Future.delayed(Duration(seconds: 1));
    //         await characteristic.setNotifyValue(true);
    //       } catch (e) {
    //         print("Error getting Notify Data form BLE");
    //       }
    //     }
    //   }
    // }
    // if (isBlueToothConnected) {
    //   // startReadCalls();
    //   startReadNotifyCalls();
    // }
  }

  void startReadCalls() async {
    for (BluetoothService service in _connectedDeviceServices) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.read) {
          var sub = characteristic.value.listen((value) {
            setValueForUUID(uuid: characteristic.uuid, value: value);
          });
          try {
            await Future.delayed(Duration(seconds: 1));
            await characteristic.read();
          } catch (e) {
            print("Error getting Read Data form BLE");
          } finally {
            sub.cancel();
          }
        }
      }
    }
    if (isBlueToothConnected) {
      startReadCalls();
    }
  }

  // void cborValueFor({Guid uuid, List<int> value}) {
  //   //
  //   ///
  //   ///

  //   if (!_shown) {
  //     ///
  //     ///
  //     ///
  //     _shown = false;
  //     ////
  //     /////
  //     ///
  //     ///
  //     ///
  //     ///

  //     Cbor cborobj = Cbor();

  //     // Get our encoder
  //     final encoder = cborobj.encoder;

  //     try {
  //       //  // Encode some values
  //       //     encoder.writeArray(<int>[1, 2, 3]);

  //       print("encoding to with writeArray");
  //       if (encoder.writeArray(value)) {
  //         try {
  //           print("encoded successfully");

  //           // You can now get the encoded output.
  //           final buff = cborobj.output.getData();

  //           // and do what you want with it
  //           print("Getting toString()");
  //           print(buff.toString());

  //           // Or, we can decode ourselves
  //           print("Getting decodeFromInput");
  //           cborobj.decodeFromInput();

  //           // Then pretty print it
  //           print("Getting decodedPrettyprint");
  //           print(cborobj.decodedPrettyprint());
  //           //
  //         } catch (e) {
  //           print("Error Decoding From WriteArray");
  //         }
  //       }
  //     } catch (e) {
  //       print("Error Encoding From WriteArray");
  //     }

  //     ///
  //     ////
  //     ///
  //     ///
  //     ///
  //   }
  // }

  // void addReadCall({Function() function}) {
  //   _bleReadCalls.add(function);
  // }

  // void addNotifyCall({Function() function}) {
  //   _bleNotifyCalls.add(function);
  // }

  // void executeAllReadAndNotifyCalls() async {
  //   if (isBlueToothConnected) {
  //     print("AutoCalling Read And Notify Methods, Listener is already added, on listener invoke value is added by setValueForUUID() their notifyListeners(); is called which get latest value for thet guid and build method is re executed ");

  //     _executeAllReadCalls();
  //     _executeAllNotifyCalls();
  //   }
  // }

  // void _executeAllReadCalls() async {
  //   print("executing Read Call");
  //   if (isBlueToothConnected) {
  //     _bleReadCalls.forEach((call) async {
  //       if (isBlueToothConnected) {
  //         // // asynchronous methos without awaiting
  //         // Future.delayed(Duration(milliseconds: 200), () {
  //         //   call();
  //         // });
  //         call();
  //       }
  //     });
  //   }
  //   if (isBlueToothConnected) {
  //     await Future.delayed(Duration(seconds: 5), () {
  //       print("Started Read Calls After 5 Seconds");
  //       _executeAllReadCalls();
  //     });
  //   }
  // }

  // void _executeAllNotifyCalls() async {
  //   print("executing Notify Call");
  //   if (isBlueToothConnected) {
  //     _bleNotifyCalls.forEach((call) async {
  //       if (isBlueToothConnected) {
  //         // // asynchronous methos without awaiting
  //         // Future.delayed(Duration(milliseconds: 200), () {
  //         //   call();
  //         // });
  //         call();
  //       }
  //     });
  //   }
  // }

}
