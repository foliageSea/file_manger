import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:window_manager/window_manager.dart';

import '../interfaces/ioc_register.dart';

class WindowManagerUtil extends IocRegister {
  Future init() async {}

  static final Map<String, WindowManagerUtil Function()> _platformMap = {
    'windows': () => _WindowManagerUtilImpl(),
    'default': () => _WindowManagerUtilOther(),
  };

  @override
  void register(GetIt getIt) {
    String platformKey = Platform.isWindows ? 'windows' : 'default';
    // 从映射表中获取对应平台的实例
    getIt.registerSingleton<WindowManagerUtil>(_platformMap[platformKey]!());
  }
}

class _WindowManagerUtilImpl extends WindowManagerUtil {
  @override
  Future init() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    unawaited(
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      }),
    );
  }
}

class _WindowManagerUtilOther extends WindowManagerUtil {
  @override
  Future init() async {}
}
