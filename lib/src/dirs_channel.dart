abstract interface class DirsChannel {
  String get filesDir;
  List<String> get externalFilesDirs;
  String? get externalFilesDir;
  String get storageDir;
}
