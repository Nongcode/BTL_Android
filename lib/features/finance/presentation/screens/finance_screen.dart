import 'package:flutter/material.dart';
import '../../data/models/finance_model.dart';
import '../widgets/finance_stat_card.dart';
import '../widgets/finance_item_card.dart';
import '../widgets/finance_summary_card.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  int _selectedTabIndex = 0;

  // Mock data
  List<FinanceItem> allFinanceItems = [
    FinanceItem(
      id: '1',
      title: 'Đi ăn lẩu cuối tháng',
      description: 'Chi tiêu khác trong tháng - A B C',
      amount: '500.000 đ',
      date: '27/12/2025',
      category: 'expense',
    ),
    FinanceItem(
      id: '2',
      title: 'Bánh sinh nhật',
      description: 'Sinh nhật - Chi tiêu - A C',
      amount: '200.000 đ',
      date: '27/12/2025',
      category: 'expense',
    ),
    FinanceItem(
      id: '3',
      title: 'Thu tiền tháng',
      description: 'Quỹ chung tháng này',
      amount: '+1.500.000 đ',
      date: '01/12/2025',
      category: 'income',
    ),
  ];

  List<FinanceItem> get filteredFinances {
    if (_selectedTabIndex == 1) {
      return allFinanceItems.where((item) => item.category == 'expense').toList();
    } else if (_selectedTabIndex == 2) {
      return allFinanceItems.where((item) => item.category == 'income').toList();
    }
    return allFinanceItems;
  }

  int get totalExpense => allFinanceItems
      .where((item) => item.category == 'expense')
      .length;
  int get totalIncome =>
      allFinanceItems.where((item) => item.category == 'income').length;
  int get totalItems => allFinanceItems.length;

  @override
  Widget build(BuildContext context) {
    final currentList = filteredFinances;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner
                Center(
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20, top: 30),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.attach_money_rounded,
                        size: 80, color: Colors.cyan),
                  ),
                ),

                // 2. Stat Cards (Tất cả / Chi tiêu / Thu nhập)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: FinanceStatCard(
                        title: "Tất cả giao dịch",
                        amount: "$totalItems giao dịch",
                        iconColor: Colors.cyan,
                        amountColor: Colors.blue,
                        isSelected: _selectedTabIndex == 0,
                        onTap: () => setState(() => _selectedTabIndex = 0),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FinanceStatCard(
                        title: "Chi tiêu",
                        amount: "$totalExpense giao dịch",
                        iconColor: Colors.red,
                        amountColor: Colors.red,
                        isSelected: _selectedTabIndex == 1,
                        onTap: () => setState(() => _selectedTabIndex = 1),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FinanceStatCard(
                        title: "Thu nhập",
                        amount: "$totalIncome giao dịch",
                        iconColor: Colors.green,
                        amountColor: Colors.green,
                        isSelected: _selectedTabIndex == 2,
                        onTap: () => setState(() => _selectedTabIndex = 2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 3. Quỹ sinh hoạt section (từ ảnh)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.cyan.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_atm_rounded,
                              color: Colors.cyan, size: 28),
                          SizedBox(width: 10),
                          Text(
                            "Quỹ sinh hoạt",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildFinanceRow("Mục đông:", "500.000 đ/người/tháng"),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Đổ đông:",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: const [
                              _MemberDot(label: "M", color: Colors.pink),
                              SizedBox(width: 8),
                              _MemberDot(label: "L", color: Colors.green),
                              SizedBox(width: 8),
                              _MemberDot(label: "T", color: Colors.cyan),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildFinanceRow(
                          "Số dự hiện tại:", "80.000 đ",
                          color: Colors.cyan),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      FinanceSummaryCard(
                        title: "Binh nước uống",
                        description: "90.000 đ - Trừ quỹ ngày 09/11",
                        amount: "",
                        backgroundColor: Colors.white,
                        borderColor: Colors.cyan.withOpacity(0.3),
                        hasArrow: true,
                      ),
                      const SizedBox(height: 12),
                      FinanceSummaryCard(
                        title: "Nước rửa chén",
                        description: "40.000 đ - Trừ quỹ ngày 08/11",
                        amount: "",
                        backgroundColor: Colors.white,
                        borderColor: Colors.cyan.withOpacity(0.3),
                        hasArrow: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 4. Chi tiêu tháng section (từ ảnh)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shopping_cart_rounded,
                                  color: Colors.orange, size: 28),
                              SizedBox(width: 10),
                              Text(
                                "Chi tiêu tháng",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle "Thêm chi tiêu mới"
                            },
                            child: const Text(
                              "Thêm chi tiêu mới",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      FinanceSummaryCard(
                        title: "Đi ăn lẩu cuối tháng",
                        description: "Chi tiêu khác - Chứng được A B C",
                        amount: "500.000 đ",
                        backgroundColor: Colors.white,
                        borderColor: Colors.orange.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      FinanceSummaryCard(
                        title: "Bánh sinh nhật",
                        description: "Sinh nhật - Chi tiêu - A C",
                        amount: "200.000 đ",
                        backgroundColor: Colors.white,
                        borderColor: Colors.orange.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 5. Danh sách giao dịch chi tiết
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Danh sách giao dịch",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Có ${currentList.length} giao dịch",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      if (currentList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            "Không có giao dịch nào!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...currentList.map((finance) {
                          return FinanceItemCard(
                            title: finance.title,
                            description: finance.description,
                            amount: finance.amount,
                            category: finance.category,
                            date: finance.date,
                          );
                        }).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value,
      {Color color = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MemberDot extends StatelessWidget {
  final String label;
  final Color color;

  const _MemberDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ),
    );
  }
}
