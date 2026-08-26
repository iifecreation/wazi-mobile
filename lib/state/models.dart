enum AppScreen {
  splash,
  onboarding,
  welcome,
  auth,
  login,
  home,
  insights,
  settings,
  typing,
  scan,
}

enum SheetType { confirm, pin, privacy, success, notif, support }

enum ChatRole { user, ai }

enum BankTab { bank, chat }

class ChatTurn {
  const ChatTurn({required this.role, required this.text, this.speaking = false});

  final ChatRole role;
  final String text;
  final bool speaking;
}
