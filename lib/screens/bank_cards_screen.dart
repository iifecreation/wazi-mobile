import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class BankCardsScreen extends StatelessWidget {
  const BankCardsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaziColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => appState.go(AppScreen.settings),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Bank Cards/Account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20), // Balance the back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Accounts Section
                    Text(
                      'Bank Accounts',
                      style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _AccountTile(
                            bankName: 'Access Bank',
                            accountName: 'JOHN DOE',
                            accountNumber: '**** 5678',
                            iconData: Icons.account_balance_rounded,
                          ),
                          _AccountTile(
                            bankName: 'Guaranty Trust Bank',
                            accountName: 'JOHN DOE',
                            accountNumber: '**** 1234',
                            iconData: Icons.account_balance_rounded,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Add New Account Button
                    _AddButton(
                      title: 'Add New Account',
                      icon: Icons.add_circle_outline_rounded,
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),

                    // Bank Cards Section
                    Text(
                      'Bank Cards',
                      style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _CardTile(
                            cardType: 'Mastercard',
                            cardNumber: '**** **** **** 8899',
                            expiry: '12/28',
                            iconData: Icons.credit_card_rounded,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Add New Card Button
                    _AddButton(
                      title: 'Add New Card',
                      icon: Icons.add_card_rounded,
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Security Info
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.security_rounded, size: 16, color: Colors.greenAccent),
                          const SizedBox(width: 8),
                          Text(
                            'Your data is protected and secured',
                            style: WaziText.inter(size: 12, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.iconData,
    this.isLast = false,
  });

  final String bankName;
  final String accountName;
  final String accountNumber;
  final IconData iconData;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankName,
                  style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      accountNumber,
                      style: WaziText.inter(size: 13, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      accountName,
                      style: WaziText.inter(size: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    required this.cardType,
    required this.cardNumber,
    required this.expiry,
    required this.iconData,
    this.isLast = false,
  });

  final String cardType;
  final String cardNumber;
  final String expiry;
  final IconData iconData;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: Colors.greenAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardType,
                  style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      cardNumber,
                      style: WaziText.inter(size: 13, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Exp: $expiry',
                      style: WaziText.inter(size: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.more_vert_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
