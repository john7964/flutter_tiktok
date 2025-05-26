extension DurationFormatter on Duration {
  String get formattedString {
    int hour = inHours;
    int minutes = (inMicroseconds % Duration.microsecondsPerHour) ~/ Duration.microsecondsPerMinute;
    int seconds =
        (inMicroseconds % Duration.microsecondsPerMinute) ~/ Duration.microsecondsPerSecond;

    String res = "";
    if (hour > 0) {
      res += "${hour.twoDigitalString}:";
    }
    return "$res${minutes.twoDigitalString}:${seconds.twoDigitalString}";
  }
}

extension IntFormatter on int {
  String get twoDigitalString {
    return this < 10 ? "0$this" : "$this";
  }
}
