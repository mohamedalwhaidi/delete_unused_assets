enum ConsoleColorType { success, error, attention, info }

write(String text, {ConsoleColorType colorType = ConsoleColorType.success}) {
  const resetColor = '\x1B[0m';
  final String color;
  switch (colorType) {
    case ConsoleColorType.error:
      color = '\x1B[31m';
      break;
    case ConsoleColorType.success:
      color = '\x1B[32m';
      break;
    case ConsoleColorType.attention:
      color = '\x1B[33m';
      break;
    case ConsoleColorType.info:
      color = '\x1B[34m';
      break;
  }
  print('$color$text$resetColor');
}

