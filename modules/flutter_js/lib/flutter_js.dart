import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_js/qjs_win_util.dart';

class FlutterJs {
  static const MethodChannel _channel = const MethodChannel('io.abner.flutter_js');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<int> initEngine([int id]) async {
    if (Platform.isWindows) {
      final int id = QJsWindowsUtil.initJS();
      return id;
    }
    final int engineId =
        await _channel.invokeMethod("initEngine", id ?? new Random().nextInt(1000));
    return engineId;
  }

  static Future<dynamic> evaluate(String command, int id) async {
    if (Platform.isWindows) {
      final int _id = QJsWindowsUtil.initJS();
      final rs = QJsWindowsUtil.evalJs(_id,
          "window_command = ${jsonEncode(command)};window_result = eval(window_command);JSON.stringify(window_result);");
      QJsWindowsUtil.freeJs(_id);
      return jsonDecode(rs);
    }
    var arguments = {"engineId": id, "command": command};
    final rs = await _channel.invokeMethod("evaluate", arguments);
    if (Platform.isAndroid) return jsonDecode(rs);
    return rs;
  }

  static Future<bool> close(int id) async {
    if (Platform.isWindows) {
      QJsWindowsUtil.freeJs(id);
      return true;
    }
    var arguments = {"engineId": id};
    _channel.invokeMethod("close", arguments);
    return true;
  }
  /*
  static Future<String> getString(String command, int id) async {
    final rs = await evaluate(command, id);
    return '$rs' ?? '';
  }

  static Future<List<String>> getStringList(String command, int id) async {
    final rs = await getList(command, id);
    if (rs.isEmpty) return <String>[];
    return rs.map((r) => '$r').toList();
  }

  static Future<Map<dynamic, dynamic>> getMap(String command, int id) async {
    final rs = await evaluate(command, id);
    return rs ?? Map<String, String>();
  }

  static Future<List<dynamic>> getList(String command, int id) async {
    final rs = await evaluate(command, id);
    if (rs == null) return <dynamic>[];
    return rs as List;
  }
  */
}
