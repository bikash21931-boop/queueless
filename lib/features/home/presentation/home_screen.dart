import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../scanner/presentation/scanner_screen.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../history/presentation/history_screen.dart';
import '../../account/presentation/account_screen.dart';
import '../../membership/presentation/membership_screen.dart';
import '../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentIndex;
  String selectedStoreId = 'dmart';
  String selectedStoreName = 'Dmart';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _updateStore(String newId, String newName) {
    setState(() {
      selectedStoreId = newId;
      selectedStoreName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        _HomeDashboardContent(
          storeName: selectedStoreName,
          onStorePickerTriggered: _updateStore,
        ),
        ScannerScreen(
          storeId: selectedStoreId,
          onBack: () => setState(() => _currentIndex = 0),
          onCartNavigate: () => setState(() => _currentIndex = 2),
        ),
        const CartScreen(),
      ][_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade600,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeDashboardContent extends ConsumerWidget {
  final String storeName;
  final Function(String, String) onStorePickerTriggered;

  const _HomeDashboardContent({
    required this.storeName,
    required this.onStorePickerTriggered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(
          Icons.storefront_rounded,
          color: AppColors.primary,
          size: 28,
        ),
        title: GestureDetector(
          onTap: () => _showStorePicker(context, onStorePickerTriggered),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.black87),
                ],
              ),
              const Text(
                'Jp Road, Bhimavaram, AP',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                // Coin Pill
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MembershipScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${ref.watch(authProvider).user?.coins ?? 0}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // My Account Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountScreen()),
                    );
                  },
                  icon: const Icon(Icons.person, color: AppColors.primary),
                  label: const Text(
                    'My Acc',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skip the lines and shop at your own pace.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            Text(
              'How it Works',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _AnimatedScaleWidget(
              delay: 0,
              child: _buildInstructionCard(
                context,
                step: '1',
                title: 'Scan Next to Shelf',
                description:
                    'Use the Scan tab below to scan product barcodes as you add them to your basket.',
                icon: Icons.qr_code_scanner_rounded,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedScaleWidget(
              delay: 1,
              child: _buildInstructionCard(
                context,
                step: '2',
                title: 'Review My Cart',
                description:
                    'Tap the Cart tab to review your scanned items, adjust quantities, or remove things.',
                icon: Icons.shopping_cart_outlined,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 12),
            _AnimatedScaleWidget(
              delay: 2,
              child: _buildInstructionCard(
                context,
                step: '3',
                title: 'Tap to Checkout',
                description:
                    'Pay securely from your phone and present your digital receipt at the exit gate.',
                icon: Icons.payment_outlined,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _AnimatedScaleWidget(
              delay: 3,
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      context,
                      title: 'Digital Receipts',
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.primary,
                      bgColor: Colors.white,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step $step: $title',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStorePicker(
    BuildContext context,
    Function(String, String) onStoreSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select Store',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.store, color: AppColors.primary),
                title: const Text('Dmart'),
                subtitle: const Text('Jp Road, Bhimavaram, AP'),
                onTap: () {
                  onStoreSelected('dmart', 'Dmart');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: const Text('Zudio Fashion'),
                subtitle: const Text('SRKR Marg, Bhimavaram, AP'),
                onTap: () {
                  onStoreSelected('zudio', 'Zudio Fashion');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScaleWidget extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedScaleWidget({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
