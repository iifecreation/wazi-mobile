import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

import '../api/api_client.dart';
import '../api/savings_api.dart';

const _goalColors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.teal];
const _goalIcon = Icons.savings_rounded;

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

  Future<int?> _promptAmount(String title, String actionLabel) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text(title, style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: WaziText.inter(size: 16, color: Colors.white),
          decoration: const InputDecoration(hintText: 'Amount in Naira', hintStyle: TextStyle(color: Colors.white38)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final naira = int.tryParse(controller.text.trim());
              Navigator.pop(context, naira != null ? naira * 100 : null);
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _promptNewGoal() async {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: WaziColors.card,
        title: Text('New savings goal', style: WaziText.grotesk(size: 18, weight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              autofocus: true,
              style: WaziText.inter(size: 16, color: Colors.white),
              decoration: const InputDecoration(hintText: 'Goal name (e.g. Vacation)', hintStyle: TextStyle(color: Colors.white38)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              style: WaziText.inter(size: 16, color: Colors.white),
              decoration: const InputDecoration(hintText: 'Target amount (optional)', hintStyle: TextStyle(color: Colors.white38)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, {'title': titleController.text.trim(), 'target': targetController.text.trim()}),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result == null || result['title']!.isEmpty) return;
    final userId = widget.appState.userId;
    if (userId == null) return;
    final targetNaira = int.tryParse(result['target'] ?? '');
    try {
      await widget.appState.savingsApi.createGoal(userId, result['title']!, targetMinor: targetNaira != null ? targetNaira * 100 : null);
      await _loadData();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not create goal')));
    }
  }

  Future<void> _depositInto(SavingsGoalOut goal) async {
    final amountMinor = await _promptAmount('Add to ${goal.title}', 'Save');
    if (amountMinor == null || amountMinor <= 0) return;
    final userId = widget.appState.userId;
    if (userId == null) return;
    try {
      await widget.appState.savingsApi.deposit(userId, amountMinor, goalId: goal.goalId);
      await widget.appState.refreshBalance();
      await _loadData();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
    }
  }

  Future<void> _withdrawFrom(SavingsGoalOut goal) async {
    final amountMinor = await _promptAmount('Withdraw from ${goal.title}', 'Withdraw');
    if (amountMinor == null || amountMinor <= 0) return;
    final userId = widget.appState.userId;
    if (userId == null) return;
    try {
      await widget.appState.savingsApi.withdraw(userId, amountMinor, goalId: goal.goalId);
      await widget.appState.refreshBalance();
      await _loadData();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.detail)));
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
                            Text(_data!.totalSavedFormatted, style: WaziText.grotesk(size: 32, weight: FontWeight.w600, color: WaziColors.gold)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Interest Earned: ', style: WaziText.inter(size: 12, color: Colors.white.withValues(alpha: 0.5))),
                                Text(_data!.interestEarnedFormatted, style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.green)),
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
                          GestureDetector(
                            onTap: _promptNewGoal,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('+ New', style: WaziText.inter(size: 12, weight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_data!.goals.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            "No savings goals yet — tap \"+ New\" to start one, or just say \"save 5000 naira\".",
                            style: WaziText.inter(size: 14, color: WaziColors.textAt(0.5)),
                          ),
                        ),
                      ..._data!.goals.asMap().entries.map((entry) {
                        final g = entry.value;
                        final color = _goalColors[entry.key % _goalColors.length];
                        return _buildGoalCard(goal: g, color: color, icon: _goalIcon);
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

  Widget _buildGoalCard({required SavingsGoalOut goal, required Color color, required IconData icon}) {
    final progress = goal.progress ?? 0.0;
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
                child: Text(goal.title, style: WaziText.inter(size: 16, weight: FontWeight.w600, color: Colors.white)),
              ),
              if (goal.targetMinor != null)
                Text('${(progress * 100).toInt()}%', style: WaziText.inter(size: 14, weight: FontWeight.w600, color: color)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: goal.targetMinor != null ? progress : null,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.savedFormatted, style: WaziText.inter(size: 14, weight: FontWeight.w500, color: Colors.white)),
              if (goal.targetFormatted != null)
                Text('of ${goal.targetFormatted}', style: WaziText.inter(size: 12, color: WaziColors.textAt(0.5))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _depositInto(goal),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: WaziColors.textAt(.14)), padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: Text('Add money', style: WaziText.inter(size: 13, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _withdrawFrom(goal),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: WaziColors.textAt(.14)), padding: const EdgeInsets.symmetric(vertical: 10)),
                  child: Text('Withdraw', style: WaziText.inter(size: 13, weight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
