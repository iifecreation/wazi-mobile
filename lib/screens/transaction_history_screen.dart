import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../api/accounts_api.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TransactionHistoryResponse? _response;
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = widget.appState.userId;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final res = await widget.appState.accountsApi.getTransactions(userId);
      if (!mounted) return;
      setState(() {
        _response = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load transactions';
        _loading = false;
      });
    }
  }

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
                    onPressed: () => widget.appState.go(AppScreen.settings),
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
                  GestureDetector(onTap: () => setState(() => _filter = 'All'), child: _FilterChip(title: 'All', isSelected: _filter == 'All')),
                  GestureDetector(onTap: () => setState(() => _filter = 'Money In'), child: _FilterChip(title: 'Money In', isSelected: _filter == 'Money In')),
                  GestureDetector(onTap: () => setState(() => _filter = 'Money Out'), child: _FilterChip(title: 'Money Out', isSelected: _filter == 'Money Out')),
                  GestureDetector(onTap: () => setState(() => _filter = 'Transfers'), child: _FilterChip(title: 'Transfers', isSelected: _filter == 'Transfers')),
                  GestureDetector(onTap: () => setState(() => _filter = 'Bills'), child: _FilterChip(title: 'Bills', isSelected: _filter == 'Bills')),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Transactions List
            Expanded(
              child: _loading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                  ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                  : _buildTransactionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final txs = _response?.transactions ?? [];
    if (txs.isEmpty) {
      return Center(
        child: Text('No transactions found', style: WaziText.inter(size: 14, color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        final isCredit = tx.direction == 'in';
        IconData icon = isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
        if (tx.category == 'airtime') icon = Icons.phone_android_rounded;
        if (tx.category == 'electricity') icon = Icons.lightbulb_outline_rounded;
        
        return _TransactionTile(
          title: tx.counterparty.isEmpty ? tx.description : tx.counterparty,
          subtitle: '${tx.occurredAt.month}/${tx.occurredAt.day} • ${tx.category}',
          amount: '${isCredit ? '+' : '-'}${tx.amountFormatted}',
          isCredit: isCredit,
          status: 'Success', // Mocked as the API doesn't return status yet
          icon: icon,
        );
      },
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
