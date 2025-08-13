// log_decoder.dart
// 这是一个将 Python 2 日志解码器转换为 Dart 的脚本。
// 它依赖于 archive, pointycastle, zstd_dart 和 path 包。

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:es_compression/zstd.dart';
import 'package:archive/archive.dart';
import 'package:pointycastle/export.dart';

// 魔数常量，用于标识日志缓冲区的类型
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

// TEA 解密密钥
const String PRIV_KEY =
    "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8";
const String PUB_KEY =
    "572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1";

/// Tiny Encryption Algorithm (TEA) 解密函数，用于解密 8 字节的数据块
Uint8List teaDecipher(Uint8List v, Uint8List k) {
  final v0 = ByteData.sublistView(v, 0, 4).getUint32(0, Endian.little);
  final v1 = ByteData.sublistView(v, 4, 8).getUint32(0, Endian.little);
  final k1 = ByteData.sublistView(k, 0, 4).getUint32(0, Endian.little);
  final k2 = ByteData.sublistView(k, 4, 8).getUint32(0, Endian.little);
  final k3 = ByteData.sublistView(k, 8, 12).getUint32(0, Endian.little);
  final k4 = ByteData.sublistView(k, 12, 16).getUint32(0, Endian.little);

  const int delta = 0x9E3779B9;
  var s = (delta * 16) & 0xFFFFFFFF;

  var currentV0 = v0;
  var currentV1 = v1;

  for (int i = 0; i < 16; i++) {
    currentV1 =
        (currentV1 -
            (((currentV0 << 4) + k3) ^
                (currentV0 + s) ^
                ((currentV0 >> 5) + k4))) &
        0xFFFFFFFF;
    currentV0 =
        (currentV0 -
            (((currentV1 << 4) + k1) ^
                (currentV1 + s) ^
                ((currentV1 >> 5) + k2))) &
        0xFFFFFFFF;
    s = (s - delta) & 0xFFFFFFFF;
  }

  final result = ByteData(8);
  result.setUint32(0, currentV0, Endian.little);
  result.setUint32(4, currentV1, Endian.little);

  return result.buffer.asUint8List();
}

/// 使用 TEA 算法解密整个字节列表
Uint8List teaDecrypt(Uint8List v, Uint8List k) {
  final num = v.length - (v.length % 8);
  final ret = BytesBuilder();
  for (int i = 0; i < num; i += 8) {
    ret.add(teaDecipher(v.sublist(i, i + 8), k));
  }
  ret.add(v.sublist(num));
  return ret.toBytes();
}

