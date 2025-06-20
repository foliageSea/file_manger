import 'package:file_manger/app/constants/constants.dart';
import 'package:file_manger/app/utils/theme_color_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class FileIconGenerator {
  static Map<String, IconData> getIconData() {
    Map<String, IconData> data = {};
    for (var element in supportVideoExtensions) {
      data[element] = CupertinoIcons.film;
    }
    return data;
  }

  static Widget getIcon(String fileName, [bool isDir = false]) {
    var color = ThemeColorUtil.getPrimaryColor(Get.context!);

    Icon getIcon(IconData iconData) {
      return Icon(iconData, color: color);
    }

    if (isDir) {
      return getIcon(CupertinoIcons.folder);
    }
    final list = fileName.split('.');
    if (list.length == 1) {
      return getIcon(CupertinoIcons.doc);
    }
    final ext = '.${list.last.toLowerCase()}';
    var icons = getIconData();
    if (icons.containsKey(ext)) {
      return getIcon(icons[ext]!);
    }

    return getIcon(CupertinoIcons.doc);
  }
}
