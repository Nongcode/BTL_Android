import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Import Service Auth
import '../../data/auth_service.dart';
import 'register_screen.dart';
import '../../../../../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Đổi tên thành _usernameController cho khớp với Backend
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Khởi tạo Service

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/Logo/logohome.svg',
                      height: 250,
                      width: 250,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chào mừng bạn trở lại',
                      style: TextStyle(fontSize: 26, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Username / Phone field
              const Text(
                'Email đăng nhập', // Sửa label cho tổng quát
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController, // Dùng controller mới
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Nhập email đăng nhập',
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF5DBDD4)), // Đổi icon thành Person cho hợp lý
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

              // Register Link
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

  // --- HÀM XỬ LÝ ĐĂNG NHẬP ---
  void _login() async {
    // 1. Lấy dữ liệu từ ô nhập
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // 2. Kiểm tra rỗng
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên đăng nhập và mật khẩu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 3. Bật trạng thái Loading
    setState(() {
      _isLoading = true;
    });

    // 4. Gọi API Login
    final result = await _authService.login(username, password);

    // 5. Tắt loading khi có kết quả
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    // 6. Xử lý kết quả
    if (result['success']) {
      // --- THÀNH CÔNG ---
      final data = result['data'];
      final token = data['token'];
      final user = data['user'];

      print("Login thành công! Token: $token");
      print("User: ${user['full_name']}");

      // TODO: Ở bước này bạn nên lưu Token vào SharedPreferences
      // await SharedPreferences.getInstance().then((prefs) {
      //   prefs.setString('accessToken', token);
      //   prefs.setString('userId', user['id'].toString());
      // });

      if (mounted) {
        // Chuyển sang màn hình chính và xóa các màn hình cũ khỏi stack
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      // --- THẤT BẠI ---
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}