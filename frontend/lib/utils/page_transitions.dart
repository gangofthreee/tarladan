import 'package:flutter/material.dart';

/// Sayfa geçiş animasyon türleri
enum TransitionType {
  fade,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
  scale,
  rotation,
  fadeScale,
}

/// Animasyonlu sayfa geçişi için özel PageRoute
class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;
  final Curve curve;

  AnimatedPageRoute({
    required this.page,
    this.transitionType = TransitionType.fadeScale,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
              type: transitionType,
              curve: curve,
            );
          },
        );

  static Widget _buildTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    required TransitionType type,
    required Curve curve,
  }) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: curvedAnimation, child: child);

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(opacity: curvedAnimation, child: child),
        );

      case TransitionType.fadeScale:
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

/// Navigator extension for easy animated navigation
extension NavigatorExtension on NavigatorState {
  /// Animasyonlu sayfa geçişi ile yeni sayfaya git
  Future<T?> pushAnimated<T>(
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return push<T>(AnimatedPageRoute<T>(
      page: page,
      transitionType: transition,
      duration: duration,
      curve: curve,
    ));
  }

  /// Animasyonlu sayfa geçişi ile sayfayı değiştir
  Future<T?> pushReplacementAnimated<T, TO>(
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return pushReplacement<T, TO>(AnimatedPageRoute<T>(
      page: page,
      transitionType: transition,
      duration: duration,
      curve: curve,
    ));
  }

  /// Tüm sayfaları temizleyip animasyonlu geçiş ile yeni sayfaya git
  Future<T?> pushAndRemoveAllAnimated<T>(
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return pushAndRemoveUntil<T>(
      AnimatedPageRoute<T>(
        page: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
      (route) => false,
    );
  }
}

/// Kolay kullanım için yardımcı fonksiyonlar
class AppNavigator {
  /// Animasyonlu sayfa geçişi
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(context).push<T>(AnimatedPageRoute<T>(
      page: page,
      transitionType: transition,
      duration: duration,
      curve: curve,
    ));
  }

  /// Animasyonlu sayfa değiştirme
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(AnimatedPageRoute<T>(
      page: page,
      transitionType: transition,
      duration: duration,
      curve: curve,
    ));
  }

  /// Tüm sayfaları temizle ve yeni sayfaya git
  static Future<T?> pushAndRemoveAll<T>(
    BuildContext context,
    Widget page, {
    TransitionType transition = TransitionType.fadeScale,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      AnimatedPageRoute<T>(
        page: page,
        transitionType: transition,
        duration: duration,
        curve: curve,
      ),
      (route) => false,
    );
  }

  /// Geri git
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// En üst sayfaya kadar geri git
  static void popUntilFirst(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
