import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';

import "../providers/BLEValuesProvider.dart";

// This is made because setState was making whole UI to update, on ble read notify value change
class ValueWidget extends StatelessWidget {
  const ValueWidget({
    Key key,
    @required this.context,
    @required this.uuid,
  }) : super(key: key);

  final BuildContext context;
  final Guid uuid;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Value: ' +
          context.watch<BLEValue>().getValueForUUID(uuid: uuid).toString(),
    );
  }
}
