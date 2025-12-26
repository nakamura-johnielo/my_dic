// Web環境用のdart:ioスタブファイル
// dart:ioが使えないWeb環境で例外をスローする

class File {
  File(String path) {
    throw UnsupportedError('File operations are not supported on web');
  }
  
  Future<bool> exists() async {
    throw UnsupportedError('File operations are not supported on web');
  }
  
  Future<void> delete() async {
    throw UnsupportedError('File operations are not supported on web');
  }
  
  Future<void> writeAsBytes(List<int> bytes, {bool flush = false}) async {
    throw UnsupportedError('File operations are not supported on web');
  }
}

class Directory {
  Directory(String path) {
    throw UnsupportedError('Directory operations are not supported on web');
  }
  
  Future<bool> exists() async {
    throw UnsupportedError('Directory operations are not supported on web');
  }
  
  Future<Directory> create({bool recursive = false}) async {
    throw UnsupportedError('Directory operations are not supported on web');
  }
  
  String get path {
    throw UnsupportedError('Directory operations are not supported on web');
  }
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isWindows => false;
  static bool get isMacOS => false;
  static bool get isLinux => false;
}
