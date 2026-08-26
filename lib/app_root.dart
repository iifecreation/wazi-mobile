import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/typing_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'state/models.dart';
import 'theme/colors.dart';
import 'widgets/sheets/confirm_sheet.dart';
import 'widgets/sheets/notif_sheet.dart';
import 'widgets/sheets/pin_sheet.dart';
import 'widgets/sheets/privacy_sheet.dart';
import 'widgets/sheets/success_sheet.dart';
import 'widgets/sheets/support_sheet.dart';

/// Owns the single AppState for the whole app and renders it: one screen
/// active at a time (no Navigator — matches the design's own state-flag
/// model, see the implementation plan), with sheets as a Stack overlay on
/// top rather than a modal route.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    _appState.addListener(_onStateChanged);
  }

  void _onStateChanged() => setState(() {});

  @override
  void dispose() {
    _appState.removeListener(_onStateChanged);
    _appState.dispose();
    super.dispose();
  }

  /// Each screen's own explicit back-button target, mirroring the design's
  /// onClick handlers (e.g. auth's "←" goes to welcome). Screens with no
  /// explicit back affordance in the design (splash/onboarding/welcome/home)
  /// fall through to normal system back behavior.
  bool get _canPopDirectly =>
      _appState.sheet == null &&
      !{AppScreen.auth, AppScreen.login, AppScreen.insights, AppScreen.settings, AppScreen.scan, AppScreen.typing}
          .contains(_appState.screen);

  void _handleBack() {
    if (_appState.sheet != null) {
      _appState.dismiss();
      return;
    }
    switch (_appState.screen) {
      case AppScreen.auth:
      case AppScreen.login:
        _appState.go(AppScreen.welcome);
      case AppScreen.insights:
      case AppScreen.settings:
      case AppScreen.scan:
      case AppScreen.typing:
        _appState.go(AppScreen.home);
      default:
        break;
    }
  }

  Widget _buildScreen() {
    switch (_appState.screen) {
      case AppScreen.splash:
        return SplashScreen(key: const ValueKey('splash'), appState: _appState);
      case AppScreen.onboarding:
        return OnboardingScreen(key: const ValueKey('onboarding'), appState: _appState);
      case AppScreen.welcome:
        return WelcomeScreen(key: const ValueKey('welcome'), appState: _appState);
      case AppScreen.auth:
        return AuthScreen(key: const ValueKey('auth'), appState: _appState);
      case AppScreen.login:
        return LoginScreen(key: const ValueKey('login'), appState: _appState);
      case AppScreen.home:
        return HomeScreen(key: const ValueKey('home'), appState: _appState);
      case AppScreen.insights:
        return InsightsScreen(key: const ValueKey('insights'), appState: _appState);
      case AppScreen.settings:
        return SettingsScreen(key: const ValueKey('settings'), appState: _appState);
      case AppScreen.typing:
        return TypingScreen(key: const ValueKey('typing'), appState: _appState);
      case AppScreen.scan:
        return ScanScreen(key: const ValueKey('scan'), appState: _appState);
    }
  }

  Widget? _buildSheet() {
    switch (_appState.sheet) {
      case SheetType.confirm:
        return ConfirmSheet(appState: _appState);
      case SheetType.pin:
        return PinSheet(appState: _appState);
      case SheetType.privacy:
        return PrivacySheet(appState: _appState);
      case SheetType.success:
        return SuccessSheet(appState: _appState);
      case SheetType.notif:
        return NotifSheet(appState: _appState);
      case SheetType.support:
        return SupportSheet(appState: _appState);
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sheetContent = _buildSheet();
    return PopScope(
      canPop: _canPopDirectly,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: WaziColors.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: _buildScreen(),
              ),
            ),
            IgnorePointer(
              ignoring: sheetContent == null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: sheetContent == null ? 0 : 1,
                child: GestureDetector(
                  onTap: _appState.dismiss,
                  child: Container(color: const Color(0xB8040610)),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              left: 0,
              right: 0,
              bottom: sheetContent == null ? -400 : 0,
              child: sheetContent ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
