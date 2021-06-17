import 'package:flutter/material.dart';
import 'dart:io';

import "../controllers/PermissionController.dart";

class Alert {
  //
  //
  static Alert _instance;
  Alert._();
  static Alert get getInstance => _instance ??= Alert._();

  Future loading(
      {BuildContext context, String textmessage, Function callback}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext cx) {
        return AlertDialog(
          content: Container(
            height: 60,
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.all(15), child: Text("$textmessage")),
                LinearProgressIndicator(),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel connection",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () {
                callback();
                Navigator.pop(cx); //Loading
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  Future error({BuildContext context, String textmessage}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext cx) {
        return AlertDialog(
          content: Text("$textmessage"),
          actions: [
            TextButton(
                child: Text(
                  "Ok",
                  style: TextStyle(
                    color: Colors.blueAccent,
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(cx);
                }),
            if (textmessage.contains("Permanently Denied") || Platform.isIOS)
              //|| Platform.isIOS
              TextButton(
                child: Text("Grant Permisson",
                    style: TextStyle(color: Colors.greenAccent)),
                onPressed: () {
                  Navigator.of(cx).pop();
                  PermissionController.getInstance.openSettings();
                },
              ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }
}
