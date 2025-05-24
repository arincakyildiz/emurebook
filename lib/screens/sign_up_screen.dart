import 'package:flutter/material.dart';
import 'package:emurebook/services/service_provider.dart';
import 'package:emurebook/widgets/loading_indicator.dart';
import 'login_screen.dart';
import 'home_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final studentIdController = TextEditingController();
  final phoneController = TextEditingController();
  final departmentController = TextEditingController();
  bool obscurePassword = true;
  String? selectedDepartment;
  bool isLoading = false;
  String? errorMessage;

  final _authService = ServiceProvider().authService;

  final List<String> departments = [
    'Computer Engineering',
    'Electrical & Electronic Engineering',
    'Civil Engineering',
    'Mechanical Engineering',
    'Industrial Engineering',
    'Architecture',
    'Business Administration',
    'Economics',
    'International Relations',
    'Psychology',
    'English Language Teaching',
    'Other'
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    studentIdController.dispose();
    phoneController.dispose();
    departmentController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Form validation
    if (nameController.text.isEmpty ||
        studentIdController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty ||
        selectedDepartment == null ||
        passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Lütfen tüm alanları doldurunuz.';
      });
      return;
    }

    // Email validation
    if (!emailController.text.endsWith('@emu.edu.tr')) {
      setState(() {
        errorMessage = 'Lütfen EMU email adresinizi kullanınız.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'studentId': studentIdController.text.trim(),
        'phone': phoneController.text.trim(),
        'department': selectedDepartment,
      };

      await _authService.register(userData);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeLayout()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Hesabınız oluşturuluyor...'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Image.asset('assets/images/emu_logo.png', height: 80),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildTextField(
                controller: nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: studentIdController,
                label: 'Student ID',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: 'EMU Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  isExpanded: true,
                  decoration: InputDecoration(
                    hintText: 'Select Department',
                    prefixIcon: const Icon(Icons.school_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: departments.map((String department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(
                        department,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDepartment = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: obscurePassword,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D66F4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF2D66F4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
