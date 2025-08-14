import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:path/path.dart' as path;

extension IntListX on List<int> {
  Uint8List toUint8List() => Uint8List.fromList(this);

  BigInt toBigInt() => BigInt.parse(hex.encode(this), radix: 16);
}

extension BitIntX on BigInt {
  Uint8List toUint8List() {
    final encoded = toRadixString(16);
    return hex.decode(encoded).toUint8List();
  }
}

extension StringX on String {
  bool get isDirectory => FileSystemEntity.isDirectorySync(this);
  bool get isFile => FileSystemEntity.isFileSync(this);

  String replaceExtension(String extension) =>
      '${path.withoutExtension(this)}.$extension';
}
