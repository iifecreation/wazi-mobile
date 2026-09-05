import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/payment_picker_form.dart';

/// "International Transfer" — no real FX/remittance rail exists in this
/// backend (every wallet here is an isolated fake balance, there's no
/// currency conversion or cross-border payout). What *is* real and
/// already built is exactly what this screen's original differentiator
/// concept was actually describing — "diaspora direct-to-obligation
/// payments": someone abroad pays a bill back home directly, in Naira,
/// instead of wiring cash to a person who then has to hand it over. So
/// this screen is that: pick a verified institution, pay it in Naira.
class InternationalScreen extends StatelessWidget {
  const InternationalScreen({super.key, required this.appState});

  final AppState appState;

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
                    onTap: () => appState.go(AppScreen.services),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: WaziColors.text),
                  ),
                  const SizedBox(width: 16),
                  Text('Pay a Bill Back Home', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: PaymentPickerForm(
                  appState: appState,
                  pickerLabel: 'Institution',
                  infoBanner: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pay a school, hospital, or utility bill back home directly, in Naira — no separate FX transfer, no handing cash to someone else.',
                            style: WaziText.inter(size: 12, color: Colors.blue.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loadOptions: () async {
                    final all = await appState.institutionsApi.listInstitutions();
                    final obligations = all.where((i) => i.category != 'telecom').toList();
                    return obligations.map((i) => PickerOption(id: i.institutionId, label: i.name, subtitle: i.obligationLabel)).toList();
                  },
                  onSubmit: (name, amountMinor) => appState.initiateInstitutionPayment(name, amountMinor),
                  submitLabel: 'Pay Now',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
