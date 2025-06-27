String calFileSize(int? fileSize) {
  final size = fileSize ?? 0;
  if (size == 0) return '';

  const units = ['B', 'KB', 'MB', 'GB'];
  var unitIndex = 0;
  var displaySize = size.toDouble();

  while (displaySize >= 1024 && unitIndex < units.length - 1) {
    displaySize /= 1024;
    unitIndex++;
  }

  return '${displaySize.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
}

// 新增格式化方法
String formatDuration(int seconds) {
  if (seconds < 60) {
    return '$seconds秒';
  } else if (seconds < 3600) {
    return '${(seconds / 60).toStringAsFixed(1)}分钟';
  } else {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '$hours小时$minutes分钟';
  }
}
