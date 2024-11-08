// lib/config/env_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureConfig {
  static final _storage = FlutterSecureStorage();
  static const String _keyPrefix = 'SECURE_CONFIG_';

  // Encryption key should be stored securely and rotated periodically
  static final _key = encrypt.Key.fromSecureRandom(32);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  static final _iv = encrypt.IV.fromSecureRandom(16);

  static Future<void> initialize() async {
    try {
      // Try to load .env file
      bool loaded = false;

      // Try multiple possible locations
      final List<String> possiblePaths = [
        '.env',
      ];

      for (final path in possiblePaths) {
        try {
          await dotenv.dotenv.load(fileName: path);
          print('Successfully loaded .env from: $path');
          loaded = true;
          break;
        } catch (e) {
          print('Could not load .env from: $path');
          continue;
        }
      }

      if (!loaded) {
        throw Exception(
            'Could not find .env file in any of the expected locations');
      }

      // Check if .env values exist
      final smtpEmail = dotenv.dotenv.env['SMTP_EMAIL'];
      final smtpPassword = dotenv.dotenv.env['SMTP_PASSWORD'];

      if (smtpEmail == null || smtpPassword == null) {
        throw Exception('SMTP credentials not found in .env file');
      }

      print('Found credentials in .env file');

      // Store encrypted credentials
      await _encryptAndStore('SMTP_EMAIL', smtpEmail);
      await _encryptAndStore('SMTP_PASSWORD', smtpPassword);

      // Verify storage
      final testEmail = await getSecureValue('SMTP_EMAIL');
      if (testEmail == null) {
        throw Exception('Failed to verify stored credentials');
      }

      print('SecureConfig initialization completed successfully');
    } catch (e) {
      print('SecureConfig initialization failed: $e');
      rethrow;
    }
  }

  static Future<void> _encryptAndStore(String key, String value) async {
    final encrypted = _encrypter.encrypt(value, iv: _iv);
    await _storage.write(
      key: '$_keyPrefix$key',
      value: encrypted.base64,
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    );
  }

  static Future<String?> getSecureValue(String key) async {
    final encrypted = await _storage.read(
      key: '$_keyPrefix$key',
      aOptions: const AndroidOptions(encryptedSharedPreferences: true),
      iOptions: const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    );

    if (encrypted == null) return null;

    final decrypted = _encrypter.decrypt64(encrypted, iv: _iv);
    return decrypted;
  }
}
