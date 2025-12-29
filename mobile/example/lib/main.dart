import 'package:example/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'demo_page.dart';

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
      home: const DemoPage(),
    );
  }
}
