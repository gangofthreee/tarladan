import 'package:flutter/material.dart';

class UserBaseScreen extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;

  const UserBaseScreen({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBodyBehindAppBar: true, // Arkaplan gradient'ının appbar arkasına taşması için
        appBar: appBar,
        body: Container(
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
          child: SafeArea(
            child: child,
          ),
        ),
      ),
    );
  }
}
