import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/subscription_repository.dart';
import '../../models/user_subscription.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscriptionRepo = Provider.of<SubscriptionRepository>(context);
    final subscription = subscriptionRepo.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonelik Bilgilerim'),
      ),
      body: subscriptionRepo.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSubscriptionInfo(context, subscription),
    );
  }

  Widget _buildSubscriptionInfo(
      BuildContext context, UserSubscription subscription) {
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
                  const Text(
                    'Altyazı Yükleme Hakkınız',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kalan hakkınız: ${subscription.remainingUploads} / ${UserSubscription.maxSubtitleUploads}',
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
                    const Text(
                      'Altyazı yükleme hakkınız kalmadı. Daha fazla altyazı yüklemek için aboneliğinizi yenileyin.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Paketler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Temel Paket',
            description: '5 altyazı yükleme hakkı',
            price: '₺49.99',
            onTap: () => _purchaseSubscription(context, 5),
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Premium Paket',
            description: '15 altyazı yükleme hakkı',
            price: '₺129.99',
            onTap: () => _purchaseSubscription(context, 15),
            isRecommended: true,
          ),
          const SizedBox(height: 16),
          _buildSubscriptionCard(
            context,
            title: 'Pro Paket',
            description: '30 altyazı yükleme hakkı',
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
                        child: const Text('Satın Al'),
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
              child: const Text(
                'Önerilen',
                style: TextStyle(
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
    // Burada ödeme işlemi entegrasyonu yapılacak
    // Şimdilik sadece hak ekleyeceğiz

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Başarılı'),
        content: Text('$uploads altyazı yükleme hakkı satın aldınız.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Yükleme hakkı ekle
              Provider.of<SubscriptionRepository>(context, listen: false)
                  .addUploads(uploads);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
