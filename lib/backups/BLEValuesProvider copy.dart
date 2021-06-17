// import 'package:flutter/foundation.dart';
// import 'package:flutter_blue/flutter_blue.dart' show Guid;

// import 'package:cbor/cbor.dart';

// class BLEValue extends ChangeNotifier {
//   ///
//   ///
//   bool isBlueToothConnected = false;

//   ///
//   ///
//   Map<Guid, List<int>> _bleValues = {};

//   // List<Function> _bleReadAndNotifyCall = [];
//   List<Function> _bleReadCalls = [];
//   List<Function> _bleNotifyCalls = [];

//   bool _shown = false;

//   void setValueForUUID({Guid guid, List<int> value}) {
//     if (isBlueToothConnected) {
//       _bleValues[guid] = value;
//       if (value.length != 0) {
//         if (!_shown) {
//           cborValueFor(guid: guid, value: value);
//         }
//       }
//       notifyListeners();
//     }
//   }

//   void cborValueFor({Guid guid, List<int> value}) {
//     //
//     ///
//     ///

//     if (!_shown) {
//       ///
//       ///
//       ///
//       _shown = false;
//       ////
//       /////
//       ///
//       ///
//       ///
//       ///

//       Cbor cborobj = Cbor();

//       // Get our encoder
//       final encoder = cborobj.encoder;

//       try {
//         //  // Encode some values
//         //     encoder.writeArray(<int>[1, 2, 3]);

//         print("encoding to with writeArray");
//         if (encoder.writeArray(value)) {
//           try {
//             print("encoded successfully");

//             // You can now get the encoded output.
//             final buff = cborobj.output.getData();

//             // and do what you want with it
//             print("Getting toString()");
//             print(buff.toString());

//             // Or, we can decode ourselves
//             print("Getting decodeFromInput");
//             cborobj.decodeFromInput();

//             // Then pretty print it
//             print("Getting decodedPrettyprint");
//             print(cborobj.decodedPrettyPrint());
//             //
//           } catch (e) {
//             print("Error Decoding From WriteArray");
//           }
//         }
//       } catch (e) {
//         print("Error Encoding From WriteArray");
//       }

//       ///
//       ////
//       ///
//       ///
//       ///
//     }
//   }

//   List<int> getValueForUUID({Guid guid}) {
//     return _bleValues[guid];
//   }

//   void addReadCall({Function() function}) {
//     _bleReadCalls.add(function);
//   }

//   void addNotifyCall({Function() function}) {
//     _bleNotifyCalls.add(function);
//   }

//   void executeAllReadAndNotifyCalls() async {
//     if (isBlueToothConnected) {
//       print(
//           "AutoCalling Read And Notify Methods, Listener is already added, on listener invoke value is added by setValueForUUID() their notifyListeners(); is called which get latest value for thet guid and build method is re executed ");

//       _executeAllReadCalls();
//       _executeAllNotifyCalls();
//     }
//   }

//   void _executeAllReadCalls() async {
//     print("executing Read Call");
//     if (isBlueToothConnected) {
//       _bleReadCalls.forEach((call) async {
//         if (isBlueToothConnected) {
//           // // asynchronous methos without awaiting
//           // Future.delayed(Duration(milliseconds: 200), () {
//           //   call();
//           // });
//           call();
//         }
//       });
//     }
//     if (isBlueToothConnected) {
//       await Future.delayed(Duration(seconds: 5), () {
//         print("Started Read Calls After 5 Seconds");
//         _executeAllReadCalls();
//       });
//     }
//   }

//   void _executeAllNotifyCalls() async {
//     print("executing Notify Call");
//     if (isBlueToothConnected) {
//       _bleNotifyCalls.forEach((call) async {
//         if (isBlueToothConnected) {
//           // // asynchronous methos without awaiting
//           // Future.delayed(Duration(milliseconds: 200), () {
//           //   call();
//           // });
//           call();
//         }
//       });
//     }
//   }
// }
