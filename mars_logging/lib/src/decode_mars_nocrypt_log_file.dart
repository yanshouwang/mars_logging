import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:es_compression/zstd.dart';

const MAGIC_NO_COMPRESS_START = 0x03;
const MAGIC_NO_COMPRESS_START1 = 0x06;
const MAGIC_NO_COMPRESS_NO_CRYPT_START = 0x08;
const MAGIC_COMPRESS_START = 0x04;
const MAGIC_COMPRESS_START1 = 0x05;
const MAGIC_COMPRESS_START2 = 0x07;
const MAGIC_COMPRESS_NO_CRYPT_START = 0x09;

const MAGIC_SYNC_ZSTD_START = 0x0A;
const MAGIC_SYNC_NO_CRYPT_ZSTD_START = 0x0B;
const MAGIC_ASYNC_ZSTD_START = 0x0C;
const MAGIC_ASYNC_NO_CRYPT_ZSTD_START = 0x0D;

const MAGIC_END = 0x00;

int lastSeq = 0;

(bool, String) isGoodLogBuffer(Uint8List buffer, int offset, int count) {
  if (offset == buffer.length) {
    return (true, '');
  }

  final magicStart = buffer[offset];
  int cryptKeyLen;
  if (magicStart == MAGIC_NO_COMPRESS_START ||
      magicStart == MAGIC_COMPRESS_START ||
      magicStart == MAGIC_COMPRESS_START1) {
    cryptKeyLen = 4;
  } else if (magicStart == MAGIC_COMPRESS_START2 ||
      magicStart == MAGIC_NO_COMPRESS_START1 ||
      magicStart == MAGIC_NO_COMPRESS_NO_CRYPT_START ||
      magicStart == MAGIC_COMPRESS_NO_CRYPT_START ||
      magicStart == MAGIC_SYNC_ZSTD_START ||
      magicStart == MAGIC_SYNC_NO_CRYPT_ZSTD_START ||
      magicStart == MAGIC_ASYNC_ZSTD_START ||
      magicStart == MAGIC_ASYNC_NO_CRYPT_ZSTD_START) {
    cryptKeyLen = 64;
  } else {
    return (false, 'buffer[$offset]:$magicStart != MAGIC_NUM_START');
  }

  final headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;

  if (offset + headerLen + 1 + 1 > buffer.length) {
    return (false, 'offset:$offset > buffer.length:${buffer.length}');
  }
  final bufferView = ByteData.view(buffer.buffer);
  final length = bufferView.getUint32(
    offset + headerLen - 4 - cryptKeyLen,
    Endian.little,
  );
  if (offset + headerLen + length + 1 > buffer.length) {
    return (
      false,
      'log length:$length, end pos ${offset + headerLen + length + 1} > buffer.length:${buffer.length}',
    );
  }
  if (MAGIC_END != buffer[offset + headerLen + length]) {
    return (
      false,
      'log length:$length, buffer[${offset + headerLen + length}]:${buffer[offset + headerLen + length]} != MAGIC_END',
    );
  }

  if (count <= 1) {
    return (true, '');
  } else {
    return isGoodLogBuffer(buffer, offset + headerLen + length + 1, count - 1);
  }
}

int getLogStartPos(Uint8List buffer, int count) {
  for (int offset = 0; offset < buffer.length; offset++) {
    int magicStart = buffer[offset];
    if (magicStart == MAGIC_NO_COMPRESS_START ||
        magicStart == MAGIC_NO_COMPRESS_START1 ||
        magicStart == MAGIC_COMPRESS_START ||
        magicStart == MAGIC_COMPRESS_START1 ||
        magicStart == MAGIC_COMPRESS_START2 ||
        magicStart == MAGIC_COMPRESS_NO_CRYPT_START ||
        magicStart == MAGIC_NO_COMPRESS_NO_CRYPT_START ||
        magicStart == MAGIC_SYNC_ZSTD_START ||
        magicStart == MAGIC_SYNC_NO_CRYPT_ZSTD_START ||
        magicStart == MAGIC_ASYNC_ZSTD_START ||
        magicStart == MAGIC_ASYNC_NO_CRYPT_ZSTD_START) {
      var (isGood, _) = isGoodLogBuffer(buffer, offset, count);
      if (isGood) {
        return offset;
      }
    }
  }
  return -1;
}

