class FinanceItem {
  final String id;
  final String title;
  final String description;
  final String amount;
  final String date;
  final String category; // 'expense' hoặc 'income'

  FinanceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}
