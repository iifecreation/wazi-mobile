enum AppScreen {
  splash,
  onboarding,
  voiceWelcome,
  welcome,
  auth,
  login,
  dashboard,
  notifications,
  notificationDetails,
  home,
  insights,
  settings,
  scan,
  services,
  cards,
  finance,
  sendMoney,
  international,
  requestMoney,
  airtime,
  payBills,
  electricity,
  cableTv,
  savings,
  fixedDeposits,
  eventTickets,
  flights,
  hotels,
  appSettings,
  transactionHistory,
  accountLimits,
  bankCards,
  bizPayment,
  oJunior,
  customerService,
  invitation,
  ussd,
  rateUs,
  myProfile,
  paymentSettings,
  loginSettings,
  savingsSettings,
  homepageSettings,
  securityQuestions,
  smsAlertSettings,
  clipboardSettings,
  themesSettings,
  securityCenter,
  feedback,
  closeAccount,
  aboutSettings,
  deviceManagement,
}

enum SheetType { confirm, pin, privacy, success, support, bvn_input, nin_input, password_input, transaction_pin_input }

enum ChatRole { user, ai }

enum BankTab { bank, chat }

class ChatTurn {
  const ChatTurn({required this.role, required this.text, this.speaking = false});

  final ChatRole role;
  final String text;
  final bool speaking;
}
