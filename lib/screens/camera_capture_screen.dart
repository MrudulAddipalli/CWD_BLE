import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraCaptureScreen extends StatefulWidget {
  @override
  _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String result = "Scanning...";
  QRViewController _captureController;
  bool _foundRelevantData = false;

  void _onQRViewCreated(QRViewController controller) {
    this._captureController = controller;
    _captureController.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData.code;
        print(result);
        print(result.length);
        print(result.split(":").length);
        // MAC Address
        // 17 Digit mac Address - D7:9B:93:AC:75:23
        // 5 : - D7:9B:93:AC:75:23
        if (result.length == 17 && result.split(":").length - 1 == 5) {
          print("Satisfying Condition");
          setState(() {
            _foundRelevantData = true;
          });
          _captureController.pauseCamera().then((_) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pop(context, {"macAddress": result});
            });
          });
        }
        // UUID
        // 36 Digit 00002a19-0000-1000-8000-00805f9b34fb
        if (result.length == 36 && result.split("-").length - 1 == 4) {
          print("Satisfying Condition");
          setState(() {
            _foundRelevantData = true;
          });
          _captureController.pauseCamera().then((_) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.pop(context, {"uuid": result});
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),

            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      // color: Colors.grey,
                      border: Border.all(
                          color:
                              _foundRelevantData ? Colors.green : Colors.white,
                          width: 5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(height: 300, width: 300),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("$result",
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ],
              ),
            ),
            //
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        _captureController.pauseCamera().then((_) {
                          Navigator.pop(context);
                        });
                      },
                      icon: Icon(
                        Icons.cancel,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      onPressed: () async {
                        await _captureController.flipCamera();
                      },
                      icon: Icon(
                        Icons.flip_camera_android,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 50),
                    IconButton(
                      onPressed: () async {
                        await _captureController.toggleFlash();
                      },
                      icon: Icon(
                        Icons.flash_auto,
                        size: 30,
                        color: Colors.white,
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
}
