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
  final privateKey = keyPair.privateKey;
  final publicKey = keyPair.publicKey;

  // Print the private key in hex format
  print("save private key");
  print(hex.encode(utils.encodeBigInt(privateKey.d!)));

  // Print the public key components (x and y) in hex format
  print("\nappender_open's parameter:");
  final publicKeyX = utils.encodeBigInt(publicKey.Q!.x!.toBigInteger());
  final publicKeyY = utils.encodeBigInt(publicKey.Q!.y!.toBigInteger());
  print("${hex.encode(publicKeyX)}${hex.encode(publicKeyY)}");
}
