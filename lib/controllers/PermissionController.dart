import 'package:simple_permissions/simple_permissions.dart';

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
    bool checkResult = false;
    try {
      checkResult =
          await SimplePermissions.checkPermission(requestedpermission);
    } catch (e) {
      // PermissionStatus x =
      //     await SimplePermissions.getPermissionStatus(requestedpermission);
      // print("PermissionStatus For IOS Devices - $PermissionStatus");

      return "Success";
    }
    if (!checkResult) {
      var status =
          await SimplePermissions.requestPermission(requestedpermission);
      print("Permission Status - $status");
      if (status == PermissionStatus.authorized) {
        print("permission granted");
        return "Success";
      } else {
        print("permission denied");
        if (status == PermissionStatus.deniedNeverAsk) {
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
    SimplePermissions.openSettings();
  }
}
