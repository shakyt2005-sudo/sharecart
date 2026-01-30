import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../core/colors.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ItemCard({Key? key, required this.item, required this.onTap}) : super(key: key);

  Color _getExpiryColor(DateTime expiry) {
    final days = expiry.difference(DateTime.now()).inDays;
    if (days < 3) return AppColors.error;
    if (days < 7) return AppColors.accent;
    return AppColors.success;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final expiryColor = _getExpiryColor(item.expiryDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon / Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.quantity} • ${item.vendor?.shopName ?? "Unknown"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                       const SizedBox(height: 8),
                       Row(
                         children: [
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: expiryColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Row(
                               children: [
                                 Icon(Icons.access_time_filled, size: 12, color: expiryColor),
                                 const SizedBox(width: 4),
                                 Text(
                                   'Expires ${_formatDate(item.expiryDate)}',
                                   style: TextStyle(
                                     fontSize: 12,
                                     fontWeight: FontWeight.w600,
                                     color: expiryColor,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                       )
                    ],
                  ),
                ),
                
                // Action Icon
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: AppColors.background),
                   ),
                   child: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
