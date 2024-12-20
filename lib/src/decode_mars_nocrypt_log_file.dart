// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

const MAGIC_NO_COMPRESS_START = 0x03;
const MAGIC_NO_COMPRESS_START1 = 0x06;
const MAGIC_NO_COMPRESS_NO_CRYPT_START = 0x08;
const MAGIC_COMPRESS_START = 0x04;
const MAGIC_COMPRESS_START1 = 0x05;
const MAGIC_COMPRESS_START2 = 0x07;
const MAGIC_COMPRESS_NO_CRYPT_START = 0x09;
const MAGIC_END = 0x00;

int lastSeq = 0;

(bool, String) isGoodLogBuffer(Uint8List buffer, int offset, int count) {
  if (offset == buffer.length) {
    return (true, '');
  }

  final magicStart = buffer[offset];
  int cryptKeyLen;
  switch (magicStart) {
    case MAGIC_NO_COMPRESS_START:
    case MAGIC_COMPRESS_START:
    case MAGIC_COMPRESS_START1:
      cryptKeyLen = 4;
      break;
    case MAGIC_COMPRESS_START2:
    case MAGIC_NO_COMPRESS_START1:
    case MAGIC_NO_COMPRESS_NO_CRYPT_START:
    case MAGIC_COMPRESS_NO_CRYPT_START:
      cryptKeyLen = 64;
      break;
    default:
      return (false, 'buffer[$offset]:${buffer[offset]} != MAGIC_NUM_START');
  }

  final headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;

  if (offset + headerLen + 1 + 1 > buffer.length) {
    return (false, 'offset:$offset > buffer.length:${buffer.length}');
  }

  final length =
      ByteData.view(buffer.buffer, offset + headerLen - 4 - cryptKeyLen)
          .getUint32(0, Endian.little);

  if (offset + headerLen + length + 1 > buffer.length) {
    return (
      false,
      'log length:$length, end pos ${offset + headerLen + length + 1} > buffer.length:${buffer.length}'
    );
  }

  if (buffer[offset + headerLen + length] != MAGIC_END) {
    return (
      false,
      'log length:$length, buffer[${offset + headerLen + length}]:${buffer[offset + headerLen + length]} != MAGIC_END'
    );
  }

  if (count <= 1) {
    return (true, '');
  }

  return isGoodLogBuffer(buffer, offset + headerLen + length + 1, count - 1);
}

int getLogStartPos(Uint8List buffer, int count) {
  for (int offset = 0; offset < buffer.length; offset++) {
    final magicStart = buffer[offset];
    if (magicStart == MAGIC_NO_COMPRESS_START ||
        magicStart == MAGIC_NO_COMPRESS_START1 ||
        magicStart == MAGIC_COMPRESS_START ||
        magicStart == MAGIC_COMPRESS_START1 ||
        magicStart == MAGIC_COMPRESS_START2 ||
        magicStart == MAGIC_COMPRESS_NO_CRYPT_START) {
      if (isGoodLogBuffer(buffer, offset, count).$1) {
        return offset;
      }
    }
  }
  return -1;
}

