import 'package:flutter/material.dart';

import '../../api/wallets_api.dart';
import '../../state/app_state.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'sheet_common.dart';

const _currencyLabels = {
  'USD': 'US Dollar',
  'GBP': 'British Pound',
  'EUR': 'Euro',
};
const _currencySymbols = {'USD': '\$', 'GBP': '£', 'EUR': '€'};

class AddWalletSheet extends StatelessWidget {
  const AddWalletSheet({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final openCurrencies = appState.wallets.map((w) => w.currency).toSet();
    final available = WalletsApi.supportedCurrencies
        .where((c) => !openCurrencies.contains(c))
        .toList();

    return SheetContainer(
      accent: WaziColors.gold.withValues(alpha: .4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Open a new wallet',
            style: WaziText.grotesk(size: 21, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Naira account stays your default. A wallet holds a balance in another currency, ready for diaspora transfers or international spend.',
            style: WaziText.inter(
              size: 13.5,
              color: WaziColors.textAt(.55),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          if (appState.walletError != null) ...[
            Text(
              appState.walletError!,
              style: WaziText.inter(size: 13, color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
          ],
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "You already have a wallet in every currency Wazi supports right now.",
                style: WaziText.inter(size: 14, color: WaziColors.textAt(.6)),
              ),
            )
          else
            ...available.map(
              (currency) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: appState.walletBusy
                        ? null
                        : () => appState.createWallet(currency),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: WaziColors.textAt(.14)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: WaziColors.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _currencySymbols[currency] ?? currency,
                            style: WaziText.grotesk(
                              size: 16,
                              weight: FontWeight.w600,
                              color: WaziColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '${_currencyLabels[currency] ?? currency} ($currency)',
                            style: WaziText.inter(
                              size: 15,
                              weight: FontWeight.w500,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (appState.walletBusy)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white38,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: appState.walletBusy ? null : appState.dismiss,
              child: Text(
                'Not now',
                style: WaziText.inter(size: 13.5, color: WaziColors.textAt(.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
