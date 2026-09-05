import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/models.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/payment_picker_form.dart';

class CableTvScreen extends StatelessWidget {
  const CableTvScreen({super.key, required this.appState});

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
                  Text('Cable TV', style: WaziText.grotesk(size: 20, weight: FontWeight.w600, letterSpacing: -0.2)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: PaymentPickerForm(
                  appState: appState,
                  pickerLabel: 'Provider',
                  loadOptions: () async {
                    final providers = await appState.institutionsApi.listInstitutions(category: 'cable_tv');
                    return providers.map((p) => PickerOption(id: p.institutionId, label: p.name)).toList();
                  },
                  onSubmit: (name, amountMinor) => appState.initiateInstitutionPayment(name, amountMinor),
                  submitLabel: 'Pay Subscription',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
