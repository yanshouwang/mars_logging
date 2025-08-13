import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';

import 'package:es_compression/zstd.dart';

const int MAGIC_NO_COMPRESS_START = 0x03;
const int MAGIC_NO_COMPRESS_START1 = 0x06;
const int MAGIC_NO_COMPRESS_NO_CRYPT_START = 0x08;
const int MAGIC_COMPRESS_START = 0x04;
const int MAGIC_COMPRESS_START1 = 0x05;
const int MAGIC_COMPRESS_START2 = 0x07;
const int MAGIC_COMPRESS_NO_CRYPT_START = 0x09;

const int MAGIC_SYNC_ZSTD_START = 0x0A;
const int MAGIC_SYNC_NO_CRYPT_ZSTD_START = 0x0B;
const int MAGIC_ASYNC_ZSTD_START = 0x0C;
const int MAGIC_ASYNC_NO_CRYPT_ZSTD_START = 0x0D;

const int MAGIC_END = 0x00;

int lastSeq = 0;

/// 检查缓冲区中从指定偏移量开始的日志记录是否有效
(bool, String) isGoodLogBuffer(Uint8List buffer, int offset, int count) {
  if (offset == buffer.length) {
    return (true, '');
  }

  int magicStart = buffer[offset];
  int cryptKeyLen;

  if ([
    MAGIC_NO_COMPRESS_START,
    MAGIC_COMPRESS_START,
    MAGIC_COMPRESS_START1,
  ].contains(magicStart)) {
    cryptKeyLen = 4;
  } else if ([
    MAGIC_COMPRESS_START2,
    MAGIC_NO_COMPRESS_START1,
    MAGIC_NO_COMPRESS_NO_CRYPT_START,
    MAGIC_COMPRESS_NO_CRYPT_START,
    MAGIC_SYNC_ZSTD_START,
    MAGIC_SYNC_NO_CRYPT_ZSTD_START,
    MAGIC_ASYNC_ZSTD_START,
    MAGIC_ASYNC_NO_CRYPT_ZSTD_START,
  ].contains(magicStart)) {
    cryptKeyLen = 64;
  } else {
    return (false, 'buffer[$offset]:$magicStart != MAGIC_NUM_START');
  }

  int headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;
  if (offset + headerLen + 1 > buffer.length) {
    return (false, 'offset:$offset > buffer.length:${buffer.length}');
  }

  ByteData byteData = ByteData.view(buffer.buffer);
  int length = byteData.getUint32(
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

/// 找到缓冲区中第一个有效的日志记录的起始位置
int getLogStartPos(Uint8List buffer, int count) {
  for (int offset = 0; offset < buffer.length; offset++) {
    int magicStart = buffer[offset];
    if ([
      MAGIC_NO_COMPRESS_START,
      MAGIC_NO_COMPRESS_START1,
      MAGIC_COMPRESS_START,
      MAGIC_COMPRESS_START1,
      MAGIC_COMPRESS_START2,
      MAGIC_COMPRESS_NO_CRYPT_START,
      MAGIC_NO_COMPRESS_NO_CRYPT_START,
      MAGIC_SYNC_ZSTD_START,
      MAGIC_SYNC_NO_CRYPT_ZSTD_START,
      MAGIC_ASYNC_ZSTD_START,
      MAGIC_ASYNC_NO_CRYPT_ZSTD_START,
    ].contains(magicStart)) {
      var (isGood, _) = isGoodLogBuffer(buffer, offset, count);
      if (isGood) {
        return offset;
      }
    }
  }
  return -1;
}

/// 解码单个日志记录
(int, Uint8List) decodeBuffer(Uint8List buffer, int offset) {
  if (offset >= buffer.length) {
    return (-1, Uint8List(0));
  }

  var (isGood, errorMsg) = isGoodLogBuffer(buffer, offset, 1);
  if (!isGood) {
    int fixpos = getLogStartPos(buffer.sublist(offset), 1);
    if (fixpos == -1) {
      return (
        -1,
        utf8.encode(
          '[F]decode_log_file.dart decode error len=${buffer.length - offset}, result:$errorMsg \n',
        ),
      );
    } else {
      return (
        offset + fixpos,
        utf8.encode(
          '[F]decode_log_file.dart decode error len=$fixpos, result:$errorMsg \n',
        ),
      );
    }
  }

  int magicStart = buffer[offset];
  int cryptKeyLen;
  if ([
    MAGIC_NO_COMPRESS_START,
    MAGIC_COMPRESS_START,
    MAGIC_COMPRESS_START1,
  ].contains(magicStart)) {
    cryptKeyLen = 4;
  } else if ([
    MAGIC_COMPRESS_START2,
    MAGIC_NO_COMPRESS_START1,
    MAGIC_NO_COMPRESS_NO_CRYPT_START,
    MAGIC_COMPRESS_NO_CRYPT_START,
    MAGIC_SYNC_ZSTD_START,
    MAGIC_SYNC_NO_CRYPT_ZSTD_START,
    MAGIC_ASYNC_ZSTD_START,
    MAGIC_ASYNC_NO_CRYPT_ZSTD_START,
  ].contains(magicStart)) {
    cryptKeyLen = 64;
  } else {
    return (
      -1,
      utf8.encode(
        'in decodeBuffer buffer[$offset]:$magicStart != MAGIC_NUM_START\n',
      ),
    );
  }

  int headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;
  ByteData byteData = ByteData.view(buffer.buffer, offset);
  int length = byteData.getUint32(headerLen - 4 - cryptKeyLen, Endian.little);
  int seq = byteData.getUint16(headerLen - 4 - cryptKeyLen - 2, Endian.little);

  if (seq != 0 && seq != 1 && lastSeq != 0 && seq != (lastSeq + 1)) {
    String msg =
        '[F]decode_log_file.py log seq:${lastSeq + 1}-${seq - 1} is missing\n';
    // 如果发生序列号跳跃，这里可以处理并返回错误信息
  }

  if (seq != 0) {
    lastSeq = seq;
  }

  Uint8List logData = buffer.sublist(
    offset + headerLen,
    offset + headerLen + length,
  );
  Uint8List decodedData;

  try {
    if ([
      MAGIC_NO_COMPRESS_START1,
      MAGIC_COMPRESS_START2,
      MAGIC_SYNC_ZSTD_START,
      MAGIC_ASYNC_ZSTD_START,
    ].contains(magicStart)) {
      decodedData = utf8.encode("use wrong decode script\n");
    } else if (MAGIC_ASYNC_NO_CRYPT_ZSTD_START == magicStart) {
      decodedData = Uint8List.fromList(zstd.decode(logData));
    } else if ([
      MAGIC_COMPRESS_START,
      MAGIC_COMPRESS_NO_CRYPT_START,
    ].contains(magicStart)) {
      decodedData = Uint8List.fromList(zlib.decode(logData));
    } else if (MAGIC_COMPRESS_START1 == magicStart) {
      // 解压逻辑
      Uint8List decompressData = Uint8List(0);
      int decompressOffset = 0;
      while (decompressOffset < logData.length) {
        ByteData singleLogByteData = ByteData.view(
          logData.buffer,
          logData.offsetInBytes + decompressOffset,
        );
        int singleLogLen = singleLogByteData.getUint16(0, Endian.little);
        decompressData = Uint8List.fromList(
          decompressData +
              logData.sublist(
                decompressOffset + 2,
                decompressOffset + 2 + singleLogLen,
              ),
        );
        decompressOffset += singleLogLen + 2;
      }
      decodedData = Uint8List.fromList(zlib.decode(decompressData));
    } else {
      decodedData = logData; // 无压缩情况
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
