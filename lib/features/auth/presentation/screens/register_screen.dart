import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Import Service
import '../../data/auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Thêm controller cho username
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService(); // Khởi tạo Service

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 20),
              // Header nhỏ gọn hơn chút để đỡ phải cuộn nhiều
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Logo/logohome.svg',
                      height: 150, // Giảm kích thước logo chút cho cân đối
                      width: 150,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tạo tài khoản mới',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5DBDD4)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 1. Username Field (MỚI THÊM)
              const Text('Tên đăng nhập', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: _buildInputDecoration('Nhập tên đăng nhập (viết liền)', Icons.account_circle),
              ),
              const SizedBox(height: 16),

              // 2. Full Name Field
              const Text('Họ và tên', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _buildInputDecoration('Nhập họ tên đầy đủ', Icons.person),
              ),
              const SizedBox(height: 16),

              // 3. Email Field
              const Text('Email', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration('Nhập email của bạn', Icons.email),
              ),
              const SizedBox(height: 16),

              // 4. Password Field
              const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: _buildInputDecoration('Mật khẩu (tối thiểu 6 ký tự)', Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF5DBDD4)),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Confirm Password Field
              const Text('Xác nhận mật khẩu', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: _buildInputDecoration('Nhập lại mật khẩu', Icons.lock_outline).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: const Color(0xFF5DBDD4)),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5DBDD4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : const Text('Đăng ký', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: const Text('Đăng nhập', style: TextStyle(color: Color(0xFF5DBDD4), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm Helper để tạo Style cho TextField đỡ lặp code
  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF5DBDD4)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF5DBDD4))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _register() async {
    final username = _usernameController.text.trim();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validate cơ bản
    if (username.isEmpty || name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Vui lòng điền đầy đủ thông tin', Colors.orange);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Mật khẩu xác nhận không khớp', Colors.orange);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Mật khẩu phải có ít nhất 6 ký tự', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    // 2. Gọi API Đăng ký
    final result = await _authService.register(
      username, // Tên đăng nhập
      password, // Mật khẩu
      email,    // Email
      name      // Họ tên đầy đủ (Backend nhận là fullName)
    );

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success']) {
        // 3. Thành công -> Quay về màn hình đăng nhập
        _showSnackBar('Đăng ký thành công! Vui lòng đăng nhập.', Colors.green);
        
        // Đợi 1 chút để người dùng đọc thông báo rồi chuyển trang
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
           Navigator.pop(context); // Quay lại màn hình Login trước đó
        }
      } else {
        // 4. Thất bại -> Hiện lỗi từ Backend (ví dụ: Trùng username)
        _showSnackBar(result['message'] ?? 'Đăng ký thất bại', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}