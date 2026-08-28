import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key, required this.appState});

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
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Colors.white54, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search by name, reference or amount',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(title: 'All', isSelected: true),
                  _FilterChip(title: 'Money In'),
                  _FilterChip(title: 'Money Out'),
                  _FilterChip(title: 'Transfers'),
                  _FilterChip(title: 'Bills'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _MonthSection(month: 'August 2026', moneyIn: '₦ 150,000.00', moneyOut: '₦ 45,200.00'),
                  _TransactionTile(
                    title: 'John Doe',
                    subtitle: 'Aug 28, 14:22 • Bank Transfer',
                    amount: '+₦ 10,000.00',
                    isCredit: true,
                    status: 'Success',
                    icon: Icons.arrow_downward_rounded,
                  ),
                  _TransactionTile(
                    title: 'MTN Airtime',
                    subtitle: 'Aug 27, 09:15 • Airtime',
                    amount: '-₦ 2,000.00',
                    isCredit: false,
                    status: 'Success',
                    icon: Icons.phone_android_rounded,
                  ),
                  _TransactionTile(
                    title: 'Jane Smith',
                    subtitle: 'Aug 25, 18:45 • Wazi Transfer',
                    amount: '-₦ 15,000.00',
                    isCredit: false,
                    status: 'Failed',
                    icon: Icons.arrow_upward_rounded,
                    isFailed: true,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _MonthSection(month: 'July 2026', moneyIn: '₦ 450,000.00', moneyOut: '₦ 380,500.00'),
                  _TransactionTile(
                    title: 'Salary Deposit',
                    subtitle: 'Jul 31, 08:00 • Bank Transfer',
                    amount: '+₦ 400,000.00',
                    isCredit: true,
                    status: 'Success',
                    icon: Icons.business_rounded,
                  ),
                  _TransactionTile(
                    title: 'IKEDC Prepaid',
                    subtitle: 'Jul 28, 11:30 • Electricity',
                    amount: '-₦ 20,000.00',
                    isCredit: false,
                    status: 'Success',
                    icon: Icons.lightbulb_outline_rounded,
                  ),
                  _TransactionTile(
                    title: 'Supermarket POS',
                    subtitle: 'Jul 25, 16:20 • Card Payment',
                    amount: '-₦ 34,500.00',
                    isCredit: false,
                    status: 'Success',
                    icon: Icons.credit_card_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.title, this.isSelected = false});

  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.greenAccent : Colors.transparent,
          width: 1,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.greenAccent : Colors.white,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _MonthSection extends StatelessWidget {
  const _MonthSection({required this.month, required this.moneyIn, required this.moneyOut});
  
  final String month;
  final String moneyIn;
  final String moneyOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            month,
            style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white),
          ),
          Text(
            'In: $moneyIn   Out: $moneyOut',
            style: WaziText.inter(size: 11, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.status,
    required this.icon,
    this.isFailed = false,
  });

  final String title;
  final String subtitle;
  final String amount;
  final bool isCredit;
  final String status;
  final IconData icon;
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCredit ? Colors.greenAccent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCredit ? Colors.greenAccent : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: WaziText.inter(size: 15, weight: FontWeight.w600, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: WaziText.inter(size: 12, color: Colors.white54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: WaziText.inter(
                  size: 15, 
                  weight: FontWeight.w700, 
                  color: isCredit ? Colors.greenAccent : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: WaziText.inter(
                  size: 11, 
                  color: isFailed ? Colors.redAccent : (status == 'Success' ? Colors.white54 : WaziColors.gold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
