import 'package:flutter/material.dart';
import '../core/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Transaction {
  final String id;
  final String itemName;
  final String vendorName;
  final double amount;
  final DateTime mdate;
  final String status;

  Transaction(this.id, this.itemName, this.vendorName, this.amount, this.mdate, this.status);
}

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock Transactions
    final transactions = [
      Transaction("1", "Organic Carrots", "Fresh Farms", 5.00, DateTime.now().subtract(const Duration(days: 1)), "Completed"),
      Transaction("2", "Sourdough Bread", "City Bakery", 4.50, DateTime.now().subtract(const Duration(days: 2)), "Completed"),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Transactions', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long, color: AppColors.success),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tx.itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      Text(tx.vendorName, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(
                        "${tx.mdate.day}/${tx.mdate.month} • ${tx.status}",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  "\$${tx.amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX();
        },
      ),
    );
  }
}
