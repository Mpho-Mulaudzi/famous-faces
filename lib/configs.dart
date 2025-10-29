// lib/config.dart
import 'dart:io';

class AdConfig {
  // Default: Google (AdMob)
  static const String admobInterstitialId = 'ca-app-pub-6722748206860300/3676878980';
  static const String admobBannerId = 'ca-app-pub-6722748206860300/7269860829';

  // Huawei test IDs
  static const String huaweiAppId = 'testw6vs28auh3';
  static const String huaweiInterstitialId = 'testb4znbuh3n2';
  static const String huaweiBannerId = 'testw6vs28auh3';

  /// Detect preferred ad network — you can later make this configurable.
  static AdNetwork get currentNetwork {
    if (Platform.isAndroid) {
      // simplistic detection; you can refine with package_info_plus to check installOrigin
      // For now, let's choose Huawei if device lacks Google Play Services.
      return AdNetwork.auto;
    }
    return AdNetwork.admob;
  }
}

enum AdNetwork { admob, huawei, auto }