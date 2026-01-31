import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../core/colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController(); // New Location Field
  
  String _selectedRole = 'Vendor';
  final List<String> _roles = ['Vendor', 'User'];
  
  // For Vendor only
  String _shopType = 'Grocery';
  final List<String> _shopTypes = ['Grocery', 'Bakery', 'Restaurant', 'Farm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.primary),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                
                const SizedBox(height: 24),
                
                const Text(
                  'ShareCart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 8),
                const Text(
                  'Professional B2B Surplus Marketplace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 48),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Role Selector Removed - Defaulting to Vendor
                      const Text(
                        "Vendor Login",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      
                      const SizedBox(height: 24),

                      // Fields
                      _buildTextField('Phone Number', Icons.phone_outlined, _phoneController),
                      const SizedBox(height: 16),
                      _buildTextField('Shop Name', Icons.store_outlined, _nameController),
                      const SizedBox(height: 16),
                      _buildTextField('Location (City, Area)', Icons.location_on_outlined, _locationController),
                      const SizedBox(height: 16),
                      _buildDropdown(),
                      
                      const SizedBox(height: 32),
                      
                      // Primary Button
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : () async {
                                if (_isValid()) {
                                  // Simplified login for demo - passes basic info
                                  bool success = await provider.login(
                                    _phoneController.text,
                                    _nameController.text,
                                    'Vendor', // Forced Vendor Role
                                  );
                                  if (!success) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                       const SnackBar(content: Text('Login failed. Check connection.'))
                                     );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(content: Text('Please fill all fields'))
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: provider.isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Access Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 24),
                
                // Guest Option
                Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return TextButton(
                      onPressed: () {
                        provider.loginAsGuest();
                        // Provider handles navigation or state change
                      },
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 16),
                const Text(
                  'Guests can browse but cannot transact.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValid() {
    return _phoneController.text.isNotEmpty && 
           _nameController.text.isNotEmpty && 
           _locationController.text.isNotEmpty;
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: AppColors.background,
        ),
      ),
    );
  }
  
  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _shopType,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 16),
          items: _shopTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'Grocery' ? Icons.local_grocery_store_outlined :
                    value == 'Bakery' ? Icons.cake_outlined :
                    value == 'Restaurant' ? Icons.restaurant_outlined :
                    Icons.grass_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _shopType = newValue!;
            });
          },
        ),
      ),
    );
  }
}
