// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:famous_faces/configs.dart';
// class BannerAdWidget extends StatefulWidget {
//   const BannerAdWidget({super.key});
//
//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }
//
// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   BannerAd? _banner;
//   bool _isLoaded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _banner = BannerAd(
//       size: AdSize.banner,
//       adUnitId: AdConfig.bannerId,
//       listener: BannerAdListener(
//         onAdLoaded: (_) => setState(() => _isLoaded = true),
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           debugPrint('Banner failed to load: $error');
//         },
//       ),
//       request: const AdRequest(),
//     )..load();
//   }
//
//   @override
//   void dispose() {
//     _banner?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded) return const SizedBox(height: 0);
//     return Container(
//       alignment: Alignment.center,
//       width: _banner!.size.width.toDouble(),
//       height: _banner!.size.height.toDouble(),
//       child: AdWidget(ad: _banner!),
//     );
//   }
// }