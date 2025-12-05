import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/chores/presentation/screens/chore_screen.dart';

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
    // Lý do: Để có thể truyền hàm _switchTab vào HomeScreen
    final List<Widget> pages = [
      HomeScreen(
        onSwitchTab: (index) => _switchTab(index), // Truyền hàm vào đây
      ),
      const ChoreScreen(), // Index 1
      const Scaffold(body: Center(child: Text("Quỹ chung"))), // Index 2
      const Scaffold(body: Center(child: Text("Thông báo"))), // Index 3
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: pages, // Sử dụng biến pages vừa tạo ở trên
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            _switchTab(index); // Gọi hàm chuyển tab khi bấm icon
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(icon: Icon(Icons.checklist_rtl_outlined), activeIcon: Icon(Icons.checklist_rtl), label: 'Việc nhà'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Quỹ chung'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
          ],
        ),
      ),
    );
  }
}