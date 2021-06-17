import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import "../providers/BLEValuesProvider.dart";

import "../helpers/alerts.dart";
import "../controllers/CameraController.dart";
import "../screens/camera_capture_screen.dart";
import "../widgets/value_text.dart";

class BLEScreen extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];
  // Map<Guid, List<int>> readValues = {};

  StreamController<Map<String, dynamic>> currentBluetoothState =
      StreamController<Map<String, dynamic>>();

  bool isScanning = false;

  @override
  _BLEScreenState createState() => _BLEScreenState();
}

class _BLEScreenState extends State<BLEScreen> {
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice = null;
  List<BluetoothService> _services = [];

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      if (mounted) {
        if (mounted) {
          setState(() {
            widget.devicesList.add(device);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      // //
      // // to remove lost rande device
      // widget.devicesList.clear();
      // //
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      // //
      // // to remove lost rande device
      // widget.devicesList.clear();
      // //
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.state.listen((BluetoothState state) {
      print("state - $state");
      if (state == BluetoothState.on) {
        widget.currentBluetoothState
            .add({"status": "ON", "color": Colors.cyan[300]});
      } else if (state == BluetoothState.off) {
        widget.currentBluetoothState
            .add({"status": "OFF", "color": Colors.redAccent});
      } else if (state == BluetoothState.unavailable) {
        widget.currentBluetoothState
            .add({"status": "Unavailable", "color": Colors.yellow});
      } else if (state == BluetoothState.turningOn) {
        widget.currentBluetoothState
            .add({"status": "Turning ON", "color": Colors.cyan[300]});
      } else if (state == BluetoothState.turningOff) {
        widget.currentBluetoothState
            .add({"status": "Turning OFF", "color": Colors.redAccent});
      } else if (state == BluetoothState.unauthorized) {
        widget.currentBluetoothState
            .add({"status": "Unauthorized", "color": Colors.red});
      } else if (state == BluetoothState.unknown) {
        widget.currentBluetoothState
            .add({"status": "Null", "color": Colors.grey});
      }
    });
    // print("\n\n\n\n\nScanning\n\n\n\n\n");
    //   if (mounted) {
    // setState(() {
    //   widget.isScanning = true;
    // });
    // }
    // widget.flutterBlue.startScan();
    // Future.delayed(Duration(seconds: 10), () {
    //   stoptScan();
    // });

    startScan();
  }

  @override
  void dispose() {
    if (_connectedDevice != null) {
      _connectedDevice.disconnect();
    }
    widget.currentBluetoothState.close();
    super.dispose();
  }

  void startScan() {
    print("\n\n\n\n\nScanning\n\n\n\n\n");
    if (mounted) {
      setState(() {
        widget.devicesList.clear();
        widget.isScanning = true;
      });
    }
    widget.flutterBlue.startScan();

    Future.delayed(Duration(seconds: 15), () {
      print("Scanning Stop After 15 Seconds");
      stoptScan();
    });
  }

  void stoptScan() {
    print("\n\n\n\n\nScanning Stoped\n\n\n\n\n");
    if (mounted) {
      setState(() {
        widget.isScanning = false;
      });
    }
    widget.flutterBlue.stopScan();
  }

  void connectToDevice(BluetoothDevice device) async {
    //
    bool isloading = true;
    print("Connecting to device - ${device.name}");
    Alert.getInstance.loading(
        context: context,
        textmessage: "Connecting Please Wait!!",
        callback: () {
          device.disconnect();
          setState(() {
            isloading = false;
          });
          print("Connecting Cancelled");
          return;
        });
    print("after loading");
    try {
      //

      await device
          .connect(timeout: Duration(seconds: 5), autoConnect: false)
          .timeout(Duration(seconds: 5), onTimeout: () {
        if (isloading) {
          Navigator.pop(context); //Loading
        }
        // Alert.getInstance.error(
        //     context: context,
        //     textmessage:
        //         "2 Error Connecting To Device\nPlease Turn On Your Bluetooth Device\nor\nPlease Check Your Device's Bluetooth And Location Status");
      });

      ///
      print("discoverServices");
      _services = await device.discoverServices();
      context.read<BLEValue>().setServies(services: _services);

      if (isloading) {
        Navigator.pop(context); //Loading
      }
      print("Loading Poppod");
      if (mounted) {
        setState(() {
          _connectedDevice = device;
        });
      }
      context.read<BLEValue>().isBlueToothConnected = true;
      stoptScan();

      ////
    } catch (e) {
      ///
      if (isloading) {
        Navigator.pop(context); //Loading
      }
      if (e != null && e.code == 'already_connected') {
        Alert.getInstance
            .error(context: context, textmessage: "Device Already Connected");
        _services = await device.discoverServices();
        context.read<BLEValue>().setServies(services: _services);
        if (mounted) {
          setState(() {
            _connectedDevice = device;
          });
        }
        context.read<BLEValue>().isBlueToothConnected = true;

        ///
      } else {
        Alert.getInstance.error(
            context: context,
            textmessage:
                "1 Error Connecting To Device\nPlease Turn On Your Bluetooth Device\nor\nPlease Check Your Device's Bluetooth And Location Status");
      }
    } finally {
      // print("discoverServices");
      // _services = await device.discoverServices();
      // context.read<BLEValue>().setServies(services: _services);

      // if (isloading) {
      //   Navigator.pop(context); //Loading
      // }
      // print("Loading Poppod");
      // if (mounted) {
      //   setState(() {
      //     _connectedDevice = device;
      //   });
      // }
      // context.read<BLEValue>().isBlueToothConnected = true;
      // stoptScan();
    }
  }

  BluetoothDevice getBlueToothDeviceObjectFromScannedList(
      {String macAddress, String uuid}) {
    BluetoothDevice mydevice = null;
    widget.devicesList.forEach((device) {
      if (device.id.toString() == macAddress) {
        mydevice = device;
      }
      if (device.id.toString() == uuid) {
        mydevice = device;
      }
    });
    return mydevice;
  }

  ListView _buildListViewOfDevices() {
    List<ListTile> containers = [];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        ListTile(
          title: Text(
            device.name == '' ? '[Name Not Discoverable]' : device.name,
          ),
          subtitle: Text(
            device.id.toString(),
          ),
          trailing: FlatButton(
            color: Colors.blue,
            child: Text(
              'Connect',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              connectToDevice(device);
            },
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = [];

    // characteristic.value.listen((value) {
    //   context
    //       .read<BLEValue>()
    //       .setValueForUUID(uuid: characteristic.uuid, value: value);
    // });

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                var sub = characteristic.value.listen((value) {
                  context
                      .read<BLEValue>()
                      .setValueForUUID(uuid: characteristic.uuid, value: value);
                });

                try {
                  await characteristic.read();
                } catch (e) {
                  print(
                      "Something Went Wrong, Please check your bluetooth status, or device status or readCharacteristic was called before last read finished.");
                  print(e);

                  // try to autoconnect
                  try {
                    await _connectedDevice.connect();
                  } catch (e) {
                    if (e != null && e.code != 'already_connected') {
                    } else {
                      Alert.getInstance.error(
                          context: context,
                          textmessage:
                              "Something Went Wrong, Please check your bluetooth status, or device status\nor\nreadCharacteristic was called before last read finished.");
                    }
                  }
                }
                // TODO: remoce cancel
                sub.cancel();
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              print(
                                  "String is - ${_writeController.value.text}");
                              print(
                                  "UTF8 - ${utf8.encode(_writeController.value.text)}");
                              // characteristic.write(
                              //     utf8.encode(_writeController.value.text));

                              // print(utf8.encode("12")); // converts to List<int>
                              // I/flutter (24563): [49, 50]
                              //
                              // print(utf8.encode("5")); // converts to List<int>
                              // I/flutter (24563): [53]
                              //
                              // characteristic.write(utf8.encode("5")); //[53]
                              //
                              // characteristic.write([1, 2]); //[1,2]
                              // characteristic.write([0x12, 0x34]); //[18,52]

                              // final bytesBuilder = BytesBuilder();
                              // bytesBuilder.addByte(42);
                              // bytesBuilder.add([0, 5, 255]);
                              // bytesBuilder.takeBytes();

                              // List<int> data = [3, 256, -2, 2348738473];
                              // Uint8List bytes = Uint8List.fromList(data);
                              // print(bytes); // [3, 0, 254, 169]

                              //

                              int timestamp =
                                  DateTime.now().millisecondsSinceEpoch ~/ 1000;
                              // print("Timestamp (seconds): $​timestamp​");
                              // print("As utf8 encoded Bytes: ${​utf8.encode(timestamp.toString())}​");
                              ByteData sendValue = ByteData(9);
                              sendValue.setUint8(0, 5);

                              sendValue.setUint32(
                                  1, timestamp.toInt(), Endian.little);
                              print("asUint8List");
                              print(sendValue.buffer.asUint8List());
                              print("sendValue");
                              print(sendValue.lengthInBytes);

                              characteristic
                                  .write(sendValue.buffer.asUint8List());

                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                characteristic.value.listen((value) {
                  context
                      .read<BLEValue>()
                      .setValueForUUID(uuid: characteristic.uuid, value: value);
                });
                try {
                  await characteristic.setNotifyValue(true);
                } catch (e) {
                  print("Error getting Notify Date form BLE");
                }
              },
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = [];

    containers.add(
      Container(
        child: ListTile(
          title: Text("Connected Device"),
          subtitle: Text("${_connectedDevice.name}"),
          trailing: ElevatedButton(
            child: Text(
              'Disconnect',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              try {
                _connectedDevice.disconnect();

                ///
              } catch (e) {
                print(
                    "\n\n\n\n\n\nConnection Was Not Established To This Device\n\n\n\n\n\n");
                // Alert.getInstance.error(
                //     context: context,
                //     textmessage:
                //         "Connection Was Not Established To This Device");
              } finally {
                if (mounted) {
                  setState(() {
                    _connectedDevice = null;
                  });
                }
                context.read<BLEValue>().isBlueToothConnected = false;
                context.read<BLEValue>().clearValues();
                startScan();
              }
            },
          ),
        ),
      ),
    );

    int _servicescount = 1;

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = [];

      int _characteristicscount = 1;
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text("Characteristic -$_characteristicscount"),
                  subtitle: Text(characteristic.uuid.toString()),
                ),
                // Row(
                //   children: <Widget>[
                //     Text("Characteristic -$_characteristicscount",
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //   ],
                // ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Wrap(
                  children: <Widget>[
                    ////
                    ///
                    // This is made because setState was making whole UI to update, on ble read notify value change
                    ///
                    ///
                    ValueWidget(context: context, uuid: characteristic.uuid),

                    //  context.watch<BLEValue>().getValueForUUID(
                    //     guid: characteristic.uuid);
                    // Text('Value: ' +
                    //     widget.readValues[characteristic.uuid].toString()),
                  ],
                ),
                Divider(
                  thickness: 3,
                ),
              ],
            ),
          ),
        );

        // for (BluetoothDescriptor descriptor in characteristic.descriptors) {
        //   print("Descriptor - $descriptor");
        //   // print("Read - ${descriptor.read()}");
        //   descriptor.read().then((value) => {print("Read - $value")});
        // }

        _characteristicscount++;
      }
      containers.add(
        Container(
          child: ExpansionTile(
            initiallyExpanded: true,
            title: Text("Service ${_servicescount}"),
            subtitle: Text(service.uuid.toString()),
            children: (characteristicsWidget.length != 0)
                ? characteristicsWidget
                : [Text("Nothing Found"), Divider(thickness: 3)],
          ),
        ),
      );

      _servicescount++;
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CWD BLE'),
        actions: [
          if (widget.isScanning)
            Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: widget.isScanning ? stoptScan : startScan,
          )
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: widget.currentBluetoothState.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: double.infinity,
                    height: 30,
                    color: snapshot.data["color"],
                    child: Center(
                      child: Text(
                        "Bluetooth ${snapshot.data["status"]}",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
                return Container(
                  width: double.infinity,
                  height: 30,
                  child: Center(
                    child: Text(
                      "Bluetooth Is Turned Off}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }),
          Expanded(child: _buildView()),
        ],
      ),
      floatingActionButton: (_connectedDevice == null)
          ? FloatingActionButton(
              child: Icon(Icons.camera),
              onPressed: () async {
                bool status = await CameraController.getInstance
                    .getCameraApproval(context);
                if (status) {
                  //
                  //
                  startScan();
                  //
                  //
                  Map<String, String> response = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraCaptureScreen(),
                    ),
                  );

                  BluetoothDevice device;
                  print(
                      'Data is - macAddress - ${response["macAddress"]} uuid - ${response["uuid"]}');

                  if (response["macAddress"] != null ||
                      response["uuid"] != null) {
                    device = getBlueToothDeviceObjectFromScannedList(
                        macAddress: response["macAddress"],
                        uuid: response["uuid"]);

                    if (device != null) {
                      print("Device From Scan For QRScanned Data - $device");
                      connectToDevice(device);
                    } else {
                      //device not available in list , i.e scaning is not running or BLE is not turned on

                      Alert.getInstance.error(
                          context: context,
                          textmessage:
                              "Please Turn On Your Bluetooth Device\nor\nPlease Check Your Device's Bluetooth Status\nor\nKeep The BlueTooth Device Near To Your Mobile Device");
                      // startScan();
                    }
                  }
                }
              },
            )
          : Container(),
    );
  }
}
