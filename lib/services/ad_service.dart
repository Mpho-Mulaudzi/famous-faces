import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:famous_faces/configs.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  // remove any old ID constants — we use AdConfig instead

  Future<void> loadAd() async {
    if (_isLoading || _interstitialAd != null) return;
    _isLoading = true;

    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialId, // 👈 pulled from config
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            loadAd(); // preload next
          });

      _interstitialAd!.show(); // 👈 displays ad
      _interstitialAd = null;
    } else {
      loadAd();
    }
  }
}