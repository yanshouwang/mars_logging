import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:path/path.dart' as path;

extension IntListX on List<int> {
  Uint8List toUint8List() => Uint8List.fromList(this);

  BigInt toBigInt() => BigInt.parse(hex.encode(this), radix: 16);
}

extension BitIntX on BigInt {
  Uint8List toUint8List([Endian endian = Endian.little]) {
    // var text = toRadixString(16);
    // if (text.length.isOdd) {
    //   text = '0$text';
    // }
    // var elements = hex.decode(text);
    // if (endian == Endian.little) {
    //   elements = elements.reversed.toList();
    // }
    var temp = this;
    final length = (temp.bitLength + 7) >> 3;
    var elements = List.filled(length, 0);
    final mask = BigInt.from(0xff);
    for (int i = 0; i < length; i++) {
      final index = endian == Endian.little ? i : length - i - 1;
      elements[index] = (temp & mask).toInt();
      temp = temp >> 8;
    }
    return elements.toUint8List();
  }
}

extension StringX on String {
  bool get isDirectory => FileSystemEntity.isDirectorySync(this);
  bool get isFile => FileSystemEntity.isFileSync(this);

  String replaceExtension(String extension) =>
      '${path.withoutExtension(this)}.$extension';
}
