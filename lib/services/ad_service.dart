// lib/services/ad_service.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart' as admob;
import 'package:huawei_ads/huawei_ads.dart' as hms;
import 'package:famous_faces/configs.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  admob.InterstitialAd? _admobInterstitial;
  hms.AdParam? _hmsAdParam;
  hms.InterstitialAd? _hmsInterstitial;
  bool _isLoading = false;
  AdNetwork? _activeNet;

  Future<void> initialize() async {
    switch (AdConfig.currentNetwork) {
      case AdNetwork.admob:
        await admob.MobileAds.instance.initialize();
        _activeNet = AdNetwork.admob;
        break;

      case AdNetwork.huawei:
        await hms.HwAds.init();
        _activeNet = AdNetwork.huawei;
        break;

      case AdNetwork.auto:
      // try GMS first, fallback to HMS
        try {
          await admob.MobileAds.instance.initialize();
          _activeNet = AdNetwork.admob;
        } catch (e) {
          await hms.HwAds.init();
          _activeNet = AdNetwork.huawei;
        }
        break;
    }
  }

  Future<void> loadAd() async {
    if (_isLoading) return;
    _isLoading = true;

    if (_activeNet == AdNetwork.huawei) {
      _hmsInterstitial = hms.InterstitialAd(
        adSlotId: AdConfig.huaweiInterstitialId,
      );
      _hmsAdParam = hms.AdParam();
      await _hmsInterstitial!.loadAd();
    } else {
      await admob.InterstitialAd.load(
        adUnitId: AdConfig.admobInterstitialId,
        request: const admob.AdRequest(),
        adLoadCallback: admob.InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _admobInterstitial = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
          },
        ),
      );
    }
    _isLoading = false;
  }

  void showAdIfAvailable() {
    if (_activeNet == AdNetwork.huawei) {
      if (_hmsInterstitial != null) {
        _hmsInterstitial!.show();
        loadAd(); // preload next
      } else {
        loadAd();
      }
      return;
    }

    if (_admobInterstitial != null) {
      _admobInterstitial!.fullScreenContentCallback =
          admob.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _admobInterstitial = null;
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _admobInterstitial = null;
              loadAd();
            },
          );
      _admobInterstitial!.show();
      _admobInterstitial = null;
    } else {
      loadAd();
    }
  }
}