int decodeBuffer(Uint8List buffer, int offset, List<int> outBuffer) {
  if (offset >= buffer.length) {
    return -1;
  }

  final ret = isGoodLogBuffer(buffer, offset, 1);
  if (!ret.$1) {
    final fixPos = getLogStartPos(buffer.sublist(offset), 1);
    if (fixPos == -1) {
      return -1;
    } else {
      outBuffer.addAll(utf8.encode(
          '[F]decode_log_file.py decode error len=$fixPos, result: ${ret.$2}\n'));
      offset += fixPos;
    }
  }

  final magicStart = buffer[offset];
  int cryptKeyLen;
  switch (magicStart) {
    case MAGIC_NO_COMPRESS_START:
    case MAGIC_COMPRESS_START:
    case MAGIC_COMPRESS_START1:
      cryptKeyLen = 4;
      break;
    case MAGIC_COMPRESS_START2:
    case MAGIC_NO_COMPRESS_START1:
    case MAGIC_NO_COMPRESS_NO_CRYPT_START:
    case MAGIC_COMPRESS_NO_CRYPT_START:
      cryptKeyLen = 64;
      break;
    default:
      outBuffer.addAll(utf8.encode(
          'in DecodeBuffer _buffer[$offset]:$magicStart != MAGIC_NUM_START'));
      return -1;
  }

  final headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;
  final length =
      ByteData.view(buffer.buffer, offset + headerLen - 4 - cryptKeyLen)
          .getUint32(0, Endian.little);

  final tmpBuffer = Uint8List.fromList(
      buffer.sublist(offset + headerLen, offset + headerLen + length));

  final seq =
      ByteData.view(buffer.buffer, offset + headerLen - 4 - cryptKeyLen - 2 - 2)
          .getUint16(0, Endian.little);
  // final beginHour = buffer[offset + headerLen - 4 - cryptKeyLen - 1 - 1];
  // final endHour = buffer[offset + headerLen - 4 - cryptKeyLen - 1];

  if (seq != 0 && seq != 1 && lastSeq != 0 && seq != lastSeq + 1) {
    outBuffer.addAll(utf8.encode(
        '[F]decode_log_file.py log seq:${lastSeq + 1}-${seq - 1} is missing\n'));
  }

  if (seq != 0) {
    lastSeq = seq;
  }

  try {
    final decompressor = ZLibCodec(
      windowBits: ZLibOption.maxWindowBits,
      raw: true,
    );

    switch (magicStart) {
      case MAGIC_NO_COMPRESS_START1:
      case MAGIC_COMPRESS_START2:
        log("use wrong decode script");
        break;
      case MAGIC_COMPRESS_START:
      case MAGIC_COMPRESS_NO_CRYPT_START:
        outBuffer.addAll(decompressor.decode(tmpBuffer));
        break;
      case MAGIC_COMPRESS_START1:
        final decompressData = <int>[];
        var remainingBuffer = tmpBuffer;
        while (remainingBuffer.isNotEmpty) {
          final singleLogLen = ByteData.view(remainingBuffer.buffer, 0)
              .getUint16(0, Endian.little);
          decompressData.addAll(remainingBuffer.sublist(2, singleLogLen + 2));
          remainingBuffer = remainingBuffer.sublist(singleLogLen + 2);
        }
        outBuffer
            .addAll(decompressor.decode(Uint8List.fromList(decompressData)));
        break;
    }
  } catch (e) {
    outBuffer.addAll(
        utf8.encode('[F]decode_log_file.py decompress err, ${e.toString()}\n'));
    return offset + headerLen + length + 1;
  }

  return offset + headerLen + length + 1;
}

void parseFile(String file, String outfile) {
  final fileBytes = File(file).readAsBytesSync();
  final startPos = getLogStartPos(fileBytes, 2);
  if (startPos == -1) {
    return;
  }

  final outBuffer = <int>[];

  var currentPos = startPos;
  while (true) {
    currentPos = decodeBuffer(fileBytes, currentPos, outBuffer);
    if (currentPos == -1) {
      break;
    }
  }

  if (outBuffer.isEmpty) {
    return;
  }

  File(outfile).writeAsBytesSync(outBuffer);
}

void main(List<String> arguments) {
  if (arguments.length == 1) {
    final dir = Directory(arguments[0]);
    if (dir.existsSync()) {
      for (final file in dir
          .listSync(recursive: false, followLinks: false)
          .whereType<File>()) {
        if (file.path.endsWith('.xlog')) {
          lastSeq = 0;
          parseFile(file.path, '${file.path}.log');
        }
      }
    } else {
      parseFile(arguments[0], '${arguments[0]}.log');
    }
  } else if (arguments.length == 2) {
    parseFile(arguments[0], arguments[1]);
  } else {
    for (final file in Directory.current
        .listSync(recursive: false, followLinks: false)
        .whereType<File>()) {
      if (file.path.endsWith('.xlog')) {
        lastSeq = 0;
        parseFile(file.path, '${file.path}.log');
      }
    }
  }
}
