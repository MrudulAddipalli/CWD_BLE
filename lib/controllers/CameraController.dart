import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import "./PermissionController.dart";
import "../helpers/alerts.dart";

class CameraController {
  //
  static CameraController _instance;
  CameraController._();
  static CameraController get getInstance => _instance ??= CameraController._();

  Future<bool> getCameraApproval(BuildContext context) async {
    //
    //
    String status = await PermissionController.getInstance
        .checkAndRequestPermission(requestedpermission: Permission.camera);
    if (status.contains("Permission")) {
      await Alert.getInstance.error(context: context, textmessage: status);
      return false;
    } else {
      String status = await PermissionController.getInstance
          .checkAndRequestPermission(
              requestedpermission: Permission.storage);
      if (status.contains("Permission")) {
        await Alert.getInstance.error(context: context, textmessage: status);
        return false;
      } else {
        return true;
      }
    }
  }
}
