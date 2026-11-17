import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 秘密の値（API キー）を置く場所。
abstract interface class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// 端末の安全な保管場所を使う実装。
///
/// - Android: Android Keystore の鍵で暗号化して保存する
/// - iOS: キーチェーン（この端末だけ・ロック解除後に読める）
/// - Web: ブラウザの WebCrypto で暗号化して保存する。ただし鍵も同じブラウザに
///   あるため、端末の保管場所ほど強くはない（ADR-005 に記録）
class SecureStorageSecretStore implements SecretStore {
  final FlutterSecureStorage _storage;

  SecureStorageSecretStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
