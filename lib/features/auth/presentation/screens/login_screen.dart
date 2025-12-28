import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'register_screen.dart';
import '../../../../../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Logo hoặc tiêu đề
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Logo/logohome.svg',
                      height: 250,
                      width: 250,
                    ),
                    const SizedBox(height: 16),
                    // const Text(
                    //   'HousePal',
                    //   style: TextStyle(
                    //     fontSize: 32,
                    //     fontWeight: FontWeight.bold,
                    //     color: Color(0xFF5DBDD4),
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    const Text(
                      'Chào mừng bạn trở lại',
                      style: TextStyle(fontSize: 26, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Email field
              const Text(
                'Số điện thoại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Nhập số điện thoại của bạn',
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF5DBDD4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5DBDD4)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Password field
              const Text(
                'Mật khẩu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Nhập mật khẩu',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF5DBDD4)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF5DBDD4),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF5DBDD4)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to forgot password
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(
                      color: Color(0xFF5DBDD4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DBDD4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Divider
              // Row(
              //   children: [
              //     Expanded(child: Divider(color: Colors.grey.shade300)),
              //     const Padding(
              //       padding: EdgeInsets.symmetric(horizontal: 16),
              //       child: Text('hoặc', style: TextStyle(color: Colors.grey)),
              //     ),
              //     Expanded(child: Divider(color: Colors.grey.shade300)),
              //   ],
              // ),
              // const SizedBox(height: 24),

              // Social login buttons (optional)
              // Row(
              //   children: [
              //     Expanded(
              //       child: OutlinedButton(
              //         onPressed: () {
              //           // TODO: Google login
              //         },
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           side: const BorderSide(color: Colors.grey),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             const Icon(
              //               Icons.g_mobiledata,
              //               color: Colors.red,
              //               size: 20,
              //             ),
              //             const SizedBox(width: 8),
              //             const Text(
              //               'Google',
              //               style: TextStyle(color: Colors.black87),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: OutlinedButton(
              //         onPressed: () {
              //           // TODO: Facebook login
              //         },
              //         style: OutlinedButton.styleFrom(
              //           padding: const EdgeInsets.symmetric(vertical: 12),
              //           side: const BorderSide(color: Colors.grey),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(12),
              //           ),
              //         ),
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             const Icon(
              //               Icons.facebook,
              //               color: Colors.blue,
              //               size: 20,
              //             ),
              //             const SizedBox(width: 8),
              //             const Text(
              //               'Facebook',
              //               style: TextStyle(color: Colors.black87),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 32),

              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        color: Color(0xFF5DBDD4),
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

  void _login() async {
    // TODO: Implement login logic
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate loading time for better UX
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Call login API
    // For now, just navigate to main screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }
}
