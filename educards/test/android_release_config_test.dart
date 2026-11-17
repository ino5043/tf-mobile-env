import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 一般に配る Android 版の安全の設定が、うっかり外れないように確かめる。
void main() {
  final manifest =
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();

  test('release build can reach the AI APIs (INTERNET permission)', () {
    // debug と profile にしか無いと、配る版だけ AI が動かない
    expect(manifest,
        contains('<uses-permission android:name="android.permission.INTERNET"/>'));
  });

  test('app data and keys are left out of backups and device transfer', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();
    expect(rules, contains('<cloud-backup>'));
    expect(rules, contains('<device-transfer>'));
  });

  test('plain http is not allowed', () {
    expect(manifest, contains('android:usesCleartextTraffic="false"'));
    final config = File('android/app/src/main/res/xml/network_security_config.xml')
        .readAsStringSync();
    expect(config, contains('cleartextTrafficPermitted="false"'));
    expect(config, isNot(contains('src="user"')));
  });

  test('CI never signs a release with the debug key', () {
    expect(gradle, contains('isCi -> throw GradleException('));
    expect(gradle, contains('signingConfigs.getByName("release")'));
  });

  test('no signing key file is committed', () {
    final keys = Directory('android')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.jks') ||
            f.path.endsWith('.keystore') ||
            f.path.endsWith('key.properties'));
    expect(keys, isEmpty);
  });
}