int decodeBuffer(Uint8List buffer, int offset, BytesBuilder outBuffer) {
  if (offset >= buffer.length) return -1;
  final (isGood, err) = isGoodLogBuffer(buffer, offset, 1);
  if (!isGood) {
    int fixPos = getLogStartPos(buffer.sublist(offset), 1);
    if (fixPos == -1) {
      return -1;
    } else {
      outBuffer.add(
        utf8.encode(
          "[F]decode_log_file.dart decode error len=$fixPos, result:$err\n",
        ),
      );
      offset += fixPos;
    }
  }

  final magicStart = buffer[offset];
  int cryptKeyLen;
  if (magicStart == MAGIC_NO_COMPRESS_START ||
      magicStart == MAGIC_COMPRESS_START ||
      magicStart == MAGIC_COMPRESS_START1) {
    cryptKeyLen = 4;
  } else if (magicStart == MAGIC_COMPRESS_START2 ||
      magicStart == MAGIC_NO_COMPRESS_START1 ||
      magicStart == MAGIC_NO_COMPRESS_NO_CRYPT_START ||
      magicStart == MAGIC_COMPRESS_NO_CRYPT_START ||
      magicStart == MAGIC_SYNC_ZSTD_START ||
      magicStart == MAGIC_SYNC_NO_CRYPT_ZSTD_START ||
      magicStart == MAGIC_ASYNC_ZSTD_START ||
      magicStart == MAGIC_ASYNC_NO_CRYPT_ZSTD_START) {
    cryptKeyLen = 64;
  } else {
    outBuffer.add(
      utf8.encode(
        'in decodeBuffer buffer[$offset]:$magicStart != MAGIC_NUM_START\n',
      ),
    );
    return -1;
  }

  final bufferView = ByteData.view(buffer.buffer, offset);
  final headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;
  final length = bufferView.getUint32(
    headerLen - 4 - cryptKeyLen,
    Endian.little,
  );

  final seq = bufferView.getUint16(
    headerLen - 4 - cryptKeyLen - 2 - 2,
    Endian.little,
  );

  if (seq != 0 && seq != 1 && lastSeq != 0 && seq != (lastSeq + 1)) {
    outBuffer.add(
      utf8.encode(
        "[F]decode_log_file.py log seq:${lastSeq + 1}-${seq - 1} is missing\n",
      ),
    );
  }

  if (seq != 0) {
    lastSeq = seq;
  }

  var tmpBuffer = buffer.sublist(
    offset + headerLen,
    offset + headerLen + length,
  );
  Uint8List decodedData;

  try {
    if (magicStart == MAGIC_NO_COMPRESS_START1 ||
        magicStart == MAGIC_COMPRESS_START2 ||
        magicStart == MAGIC_SYNC_ZSTD_START ||
        magicStart == MAGIC_ASYNC_ZSTD_START) {
      log('use wrong decode script');
    } else if (MAGIC_ASYNC_NO_CRYPT_ZSTD_START == magicStart) {
      final decompressed = zstd.decode(tmpBuffer);
      decodedData = Uint8List.fromList(zstd.decode(tmpBuffer));
    } else if ([
      MAGIC_COMPRESS_START,
      MAGIC_COMPRESS_NO_CRYPT_START,
    ].contains(magicStart)) {
      decodedData = Uint8List.fromList(zlib.decode(tmpBuffer));
    } else if (MAGIC_COMPRESS_START1 == magicStart) {
      // 解压逻辑
      Uint8List decompressData = Uint8List(0);
      int decompressOffset = 0;
      while (decompressOffset < tmpBuffer.length) {
        ByteData singleLogByteData = ByteData.view(
          tmpBuffer.buffer,
          tmpBuffer.offsetInBytes + decompressOffset,
        );
        int singleLogLen = singleLogByteData.getUint16(0, Endian.little);
        decompressData = Uint8List.fromList(
          decompressData +
              tmpBuffer.sublist(
                decompressOffset + 2,
                decompressOffset + 2 + singleLogLen,
              ),
        );
        decompressOffset += singleLogLen + 2;
      }
      decodedData = Uint8List.fromList(zlib.decode(decompressData));
    } else {
      decodedData = tmpBuffer; // 无压缩情况
    }
  } catch (e) {
    decodedData = utf8.encode('[F]decode_log_file.dart decompress err, $e\n');
  }

  return (offset + headerLen + length + 1, decodedData);
}

/// 解析文件，并将其解码内容写入新文件
Future<void> parseFile(String inputFile, String outputFile) async {
  lastSeq = 0;
  File file = File(inputFile);
  if (!await file.exists()) {
    print('文件不存在: $inputFile');
    return;
  }

  Uint8List buffer = await file.readAsBytes();
  int startPos = getLogStartPos(buffer, 2);
  if (startPos == -1) {
    print('在文件中找不到有效的日志记录');
    return;
  }

  List<int> outbuffer = [];
  int currentOffset = startPos;
  while (true) {
    var (nextOffset, decodedData) = decodeBuffer(buffer, currentOffset);
    if (nextOffset == -1) {
      break;
    }
    outbuffer.addAll(decodedData);
    currentOffset = nextOffset;
  }

  if (outbuffer.isEmpty) {
    return;
  }

  File outFile = File(outputFile);
  await outFile.writeAsBytes(outbuffer);
}

Future<void> main(List<String> args) async {
  if (args.length == 1) {
    String path = args[0];
    if (await Directory(path).exists()) {
      var dir = Directory(path);
      await for (var entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.xlog')) {
          await parseFile(entity.path, '${entity.path}.log');
        }
      }
    } else {
      await parseFile(path, '$path.log');
    }
  } else if (args.length == 2) {
    await parseFile(args[0], args[1]);
  } else {
    var dir = Directory.current;
    await for (var entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.xlog')) {
        await parseFile(entity.path, '${entity.path}.log');
      }
    }
  }
}
