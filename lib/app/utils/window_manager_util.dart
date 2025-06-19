import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:window_manager/window_manager.dart';

import '../interfaces/ioc_register.dart';

class WindowManagerUtil extends IocRegister {
  Future init() async {}

  @override
  void register(GetIt getIt) {
    if (Platform.isWindows) {
      getIt.registerSingleton<WindowManagerUtil>(_WindowManagerUtilImpl());
    } else {
      getIt.registerSingleton<WindowManagerUtil>(_WindowManagerUtilOther());
    }
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
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

class _WindowManagerUtilOther extends WindowManagerUtil {
  @override
  Future init() async {}
}
