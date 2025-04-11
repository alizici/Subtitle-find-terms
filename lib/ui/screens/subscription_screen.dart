import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart';
import '../../repositories/subscription_repository.dart';
import '../../models/user_subscription.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionRepo = Provider.of<SubscriptionRepository>(context);
    final subscription = subscriptionRepo.subscription;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
      ),
      body: subscriptionRepo.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSubscriptionInfo(context, subscription),
    );
  }

  Widget _buildSubscriptionInfo(
      BuildContext context, UserSubscription subscription) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subtitleUploadRights,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subtitleUploadsRemaining(subscription.remainingUploads,
                        UserSubscription.maxSubtitleUploads),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: subscription.remainingUploads /
                        UserSubscription.maxSubtitleUploads,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(
                      subscription.remainingUploads > 2
                          ? Colors.green
                          : subscription.remainingUploads > 0
                              ? Colors.orange
                              : Colors.red,
                    ),
                  ),
                  if (subscription.remainingUploads == 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.noUploadsRemaining,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.packages,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: l10n.basicPackage,
            description: l10n.subtitleUploads(5),
            price: '₺49.99',
            onTap: () => _purchaseSubscription(context, 5),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: l10n.premiumPackage,
            description: l10n.subtitleUploads(15),
            price: '₺129.99',
            onTap: () => _purchaseSubscription(context, 15),
            isRecommended: true,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: l10n.proPackage,
            description: l10n.subtitleUploads(30),
            price: '₺249.99',
            onTap: () => _purchaseSubscription(context, 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required String price,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isRecommended
                ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(description),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        child: Text(l10n.purchase),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isRecommended)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Text(
                l10n.recommended,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _purchaseSubscription(BuildContext context, int uploads) {
    final l10n = AppLocalizations.of(context)!;

    // Burada ödeme işlemi entegrasyonu yapılacak
    // Şimdilik sadece hak ekleyeceğiz

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.paymentSuccessful),
        content: Text(l10n.purchasedUploads(uploads)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Yükleme hakkı ekle
              Provider.of<SubscriptionRepository>(context, listen: false)
                  .addUploads(uploads);
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
