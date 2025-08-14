import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/src/utils.dart' as utils;

void main() {
  // Use the secp256k1 curve, which is the same as in the Python code
  final curve = ECCurve_secp256k1();

  // Generate a new key pair
  final keyGen = ECKeyGenerator();
  final random = math.Random.secure();
  final seedValue = List.generate(32, (e) => random.nextInt(256));
  final seed = Uint8List.fromList(seedValue);
  final seedParam = KeyParameter(seed);
  final keyGenParams = ParametersWithRandom(
    ECKeyGeneratorParameters(curve),
    FortunaRandom()..seed(seedParam),
  );
  keyGen.init(keyGenParams);
  final keyPair = keyGen.generateKeyPair();

  // Extract the private and public keys
  final privKey = keyPair.privateKey;
  final pubKey = keyPair.publicKey;

  // Print the private key in hex format
  log("save private key");
  log(hex.encode(utils.encodeBigInt(privKey.d!)));

  // Print the public key components (x and y) in hex format
  log("\nappender_open's parameter:");
  final pubKeyX = utils.encodeBigInt(pubKey.Q!.x!.toBigInteger());
  final pubKeyY = utils.encodeBigInt(pubKey.Q!.y!.toBigInteger());
  log("${hex.encode(pubKeyX)}${hex.encode(pubKeyY)}");
}
