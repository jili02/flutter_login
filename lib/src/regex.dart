class Regex {
  // https://stackoverflow.com/a/32686261/9449426
  static final email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final chinesePhoneNumber = RegExp(r'/^1([38]\d|5[0-35-9]|7[3678])\d{8}$/');
}
