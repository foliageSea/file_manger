StackTrace? handleStackTrace(StackTrace? stackTrace, [int maxStackLines = 16]) {
  if (stackTrace != null) {
    final stackLines = stackTrace.toString().split('\n');
    if (stackLines.length > maxStackLines) {
      stackTrace = StackTrace.fromString(
        '${stackLines.take(maxStackLines).join('\n')}\n... (${stackLines.length - maxStackLines} more)',
      );
    }
  }
  return stackTrace;
}
