import 'package:core/core.dart';
import 'package:file_manger/app/interfaces/ioc_register.dart';
import 'package:flutter/widgets.dart';
import 'package:file_manger/app/controllers/controllers.dart';
import 'package:file_manger/app/locales/locales.dart';
import 'package:file_manger/db/database.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:fvp/fvp.dart' as fvp;

import '../utils/window_manager_util.dart';

class Global {
  static const String appName = "File Manger";
  static String appVersion = "1.0.0";
  static final GetIt getIt = GetIt.instance;

  Global._();

  static void info(dynamic msg, [Object? exception, StackTrace? stackTrace]) {
    AppLogger().info(msg, exception, stackTrace);
  }

  static List<CommonInitialize Function()> getInitializes() {
    return [
      () => Storage(),
      () => Request(),
      () => PackageInfoUtil(),
      () => Locales(),
    ];
  }

  static List<IocRegister Function()> getIocRegisters() {
    return [() => WindowManagerUtil()];
  }

  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      var e = details.exception;
      var st = details.stack;
      AppLogger().handle(e, st);
    };

    info('应用开始初始化');
    await initCommon();
    initAppVersion();
    await initDatabase();
    registerServices();
    initIocRegisters();

    await Global.getIt<WindowManagerUtil>().init();

    initFvp();

    info('应用初始化完成');
  }

  static Future initCommon() async {
    List<CommonInitialize Function()> initializes = getInitializes();
    for (var initialize in initializes) {
      var instance = initialize();
      await instance.init();
      info(instance.getOutput());
    }
  }

  static void registerServices() {
    var themeController = Get.put(ThemeController());
    themeController.init();
  }

  static Future initDatabase() async {
    getIt.registerSingleton(AppDatabase());
    await getIt<AppDatabase>().init(getIt);
  }

  static initAppVersion() {
    appVersion = PackageInfoUtil().getVersion();
  }

  static void initIocRegisters() {
    List<IocRegister Function()> registers = getIocRegisters();
    for (var register in registers) {
      var instance = register();
      instance.register(getIt);
    }
  }

  static initFvp() async {
    fvp.registerWith(
      options: {
        // 'fastSeek': true,
        'player': {
          // if (Platform.isAndroid) 'audio.renderer': 'AudioTrack',
          'avio.reconnect': '1',
          'avio.reconnect_delay_max': '7',
          'buffer': '2000+80000',
          'demux.buffer.ranges': '8',
        },
        // if (Platform.isAndroid)
        //   'subtitleFontFile': 'assets/fonts/NotoSansCJKsc-Medium.otf',
        'global': {'log': 'debug'},
      },
    );
  }
}
