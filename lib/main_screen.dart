import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/chores/presentation/screens/chore_screen.dart';
import 'features/bulletin/presentation/screens/news_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Hàm chuyển tab
  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- KHAI BÁO DANH SÁCH TRANG Ở TRONG NÀY ---
    final List<Widget> pages = [
      HomeScreen(
        onSwitchTab: (index) => _switchTab(index),
      ),
      const ChoreScreen(), // Index 1
      const Scaffold(body: Center(child: Text("Quỹ chung"))), // Index 2
      const NewsScreen(), // Index 3
    ];

    return Scaffold(
      // Cho phép nội dung tràn xuống dưới thanh điều hướng để trông đẹp hơn
      extendBody: true, 
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        // 1. Tạo khoảng cách (Margin) để thanh menu "nổi" lên khỏi đáy và cách 2 bên
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20), 
        color: Colors.transparent, // Nền trong suốt để thấy được background của Scaffold
        
        child: Container(
          // 2. Trang trí cho khung menu (Bo tròn + Đổ bóng)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Bo tròn mạnh để tạo hình viên thuốc
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Bóng nhẹ hơn chút cho tinh tế
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          
          // 3. Cắt (Clip) nội dung bên trong theo hình bo tròn
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _switchTab(index);
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white, // Màu nền trắng
              elevation: 0, // Tắt bóng mặc định của BottomNav (vì ta đã dùng bóng của Container)
              
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              
              // Ẩn bớt Label khi chưa chọn để gọn hơn (Optional - Tùy sở thích)
              showUnselectedLabels: true, 
              
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), 
                  activeIcon: Icon(Icons.home), 
                  label: 'Trang chủ'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_rtl_outlined), 
                  activeIcon: Icon(Icons.checklist_rtl), 
                  label: 'Việc nhà'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined), 
                  activeIcon: Icon(Icons.account_balance_wallet), 
                  label: 'Quỹ chung'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined), 
                  activeIcon: Icon(Icons.notifications), 
                  label: 'Tin tức'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}