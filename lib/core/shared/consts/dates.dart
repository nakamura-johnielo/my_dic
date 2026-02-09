class MyDateTime {
  static DateTime get sentinel => DateTime.utc(1900, 1, 1);
  static DateTime getNowUTCDateHour() {
    DateTime now = DateTime.now().toUtc();
    // ISO8601形式で文字列化
    //2025-04-06T01:19:27.393Z
    return now;
  }
}
