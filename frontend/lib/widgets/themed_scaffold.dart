import 'package:flutter/material.dart';

/// Tema uyumlu Scaffold widget'ı
/// Login, signup, splash ve verification sayfaları hariç tüm sayfalarda kullanılmalı
class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useCustomerBackground;

  const ThemedScaffold({
    super.key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonLocation,
    this.useCustomerBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? currentBody = body;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (useCustomerBackground && isLight) {
      currentBody = Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F5D1), // Pastel sarı-yeşil
              Color(0xFFBCE6C9), // Nane yeşili
            ],
          ),
        ),
        child: currentBody ?? const SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: (useCustomerBackground && isLight)
          ? const Color(0xFFF0F5D1)
          : (backgroundColor ?? Theme.of(context).scaffoldBackgroundColor),
      appBar: appBar,
      body: currentBody,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBody: (useCustomerBackground && isLight) ? true : extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Tema uyumlu AppBar widget'ı
class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? elevation;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ThemedAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.elevation,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor:
          foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor,
      elevation: elevation ?? 0,
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Tema uyumlu Container widget'ı
class ThemedContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;

  const ThemedContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      alignment: alignment,
      decoration:
          decoration ?? BoxDecoration(color: Theme.of(context).cardColor),
      child: child,
    );
  }
}

/// Tema uyumlu Card widget'ı
class ThemedCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ThemedCard({
    super.key,
    this.child,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: elevation ?? 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Tema uyumlu Text widget'ı
class ThemedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool useBodyColor;

  const ThemedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.useBodyColor = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = useBodyColor
        ? Theme.of(context).textTheme.bodyLarge?.color
        : null;

    return Text(
      text,
      style:
          style?.copyWith(color: style?.color ?? defaultColor) ??
          TextStyle(color: defaultColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
