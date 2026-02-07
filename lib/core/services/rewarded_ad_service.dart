import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  static const String _androidAdUnitId =
      'ca-app-pub-2106909509131304/9980592799';
  static const String _iosAdUnitId = 'ca-app-pub-2106909509131304/9980592799';

  static const String _testAndroidAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosAdUnitId =
      'ca-app-pub-3940256099942544/1712485313';

  String get _adUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testAndroidAdUnitId : _testIosAdUnitId;
    }
    return Platform.isAndroid ? _androidAdUnitId : _iosAdUnitId;
  }

  bool get isAdReady => _rewardedAd != null;

  bool get isLoading => _isLoading;

  void loadAd({VoidCallback? onAdLoaded, Function(String)? onAdFailedToLoad}) {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isLoading = false;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          onAdFailedToLoad?.call(error.message);
        },
      ),
    );
  }

  void showAd({
    required Function(int amount, String type) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    Function(String)? onAdFailedToShow,
  }) {
    if (_rewardedAd == null) {
      onAdFailedToShow?.call('Ad not ready');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow?.call(error.message);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
      },
      onAdImpression: (ad) {},
      onAdClicked: (ad) {},
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
        onUserEarnedReward(rewardItem.amount.toInt(), rewardItem.type);
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
