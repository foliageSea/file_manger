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
