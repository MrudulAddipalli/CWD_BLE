import 'package:flutter/material.dart';

import 'package:simple_permissions/simple_permissions.dart';

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
        .checkAndRequestPermission(requestedpermission: Permission.Camera);
    if (status.contains("Permission")) {
      await Alert.getInstance.error(context: context, textmessage: status);
      return false;
    } else {
      String status = await PermissionController.getInstance
          .checkAndRequestPermission(
              requestedpermission: Permission.WriteExternalStorage);
      if (status.contains("Permission")) {
        await Alert.getInstance.error(context: context, textmessage: status);
        return false;
      } else {
        return true;
      }
    }
  }
}
