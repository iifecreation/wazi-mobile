import 'package:flutter/material.dart';

import 'screens/about_settings_screen.dart';
import 'screens/account_limits_screen.dart';
import 'screens/airtime_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/bank_cards_screen.dart';
import 'screens/biz_payment_screen.dart';
import 'screens/cable_tv_screen.dart';
import 'screens/cards_screen.dart';
import 'screens/clipboard_settings_screen.dart';
import 'screens/close_account_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/device_management_screen.dart';
import 'screens/electricity_screen.dart';
import 'screens/event_tickets_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/fixed_deposits_screen.dart';
import 'screens/flights_screen.dart';

import 'screens/homepage_settings_screen.dart';
import 'screens/hotels_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/international_screen.dart';
import 'screens/login_screen.dart';
import 'screens/login_settings_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/notification_details_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/ojunior_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pay_bills_screen.dart';
import 'screens/payment_settings_screen.dart';
import 'screens/placeholder_screen.dart';
import 'screens/request_money_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/savings_settings_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/security_center_screen.dart';
import 'screens/security_questions_screen.dart';
import 'screens/send_money_screen.dart';
import 'screens/services_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/sms_alert_settings_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/themes_settings_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/voice_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'state/models.dart';
import 'theme/colors.dart';
import 'widgets/sheets/confirm_sheet.dart';
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
  /// explicit back affordance in the design (splash/onboarding/welcome/dashboard)
  /// fall through to normal system back behavior.
  bool get _canPopDirectly =>
      _appState.sheet == null &&
      !{AppScreen.auth, AppScreen.login, AppScreen.insights, AppScreen.settings, AppScreen.scan, AppScreen.home, AppScreen.notifications, AppScreen.notificationDetails, AppScreen.services}
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
      case AppScreen.home:
      case AppScreen.insights:
      case AppScreen.settings:
      case AppScreen.scan:
      case AppScreen.notifications:
      case AppScreen.services:
      case AppScreen.cards:
      case AppScreen.finance:
        _appState.go(AppScreen.dashboard);
      case AppScreen.sendMoney:
      case AppScreen.international:
      case AppScreen.requestMoney:
      case AppScreen.airtime:
      case AppScreen.payBills:
      case AppScreen.electricity:
      case AppScreen.cableTv:
      case AppScreen.savings:
      case AppScreen.fixedDeposits:
      case AppScreen.eventTickets:
      case AppScreen.flights:
      case AppScreen.hotels:
        _appState.go(AppScreen.services);
      case AppScreen.notificationDetails:
        _appState.go(AppScreen.notifications);
      case AppScreen.appSettings:
      case AppScreen.transactionHistory:
      case AppScreen.accountLimits:
      case AppScreen.bankCards:
      case AppScreen.bizPayment:
      case AppScreen.oJunior:
      case AppScreen.customerService:
      case AppScreen.invitation:
      case AppScreen.ussd:
      case AppScreen.rateUs:
        _appState.go(AppScreen.settings);
      case AppScreen.myProfile:
      case AppScreen.paymentSettings:
      case AppScreen.loginSettings:
      case AppScreen.savingsSettings:
      case AppScreen.homepageSettings:
      case AppScreen.securityQuestions:
      case AppScreen.smsAlertSettings:
      case AppScreen.clipboardSettings:
      case AppScreen.themesSettings:
      case AppScreen.securityCenter:
      case AppScreen.feedback:
      case AppScreen.closeAccount:
      case AppScreen.aboutSettings:
        _appState.go(AppScreen.appSettings);
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
      case AppScreen.dashboard:
        return DashboardScreen(key: const ValueKey('dashboard'), appState: _appState);
      case AppScreen.notifications:
        return NotificationsScreen(key: const ValueKey('notifications'), appState: _appState);
      case AppScreen.notificationDetails:
        return NotificationDetailsScreen(key: const ValueKey('notificationDetails'), appState: _appState);
      case AppScreen.services:
        return ServicesScreen(key: const ValueKey('services'), appState: _appState);
      case AppScreen.home:
      case AppScreen.voiceWelcome:
        return VoiceScreen(key: const ValueKey('voice'), appState: _appState);
      case AppScreen.insights:
        return InsightsScreen(key: const ValueKey('insights'), appState: _appState);
      case AppScreen.settings:
        return SettingsScreen(key: const ValueKey('settings'), appState: _appState);
      case AppScreen.scan:
        return ScanScreen(key: const ValueKey('scan'), appState: _appState);
      case AppScreen.cards:
        return CardsScreen(key: const ValueKey('cards'), appState: _appState);
      case AppScreen.finance:
        return FinanceScreen(key: const ValueKey('finance'), appState: _appState);
      case AppScreen.sendMoney:
        return SendMoneyScreen(key: const ValueKey('sendMoney'), appState: _appState);
      case AppScreen.international:
        return InternationalScreen(key: const ValueKey('international'), appState: _appState);
      case AppScreen.requestMoney:
        return RequestMoneyScreen(key: const ValueKey('requestMoney'), appState: _appState);
      case AppScreen.airtime:
        return AirtimeScreen(key: const ValueKey('airtime'), appState: _appState);
      case AppScreen.payBills:
        return PayBillsScreen(key: const ValueKey('payBills'), appState: _appState);
      case AppScreen.electricity:
        return ElectricityScreen(key: const ValueKey('electricity'), appState: _appState);
      case AppScreen.cableTv:
        return CableTvScreen(key: const ValueKey('cableTv'), appState: _appState);
      case AppScreen.savings:
        return SavingsScreen(key: const ValueKey('savings'), appState: _appState);
      case AppScreen.fixedDeposits:
        return FixedDepositsScreen(key: const ValueKey('fixedDeposits'), appState: _appState);
      case AppScreen.eventTickets:
        return EventTicketsScreen(key: const ValueKey('eventTickets'), appState: _appState);
      case AppScreen.flights:
        return FlightsScreen(key: const ValueKey('flights'), appState: _appState);
      case AppScreen.hotels:
        return HotelsScreen(key: const ValueKey('hotels'), appState: _appState);
      case AppScreen.appSettings:
        return AppSettingsScreen(key: const ValueKey('appSettings'), appState: _appState);
      case AppScreen.transactionHistory:
        return TransactionHistoryScreen(key: const ValueKey('transactionHistory'), appState: _appState);
      case AppScreen.accountLimits:
        return AccountLimitsScreen(key: const ValueKey('accountLimits'), appState: _appState);
      case AppScreen.bankCards:
        return BankCardsScreen(key: const ValueKey('bankCards'), appState: _appState);
      case AppScreen.bizPayment:
        return BizPaymentScreen(key: const ValueKey('bizPayment'), appState: _appState);
      case AppScreen.oJunior:
        return OJuniorScreen(key: const ValueKey('oJunior'), appState: _appState);
      case AppScreen.customerService:
        return PlaceholderScreen(key: const ValueKey('customerService'), appState: _appState, title: 'Customer Service', backScreen: AppScreen.settings);
      case AppScreen.invitation:
        return PlaceholderScreen(key: const ValueKey('invitation'), appState: _appState, title: 'Invitation', backScreen: AppScreen.settings);
      case AppScreen.ussd:
        return PlaceholderScreen(key: const ValueKey('ussd'), appState: _appState, title: 'Wazi USSD', backScreen: AppScreen.settings);
      case AppScreen.rateUs:
      case AppScreen.aboutSettings:
        return AboutSettingsScreen(key: const ValueKey('aboutSettings'), appState: _appState);
      case AppScreen.myProfile:
        return MyProfileScreen(key: const ValueKey('myProfile'), appState: _appState);
      case AppScreen.paymentSettings:
        return PaymentSettingsScreen(key: const ValueKey('paymentSettings'), appState: _appState);
      case AppScreen.loginSettings:
        return LoginSettingsScreen(key: const ValueKey('loginSettings'), appState: _appState);
      case AppScreen.savingsSettings:
        return SavingsSettingsScreen(key: const ValueKey('savingsSettings'), appState: _appState);
      case AppScreen.homepageSettings:
        return HomepageSettingsScreen(key: const ValueKey('homepageSettings'), appState: _appState);
      case AppScreen.securityQuestions:
        return SecurityQuestionsScreen(key: const ValueKey('securityQuestions'), appState: _appState);
      case AppScreen.smsAlertSettings:
        return SmsAlertSettingsScreen(key: const ValueKey('smsAlertSettings'), appState: _appState);
      case AppScreen.clipboardSettings:
        return ClipboardSettingsScreen(key: const ValueKey('clipboardSettings'), appState: _appState);
      case AppScreen.themesSettings:
        return ThemesSettingsScreen(key: const ValueKey('themesSettings'), appState: _appState);
      case AppScreen.securityCenter:
        return SecurityCenterScreen(key: const ValueKey('securityCenter'), appState: _appState);
      case AppScreen.deviceManagement:
        return DeviceManagementScreen(key: const ValueKey('deviceManagement'), appState: _appState);
      case AppScreen.feedback:
        return FeedbackScreen(key: const ValueKey('feedback'), appState: _appState);
      case AppScreen.closeAccount:
        return CloseAccountScreen(key: const ValueKey('closeAccount'), appState: _appState);
      default:
        return const SizedBox.shrink();
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
      case SheetType.support:
        return SupportSheet(appState: _appState);
      case SheetType.bvn_input:
      case SheetType.nin_input:
      case SheetType.password_input:
      case SheetType.transaction_pin_input:
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
