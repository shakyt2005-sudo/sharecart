import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/colors.dart';
import '../models/models.dart';
import '../widgets/item_card.dart';
import '../widgets/item_details_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, shadows: [
                  Shadow(color: Colors.black45, blurRadius: 4)
                ]),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary,
                        child: Center(
                          child: Text(category.icon, style: const TextStyle(fontSize: 64)),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items in this category
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: Consumer<AppProvider>(
              builder: (context, provider, child) {
                // Filter items by category (simplified - matching product names)
                final categoryItems = provider.items.where((item) {
                  final productLower = item.productName.toLowerCase();
                  final categoryLower = category.name.toLowerCase();
                  
                  // More robust matching could be done here or in backend
                  if (categoryLower.contains('vegetable')) {
                    if (item.category == 'Vegetables') return true;
                    return productLower.contains('carrot') || productLower.contains('tomato') || productLower.contains('spinach');
                  } 
                  if (categoryLower.contains('bakery')) {
                    if (item.category == 'Bakery') return true;
                    return productLower.contains('bread') || productLower.contains('donut') || productLower.contains('cake');
                  }
                  if (categoryLower.contains('dairy')) {
                    if (item.category == 'Dairy') return true;
                    return productLower.contains('milk') || productLower.contains('cheese') || productLower.contains('butter');
                  }
                  // Default search match
                  return item.category == category.name; 
                }).toList();

                if (categoryItems.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                              ]
                            ),
                            child: const Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No items found',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try looking in other categories',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = categoryItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ItemCard(
                          item: item,
                          onTap: () {
                             showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ItemDetailsDialog(item: item),
                              );
                          },
                        ),
                      ).animate().fadeIn(delay: (50 * index).ms).slideX();
                    },
                    childCount: categoryItems.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
