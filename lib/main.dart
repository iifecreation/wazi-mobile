import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_root.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: WaziColors.bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const WaziApp());
}

class WaziApp extends StatelessWidget {
  const WaziApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wazi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WaziColors.bg,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: WaziColors.gold,
          brightness: Brightness.dark,
          surface: WaziColors.bg,
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: WaziColors.gold),
      ),
      home: const AppRoot(),
    );
  }
}
