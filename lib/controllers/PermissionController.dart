import 'package:permission_handler/permission_handler.dart';

class PermissionController {
  //
  //
  static PermissionController _instance;
  PermissionController._();
  static PermissionController get getInstance =>
      _instance ??= PermissionController._();
  //
  Future<String> checkAndRequestPermission(
      {Permission requestedpermission}) async {
    // print("checking permission");
    PermissionStatus checkResult = PermissionStatus.denied;
    try {
      if (requestedpermission == Permission.camera) {
        checkResult = await Permission.camera.status;
      } else if (requestedpermission == Permission.storage) {
        checkResult = await Permission.storage.status;
      } else if (requestedpermission == Permission.bluetooth) {
        checkResult = await Permission.bluetooth.status;
      }
    } catch (e) {
      // PermissionStatus x =
      //     await SimplePermissions.getPermissionStatus(requestedpermission);
      // print("PermissionStatus For IOS Devices - $PermissionStatus");

      return "Success";
    }
    if (!checkResult.isGranted) {
      PermissionStatus status;
      if (requestedpermission == Permission.camera) {
        status = await Permission.contacts.request();
      } else if (requestedpermission == Permission.storage) {
        status = await Permission.contacts.request();
      } else if (requestedpermission == Permission.bluetooth) {
        status = await Permission.contacts.request();
      }
      print("Permission Status - $status");
      if (status == PermissionStatus.granted) {
        print("permission granted");
        return "Success";
      } else {
        print("permission denied");
        if (status == PermissionStatus.denied) {
          return "Permission Permanently Denied";
        } else {
          return "Without Permission We Cannot Proceed Further";
        }
      }
    } else {
      return "Success";
    }
  }

  void openSettings() {
    openAppSettings();
  }
}
