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
  typing,
  scan,
  services,
  cards,
  finance,
}

enum SheetType { confirm, pin, privacy, success, support, bvn_input, nin_input }

enum ChatRole { user, ai }

enum BankTab { bank, chat }

class ChatTurn {
  const ChatTurn({required this.role, required this.text, this.speaking = false});

  final ChatRole role;
  final String text;
  final bool speaking;
}
