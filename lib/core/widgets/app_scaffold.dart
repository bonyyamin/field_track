import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';

/// AppScaffold wraps main screen content with the persistent BottomNavBar.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final String currentPath;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool showBottomNav;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentPath,
    this.appBar,
    this.floatingActionButton,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(currentPath: currentPath)
          : null,
    );
  }
}