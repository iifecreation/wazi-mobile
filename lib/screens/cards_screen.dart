import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../api/cards_api.dart';
import '../widgets/bottom_nav.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  bool _loading = true;
  String? _error;
  List<CardOut> _cards = [];
  List<CardTransactionOut> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = widget.appState.userId;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final cardsRes = await widget.appState.cardsApi.getCards(userId);
      final txsRes = await widget.appState.cardsApi.getCardActivity(userId);
      if (!mounted) return;
      setState(() {
        _cards = cardsRes.cards;
        _transactions = txsRes.transactions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load card data';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: WaziBottomNav(appState: widget.appState),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text('Cards', style: WaziText.grotesk(size: 24, weight: FontWeight.w600, color: Colors.white)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: WaziColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('+ Add Card', style: WaziText.inter(size: 13, weight: FontWeight.w600, color: WaziColors.gold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Physical/Virtual Tabs
                    Row(
                      children: [
                        _buildTab(title: 'Virtual Card', active: true),
                        const SizedBox(width: 12),
                        _buildTab(title: 'Physical Card', active: false),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                      _cards.isEmpty
                          ? Center(child: Text('No cards found', style: WaziText.inter(size: 14, color: Colors.white54)))
                          : Container(
                              width: double.infinity,
                              height: 220,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2A2D34), Color(0xFF141518)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_cards.first.name, style: WaziText.grotesk(size: 18, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1)),
                                      Icon(Icons.contactless_outlined, color: Colors.white.withValues(alpha: 0.7)),
                                    ],
                                  ),
                                  Text('**** **** **** ${_cards.first.last4}', style: WaziText.grotesk(size: 24, weight: FontWeight.w500, color: Colors.white, letterSpacing: 2)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Cardholder', style: WaziText.inter(size: 10, color: Colors.white.withValues(alpha: 0.5))),
                                          const SizedBox(height: 4),
                                          Text(_cards.first.cardholder, style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Expires', style: WaziText.inter(size: 10, color: Colors.white.withValues(alpha: 0.5))),
                                          const SizedBox(height: 4),
                                          Text(_cards.first.expires, style: WaziText.inter(size: 14, weight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
                                        ],
                                      ),
                                      Text(_cards.first.brand, style: WaziText.grotesk(size: 24, weight: FontWeight.w800, color: Colors.white).copyWith(fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionButton(icon: Icons.visibility_off_outlined, label: 'Details'),
                        _buildActionButton(icon: Icons.ac_unit_rounded, label: 'Freeze'),
                        _buildActionButton(icon: Icons.tune_rounded, label: 'Limits'),
                        _buildActionButton(icon: Icons.settings_outlined, label: 'Settings'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Card Activity
                    Text('Card Activity', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                    const SizedBox(height: 16),
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    else if (_transactions.isEmpty)
                      Center(child: Text('No recent activity', style: WaziText.inter(size: 14, color: Colors.white54)))
                    else
                      ..._transactions.map((tx) {
                        IconData icon;
                        if (tx.icon == 'movie_outlined') icon = Icons.movie_outlined;
                        else if (tx.icon == 'local_taxi_outlined') icon = Icons.local_taxi_outlined;
                        else if (tx.icon == 'coffee_outlined') icon = Icons.coffee_outlined;
                        else icon = Icons.receipt_long_outlined;
                        
                        return _buildTransaction(
                          title: tx.title,
                          date: tx.date,
                          amount: tx.amount,
                          icon: icon,
                        );
                      }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required bool active}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: WaziText.inter(
              size: 14,
              weight: active ? FontWeight.w600 : FontWeight.w500,
              color: active ? Colors.white : WaziColors.textAt(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.7), weight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildTransaction({required String title, required String date, required String amount, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(date, style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
              ],
            ),
          ),
          Text(amount, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
