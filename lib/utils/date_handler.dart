//
//

String getNowUTCDateHour() {
  DateTime now = DateTime.now().toUtc();
  // ISO8601形式で文字列化
  //2025-04-06T01:19:27.393Z
  return now.toIso8601String();
}
