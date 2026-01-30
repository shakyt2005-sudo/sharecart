import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/colors.dart';
import '../core/mock_data.dart';
import '../widgets/item_card.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/subscription_popup.dart';
import 'category_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).setCurrentPage('home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // Custom App Bar with Search
                    SliverPersistentHeader(
                      floating: true,
                      delegate: _HomeHeaderDelegate(),
                    ),
                    
                    // Categories with Images
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16, left: 16, bottom: 8),
                        child: Text(
                          "Browse Categories",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: MockData.categories.length,
                          itemBuilder: (context, index) {
                            final category = MockData.categories[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetailScreen(category: category),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          category.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: AppColors.primaryLight,
                                              child: Center(
                                                child: Text(
                                                  category.icon,
                                                  style: const TextStyle(fontSize: 32),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      category.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: (50 * index).ms).slideX(),
                            );
                          },
                        ),
                      ),
                    ),

                    // Best Sellers Section
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20, left: 16, bottom: 12),
                        child: Row(
                          children: [
                            Icon(Icons.emoji_events, color: AppColors.gold, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Best Sellers",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: MockData.bestSellers.length,
                          itemBuilder: (context, index) {
                            final vendor = MockData.bestSellers[index];
                            return Container(
                              width: 200,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            vendor.shopName[0],
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    vendor.shopName,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (vendor.isVerified)
                                                  const Icon(Icons.verified, color: AppColors.verified, size: 14),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.star, color: AppColors.gold, size: 12),
                                                const SizedBox(width: 2),
                                                Text('${vendor.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          vendor.location,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${vendor.totalSales} successful trades',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: (100 * index).ms);
                          },
                        ),
                      ),
                    ),

                    // Nearby Sellers
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.near_me, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Consumer<AppProvider>(
                              builder: (context, provider, _) => Text(
                                "Near ${provider.currentUser?.location ?? 'You'}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Grid
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = provider.items[index];
                            return ItemCard(
                              item: item,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contact ${item.vendor?.shopName} for ${item.productName}'),
                                    action: SnackBarAction(label: 'Chat', onPressed: () {}),
                                  ),
                                );
                              },
                            ).animate().fadeIn(delay: (50 * index).ms).slideX();
                          },
                          childCount: provider.items.length,
                        ),
                      ),
                    ),
                    
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
            
            // Tutorial Overlays
            if (provider.showTutorial && provider.currentPage == 'home')
              TutorialOverlay(
                text: _getTutorialText(provider.tutorialStep),
                targetPosition: _getTutorialPos(context, provider.tutorialStep),
                isVisible: true,
                onNext: provider.nextTutorial,
                onSkip: provider.skipTutorial,
              ),

            // Subscription Popup
            if (provider.shouldShowSubscriptionPopup)
              SubscriptionPopup(
                onDismiss: provider.dismissSubscriptionPopup,
                onSubscribe: () {
                  provider.subscribe();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for subscribing!')),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  String _getTutorialText(int step) {
    switch (step) {
      case 0: return "Welcome! Use the search bar to find specific items quickly.";
      case 1: return "Browse by category - tap any image to filter items.";
      case 2: return "Check out our Best Sellers - vendors with proven track records!";
      case 3: return "Items are sorted by urgency. Red = expires soon!";
      default: return "";
    }
  }

  Offset _getTutorialPos(BuildContext context, int step) {
    final size = MediaQuery.of(context).size;
    switch (step) {
      case 0: return Offset(size.width * 0.5, 100);
      case 1: return Offset(size.width * 0.3, 200);
      case 2: return Offset(size.width * 0.5, 380);
      case 3: return Offset(size.width * 0.5, size.height * 0.6);
      default: return Offset(size.width / 2, size.height / 2);
    }
  }
}

class _HomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                const Text("Delivering to ", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Consumer<AppProvider>(
                  builder: (context, provider, _) => Text(
                    provider.currentUser?.location ?? "Chennai",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search surplus items...",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 130;

  @override
  double get minExtent => 130;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
