import 'package:example/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'home_screen.dart';

// Route observer for visibility tracking
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PlatformInAppWebViewController.debugLoggingSettings.enabled = false;

  runApp(const VhPlyrDemoApp());
}

class VhPlyrDemoApp extends StatelessWidget {
  const VhPlyrDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomeScreen(),
      navigatorObservers: [routeObserver],
    );
  }
}
