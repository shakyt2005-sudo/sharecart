import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/colors.dart';
import '../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  
  const PaymentScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _selectedMethod;

  final List<Map<String, dynamic>> _methods = [
    {'id': 'upi', 'name': 'UPI ID', 'icon': Icons.qr_code_scanner},
    {'id': 'card', 'name': 'Credit/Debit Card', 'icon': Icons.credit_card},
    {'id': 'netbanking', 'name': 'Net Banking', 'icon': Icons.account_balance},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Secure Checkout", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSuccess 
          ? _buildSuccessView() 
          : _buildPaymentForm(),
    );
  }

  Widget _buildPaymentForm() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Amount", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text("₹${widget.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              const Text("Select Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              
              ..._methods.map((method) => 
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedMethod == method['id'] ? AppColors.primary : Colors.transparent,
                      width: 2
                    ),
                  ),
                  child: ListTile(
                    onTap: () => setState(() => _selectedMethod = method['id']),
                    leading: Icon(method['icon'], color: AppColors.primary),
                    title: Text(method['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: _selectedMethod == method['id'] 
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
                  ),
                )
              ).toList(),
              
              const Spacer(),
              
              CustomButton(
                text: "Pay Now",
                isLoading: _isLoading,
                onPressed: _selectedMethod == null ? null : _processPayment,
              ),
            ],
          ),
        ),
        
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 60),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          
          const SizedBox(height: 30),
          
          const Text(
            "Payment Successful!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ).animate().fadeIn().slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 10),
          Text(
            "Redirecting back...",
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _processPayment() async {
    setState(() => _isLoading = true);
    
    // Simulate processing
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
    
    // Auto populate back
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    });
  }
}
