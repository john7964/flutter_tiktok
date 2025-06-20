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


extension Timestamp on int {
  String get formatTimestamp {
    final DateTime now = DateTime.now();
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(this);
    final Duration diff = now.difference(date);

    if (diff.inMinutes < 3) {
      return "刚刚";
    }
    if (now.year == date.year && now.month == date.month && now.day == date.day) {
      return "今天 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.month}-${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}