import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:es_compression/zstd.dart';
import 'package:pointycastle/export.dart';

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

const String PRIV_KEY =
    "145aa7717bf9745b91e9569b80bbf1eedaa6cc6cd0e26317d810e35710f44cf8";
const String PUB_KEY =
    "572d1e2710ae5fbca54c76a382fdd44050b3a675cb2bf39feebe85ef63d947aff0fa4943f1112e8b6af34bebebbaefa1a0aae055d9259b89a1858f7cc9af9df1";

Uint8List teaDecipher(Uint8List v, Uint8List k) {
  const op = 0xFFFFFFFF;
  var v0 = ByteData.sublistView(v, 0, 4).getUint32(0, Endian.little);
  var v1 = ByteData.sublistView(v, 4, 8).getUint32(0, Endian.little);
  final k1 = ByteData.sublistView(k, 0, 4).getUint32(0, Endian.little);
  final k2 = ByteData.sublistView(k, 4, 8).getUint32(0, Endian.little);
  final k3 = ByteData.sublistView(k, 8, 12).getUint32(0, Endian.little);
  final k4 = ByteData.sublistView(k, 12, 16).getUint32(0, Endian.little);
  const delta = 0x9E3779B9;
  var s = (delta << 4) & op;
  for (int i = 0; i < 16; i++) {
    v1 = (v1 - (((v0 << 4) + k3) ^ (v0 + s) ^ ((v0 >> 5) + k4))) & op;
    v0 = (v0 - (((v1 << 4) + k1) ^ (v1 + s) ^ ((v1 >> 5) + k2))) & op;
    s = (s - delta) & op;
  }
  final result = ByteData(8);
  result.setUint32(0, v0, Endian.little);
  result.setUint32(4, v1, Endian.little);
  return result.buffer.asUint8List();
}

Uint8List teaDecrypt(Uint8List v, Uint8List k) {
  final num = v.length - (v.length % 8);
  final ret = BytesBuilder();
  for (int i = 0; i < num; i += 8) {
    final x = teaDecipher(v.sublist(i, i + 8), k);
    ret.add(x);
  }
  ret.add(v.sublist(num));
  return ret.toBytes();
}

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

  if (offset + headerLen + 1 + 1 > buffer.length) {
    return (false, 'offset:$offset > len(buffer):${buffer.length}');
  }
  final bufferView = ByteData.view(buffer.buffer);
  final length = bufferView.getUint32(
    offset + headerLen - 4 - cryptKeyLen,
    Endian.little,
  );
  if (offset + headerLen + length + 1 > buffer.length) {
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
    final fixPos = getLogStartPos(buffer.sublist(offset), 1);
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
  // final beginHour = dataView.getUint8(
  //   offset + headerLen - 4 - cryptKeyLen - 1 - 1,
  // );
  // final endHour = dataView.getUint8(offset + headerLen - 4 - cryptKeyLen - 1);

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

  try {
    if (magicStart == MAGIC_NO_COMPRESS_START1 ||
        magicStart == MAGIC_SYNC_ZSTD_START) {
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
      final decompressed = zlib.decode(tmpBuffer);
      tmpBuffer = Uint8List.fromList(decompressed);
    } else if (magicStart == MAGIC_COMPRESS_START1) {
      final decompressData = BytesBuilder();
      while (tmpBuffer.isNotEmpty) {
        final tmpView = ByteData.view(tmpBuffer.buffer);
        final singleLogLen = tmpView.getUint16(0, Endian.little);
        decompressData.add(tmpBuffer.sublist(2, singleLogLen + 2));
        tmpBuffer = tmpBuffer.sublist(singleLogLen + 2);
      }
      final decompressed = zlib.decode(decompressData.toBytes());
      tmpBuffer = Uint8List.fromList(decompressed);
    } else {}
  } catch (e) {
    outBuffer.add(utf8.encode("[F]decode_log_file.dart decompress err, $e\n"));
    return offset + headerLen + length + 1;
  }

  outBuffer.add(tmpBuffer);
  return offset + headerLen + length + 1;
}

void parseFile(String filePath, String outPath) {
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
}

void main(List<String> args) {
  if (args.length == 1) {
    final filePath = args[0];
    if (FileSystemEntity.isDirectorySync(filePath)) {
      final fileList = Directory(
        filePath,
      ).listSync().where((e) => e.path.endsWith('.xlog'));
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
    ).listSync().where((e) => e.path.endsWith('.xlog'));
    for (final file in fileList) {
      lastSeq = 0;
      parseFile(file.path, '${file.path}.log');
    }
  }
}