/// 验证给定的日志缓冲区是否有效
(bool, String) isGoodLogBuffer(Uint8List buffer, int offset, int count) {
  if (offset >= buffer.length) return (true, '');

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

  if (offset + headerLen + 1 > buffer.length) {
    return (false, 'offset:$offset > len(buffer):${buffer.length}');
  }

  final length = ByteData.sublistView(
    buffer,
    offset + headerLen - 4 - cryptKeyLen,
    4,
  ).getUint32(0, Endian.little);

  if (offset + headerLen + length >= buffer.length) {
    return (
      false,
      'log length:$length, end pos ${offset + headerLen + length} > len(buffer):${buffer.length}',
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

/// 查找日志缓冲区开始的有效位置
int getLogStartPos(Uint8List buffer, int count) {
  int offset = 0;
  while (offset < buffer.length) {
    final magicStart = buffer[offset];
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
      final result = isGoodLogBuffer(buffer, offset, count);
      if (result.$1) {
        return offset;
      }
    }
    offset++;
  }
  return -1;
}

/// 解码单个日志缓冲区
int decodeBuffer(Uint8List buffer, int offset, BytesBuilder outBuffer) {
  if (offset >= buffer.length) return -1;
  final result = isGoodLogBuffer(buffer, offset, 1);
  if (!result.$1) {
    final fixPos = getLogStartPos(buffer.sublist(offset), 1);
    if (fixPos == -1) {
      return -1;
    } else {
      outBuffer.add(
        utf8.encode(
          "[F]decode_log_file.dart decode error len=$fixPos, result:${result.$2}\n",
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
  } else {
    cryptKeyLen = 64;
  }

  final headerLen = 1 + 2 + 1 + 1 + 4 + cryptKeyLen;
  final dataView = ByteData.sublistView(buffer);
  final length = dataView.getUint32(
    offset + headerLen - 4 - cryptKeyLen,
    Endian.little,
  );
  Uint8List tmpBuffer = buffer.sublist(
    offset + headerLen,
    offset + headerLen + length,
  );

  final seq = dataView.getUint16(
    offset + headerLen - 4 - cryptKeyLen - 2 - 2,
    Endian.little,
  );
  final beginHour = dataView.getUint8(
    offset + headerLen - 4 - cryptKeyLen - 1 - 1,
  );
  final endHour = dataView.getUint8(offset + headerLen - 4 - cryptKeyLen - 1);

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

  try {
    if (magicStart == MAGIC_NO_COMPRESS_START1 ||
        magicStart == MAGIC_SYNC_ZSTD_START) {
      // 无需处理
    } else if (magicStart == MAGIC_COMPRESS_START2 ||
        magicStart == MAGIC_ASYNC_ZSTD_START) {
      // ECC 协商密钥
      final ecDomain = ECDomainParameters('secp256k1');
      final clientPubKeyX = tmpBuffer.sublist(0, 32);
      final clientPubKeyY = tmpBuffer.sublist(32, 64);

      final privateKey = ECPrivateKey(
        BigInt.parse(PRIV_KEY, radix: 16),
        ecDomain,
      );
      final clientPoint = ecDomain.curve.createPoint(
        BigInt.parse(base64UrlEncode(clientPubKeyX), radix: 16),
        BigInt.parse(base64UrlEncode(clientPubKeyY), radix: 16),
      );
      final sharedSecret = privateKey.d! * clientPoint.x!.toBigInteger()!;
      final teaKey = sharedSecret
          .toRadixString(16)
          .padLeft(32, '0')
          .substring(0, 32);
      final teaKeyBytes = hex.decode(teaKey);

      tmpBuffer = teaDecrypt(
        tmpBuffer.sublist(64),
        Uint8List.fromList(teaKeyBytes),
      );

      if (magicStart == MAGIC_COMPRESS_START2) {
        final decompressed = zlib.decode(tmpBuffer);
        tmpBuffer = Uint8List.fromList(decompressed);
      } else {
        final decompressed = zstd.decode(tmpBuffer);
        tmpBuffer = Uint8List.fromList(decompressed);
      }
    } else if (magicStart == MAGIC_ASYNC_NO_CRYPT_ZSTD_START) {
      final decompressed = zstd.decode(tmpBuffer);
      tmpBuffer = Uint8List.fromList(decompressed);
    } else if (magicStart == MAGIC_COMPRESS_START ||
        magicStart == MAGIC_COMPRESS_NO_CRYPT_START) {
      final decompressed = ZLibDecoder().decodeBytes(tmpBuffer);
      tmpBuffer = Uint8List.fromList(decompressed);
    } else if (magicStart == MAGIC_COMPRESS_START1) {
      final decompressData = BytesBuilder();
      int currentOffset = 0;
      while (currentOffset < tmpBuffer.length) {
        final singleLogLen = ByteData.sublistView(
          tmpBuffer,
          currentOffset,
          2,
        ).getUint16(0, Endian.little);
        decompressData.add(
          tmpBuffer.sublist(
            currentOffset + 2,
            currentOffset + 2 + singleLogLen,
          ),
        );
        currentOffset += singleLogLen + 2;
      }
      final decompressed = ZLibDecoder().decodeBytes(decompressData.toBytes());
      tmpBuffer = Uint8List.fromList(decompressed);
    }
  } on Exception catch (e) {
    outBuffer.add(utf8.encode("[F]decode_log_file.dart decompress err, $e\n"));
    return offset + headerLen + length + 1;
  }

  outBuffer.add(tmpBuffer);
  return offset + headerLen + length + 1;
}

/// 解析单个文件
void parseFile(String filePath, String outPath) {
  try {
    final buffer = File(filePath).readAsBytesSync();
    final startPos = getLogStartPos(buffer, 2);
    if (startPos == -1) {
      return;
    }

    final outBuffer = BytesBuilder();
    int currentPos = startPos;

    while (true) {
      final newPos = decodeBuffer(buffer, currentPos, outBuffer);
      if (newPos == -1) break;
      currentPos = newPos;
    }

    if (outBuffer.length == 0) return;

    File(outPath).writeAsBytesSync(outBuffer.toBytes());
  } on FileSystemException catch (e) {
    print('Error processing file $filePath: $e');
  }
}

// 主函数，处理命令行参数
void main(List<String> args) {
  lastSeq = 0;
  if (args.length == 1) {
    final filePath = args[0];
    if (FileSystemEntity.isDirectorySync(filePath)) {
      final fileList = Directory(
        filePath,
      ).listSync().where((f) => f.path.endsWith('.xlog'));
      for (final file in fileList) {
        lastSeq = 0;
        parseFile(file.path, '${file.path}.log');
      }
    } else {
      parseFile(filePath, '$filePath.log');
    }
  } else if (args.length == 2) {
    parseFile(args[0], args[1]);
  } else {
    final fileList = Directory(
      '.',
    ).listSync().where((f) => f.path.endsWith('.xlog'));
    for (final file in fileList) {
      lastSeq = 0;
      parseFile(file.path, '${file.path}.log');
    }
  }
}
