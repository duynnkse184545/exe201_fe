import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _dialogOpenCount = 0;
  static const int _adFrequency = 3; // Show ad every 3 dialog opens

  // Test Ad Unit IDs (replace with your real ones in production)
  static final String _testInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1510752918584749/9587829291' // Android test ID
      : 'ca-app-pub-1510752918584749/9432202037'; // iOS test ID

  // Production Ad Unit IDs (replace with your actual AdMob IDs)
  static final String _prodInterstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-1510752918584749/9587829291'
      : 'ca-app-pub-1510752918584749/9432202037';

  // Get the appropriate ad unit ID based on build mode
  String get _interstitialAdUnitId {
    return kDebugMode ? _testInterstitialAdUnitId : _prodInterstitialAdUnitId;
  }

  /// Initialize AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    
    // Set request configuration for testing
    if (kDebugMode) {
      final configuration = RequestConfiguration(
        testDeviceIds: ['0003ddac-94d9-4f36-88fc-d4a2827160a8'], // Add your test device ID
      );
      MobileAds.instance.updateRequestConfiguration(configuration);
    }
  }

  /// Load interstitial ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          
          _interstitialAd!.setImmersiveMode(true);
          
          // Set up ad event callbacks
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              if (kDebugMode) print('Interstitial ad showed full screen content.');
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              if (kDebugMode) print('Interstitial ad dismissed.');
              ad.dispose();
              _isInterstitialAdReady = false;
              _interstitialAd = null;
              // Preload next ad
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              if (kDebugMode) print('Interstitial ad failed to show: $error');
              ad.dispose();
              _isInterstitialAdReady = false;
              _interstitialAd = null;
              // Preload next ad
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) print('Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Show interstitial ad before dialog
  Future<bool> showAdBeforeDialog() async {
    _dialogOpenCount++;
    
    // Show ad every _adFrequency dialog opens
    if (_dialogOpenCount % _adFrequency == 0) {
      if (_isInterstitialAdReady && _interstitialAd != null) {
        try {
          await _interstitialAd!.show();
          return true; // Ad was shown
        } catch (e) {
          if (kDebugMode) print('Error showing interstitial ad: $e');
          return false;
        }
      } else {
        // Ad not ready, load one for next time
        _loadInterstitialAd();
        return false;
      }
    }
    
    return false; // No ad shown
  }

  /// Preload ads (call this when app starts)
  void preloadAds() {
    _loadInterstitialAd();
  }

  /// Dispose of ads
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }

  /// Reset dialog count (useful for testing)
  void resetDialogCount() {
    _dialogOpenCount = 0;
  }

  /// Get current dialog count (for debugging)
  int get dialogCount => _dialogOpenCount;

  /// Check if ad is ready
  bool get isAdReady => _isInterstitialAdReady;
}