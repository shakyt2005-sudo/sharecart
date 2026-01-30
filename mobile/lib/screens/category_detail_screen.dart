import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/colors.dart';
import '../models/models.dart';
import '../widgets/item_card.dart';
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
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, shadows: [
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
                        color: AppColors.primaryLight,
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
                          Colors.black.withOpacity(0.7),
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
                  // Simple category matching logic
                  final productLower = item.productName.toLowerCase();
                  final categoryLower = category.name.toLowerCase();
                  
                  if (categoryLower.contains('vegetable')) {
                    return productLower.contains('carrot') || productLower.contains('tomato') || productLower.contains('spinach');
                  } else if (categoryLower.contains('bakery')) {
                    return productLower.contains('bread') || productLower.contains('donut') || productLower.contains('cake');
                  } else if (categoryLower.contains('dairy')) {
                    return productLower.contains('milk') || productLower.contains('cheese') || productLower.contains('butter');
                  } else if (categoryLower.contains('packaged')) {
                    return productLower.contains('can') || productLower.contains('bean') || productLower.contains('packet');
                  }
                  return true; // Show all for other categories
                }).toList();

                if (categoryItems.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(category.icon, style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 16),
                          const Text(
                            'No items in this category yet',
                            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
