import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/custom_button.dart';
import '../core/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _shopController = TextEditingController();
  
  // Hardcoded type for demo simplicity, or dropdown
  String _selectedType = 'Grocery';
  final List<String> _types = ['Grocery', 'Bakery', 'Restaurant', 'Farm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo or Header
              const Icon(Icons.local_mall_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'ShareCart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'Turn surplus into value.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 48),

              // Inputs
              _buildTextField('Phone Number', Icons.phone, _phoneController),
              const SizedBox(height: 16),
              _buildTextField('Shop Name', Icons.store, _shopController),
              const SizedBox(height: 16),
              
              // Type Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _types.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return CustomButton(
                    text: 'Get Started',
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      if (_phoneController.text.isNotEmpty && _shopController.text.isNotEmpty) {
                        bool success = await provider.login(
                          _phoneController.text,
                          _shopController.text,
                          _selectedType,
                        );
                        if (!success) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Login failed. Check connection.'))
                           );
                        }
                      }
                    },
                  );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
