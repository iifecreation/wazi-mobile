import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

import '../api/savings_api.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  bool _loading = true;
  String? _error;
  SavingsResponse? _data;

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
      final res = await widget.appState.savingsApi.getSavings(userId);
      if (!mounted) return;
      setState(() {
        _data = res;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load savings data';
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => widget.appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Savings Goals', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    else if (_data != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: WaziColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: WaziColors.gold.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Total Savings', style: WaziText.inter(size: 14, color: WaziColors.gold.withValues(alpha: 0.8))),
                            const SizedBox(height: 8),
                            Text(_data!.totalSavings, style: WaziText.grotesk(size: 32, weight: FontWeight.w600, color: WaziColors.gold)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Interest Earned: ', style: WaziText.inter(size: 12, color: Colors.white.withValues(alpha: 0.5))),
                                Text(_data!.interestEarned, style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your Goals', style: WaziText.grotesk(size: 16, weight: FontWeight.w600, color: WaziColors.textAt(0.7))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text('+ New', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.white)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._data!.goals.map((g) {
                        Color color;
                        if (g.color == 'blue') color = Colors.blue;
                        else if (g.color == 'orange') color = Colors.orange;
                        else if (g.color == 'purple') color = Colors.purple;
                        else color = Colors.green;

                        IconData icon;
                        if (g.icon == 'shield_rounded') icon = Icons.shield_rounded;
                        else if (g.icon == 'flight_takeoff_rounded') icon = Icons.flight_takeoff_rounded;
                        else if (g.icon == 'laptop_mac_rounded') icon = Icons.laptop_mac_rounded;
                        else icon = Icons.star_rounded;

                        return _buildGoalCard(
                          title: g.title,
                          current: g.current,
                          target: g.target,
                          progress: g.progress,
                          color: color,
                          icon: icon,
                        );
                      }),
                    ],
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

  Widget _buildGoalCard({
    required String title,
    required String current,
    required String target,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              ),
              Text('${(progress * 100).toInt()}%', style: WaziText.inter(size: 14, weight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(current, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
              Text('of $target', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            ],
          ),
        ],
      ),
    );
  }
}
