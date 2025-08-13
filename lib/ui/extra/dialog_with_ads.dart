import 'package:flutter/material.dart';
import '../../service/ads/admob_service.dart';
import 'custom_dialog.dart';

/// Wrapper function for showDialog with AdMob integration
Future<T?> showDialogWithAds<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) async {
  // Show ad before dialog
  await AdMobService().showAdBeforeDialog();
  
  // Small delay to ensure ad is properly dismissed before showing dialog
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Show the actual dialog
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}

/// Wrapper function for showCustomBottomSheet with AdMob integration
Future<T?> showCustomBottomSheetWithAds<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required String actionText,
  required Color actionColor,
  Future<void> Function()? onActionPressed,
  bool isDismissible = true,
}) async {
  // Show ad before bottom sheet
  await AdMobService().showAdBeforeDialog();
  
  // Small delay to ensure ad is properly dismissed before showing bottom sheet
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Show the actual bottom sheet
  return showCustomBottomSheet<T>(
    context: context,
    title: title,
    content: content,
    actionText: actionText,
    actionColor: actionColor,
    onActionPressed: onActionPressed,
    isDismissible: isDismissible,
  );
}

/// Wrapper function for showModalBottomSheet with AdMob integration
Future<T?> showModalBottomSheetWithAds<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) async {
  // Show ad before modal bottom sheet
  await AdMobService().showAdBeforeDialog();
  
  // Small delay to ensure ad is properly dismissed before showing modal
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Show the actual modal bottom sheet
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
  );
}

/// Helper class for easy AdMob dialog integration
class AdMobDialogs {
  /// Show a simple alert dialog with ad
  static Future<bool?> showAlertWithAd({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    Color? confirmColor,
  }) async {
    return showDialogWithAds<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Text(message),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog with ad
  static Future<bool?> showConfirmationWithAd({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
  }) async {
    return showDialogWithAds<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: cancelColor ?? Colors.grey[600],
            ),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog with ad (useful for long operations)
  static Future<void> showLoadingWithAd({
    required BuildContext context,
    String message = 'Loading...',
  }) async {
    return showDialogWithAds<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 20),
            Text(message),
          ],
        ),
      ),
    );
  }
}