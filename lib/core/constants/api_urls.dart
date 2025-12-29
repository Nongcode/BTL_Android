// lib/core/constants/api_urls.dart
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb

class ApiUrls {
  static String get baseUrl {
    // 1. Nếu đang chạy trên Web -> Dùng localhost
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    }
    // 2. Nếu chạy trên Android (Máy ảo) -> Dùng 10.0.2.2
    // (Lưu ý: defaultTargetPlatform an toàn hơn Platform.isAndroid khi build đa nền tảng)
    else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:4000/api';
    }
    // 3. Các trường hợp khác (iOS, Máy thật...) -> Dùng localhost hoặc IP LAN
    else {
      return 'http://localhost:4000/api'; // Hoặc IP LAN của bạn: 192.168.1.x
    }
  }

  static String get chores => '$baseUrl/chores';
  static String get generateDaily => '$baseUrl/chores/generate-daily';
  static String get todayChores => '$baseUrl/chores/today';
  static String get templates => '$baseUrl/chores/templates';

  // URL lấy resources (ảnh, icon)
  static String get staticIcons => '$baseUrl/chores/static/icons';
  static String get users => '$baseUrl/users';

  // Finance APIs
  static String get finance => '$baseUrl/finance';
  static String financeHouse(int houseId) => '$finance/houses/$houseId';
  static String fundSummary(int houseId) =>
      '${financeHouse(houseId)}/fund/summary';
  static String fundSettings(int houseId) =>
      '${financeHouse(houseId)}/fund/settings';
  static String fundContributions(int houseId) =>
      '${financeHouse(houseId)}/fund/contributions';
  static String commonExpenses(int houseId) =>
      '${financeHouse(houseId)}/expenses/common';
  static String adHocExpenses(int houseId) =>
      '${financeHouse(houseId)}/expenses/adhoc';
  static String debts(int houseId) => '${financeHouse(houseId)}/debts';
  static String debtPayments(int houseId, int debtId) =>
      '${financeHouse(houseId)}/debts/$debtId/payments';
  static String payDebt(int houseId, int debtId) =>
      '${financeHouse(houseId)}/debts/$debtId/pay';
  static String confirmDebtPayment(int houseId, int paymentId) =>
      '${financeHouse(houseId)}/debts/payments/$paymentId/confirm';
  static String debtSummary(int houseId) =>
      '${financeHouse(houseId)}/debts/summary';
  static String expenseStatistics(int houseId) =>
      '${financeHouse(houseId)}/expenses/statistics';
}
