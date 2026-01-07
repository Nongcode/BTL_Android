// lib/core/constants/api_urls.dart
import 'package:flutter/foundation.dart';

// Cho phép override base URL khi build (ví dụ chạy trên thiết bị thật):
// flutter run --dart-define=API_BASE_URL=http://192.168.1.10:4000/api
const String _overrideBaseUrl = String.fromEnvironment('API_BASE_URL');

class ApiUrls {
  /// Base: http://<host>:4000/api
  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) {
      return 'http://localhost:4000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator
      return 'http://10.0.2.2:4000/api';
    } else {
      // iOS simulator / desktop
      // Nếu chạy trên điện thoại thật: đổi sang IP LAN của máy tính, ví dụ:
      // return 'http://192.168.1.10:4000/api';
      return 'http://localhost:4000/api';
    }
  }

  // ===== Common / Auth / Houses =====
  static String get users => '$baseUrl/users';
  static String get auth => '$baseUrl/auth';
  static String get houses => '$baseUrl/houses';

  // ===== Chores =====
  static String get chores => '$baseUrl/chores';
  static String get generateDaily => '$baseUrl/chores/generate-daily';
  static String get todayChores => '$baseUrl/chores/today';
  static String get templates => '$baseUrl/chores/templates';
  static String get staticIcons => '$baseUrl/chores/static/icons';

  // ===== Finance =====
  static String get finance => '$baseUrl/finance';

  static String financeHouse(int houseId) => '$finance/houses/$houseId';

  static String fundSummary(int houseId) =>
      '${financeHouse(houseId)}/fund/summary';
  static String fundSettings(int houseId) =>
      '${financeHouse(houseId)}/fund/settings';
  static String fundContributions(int houseId) =>
      '${financeHouse(houseId)}/fund/contributions';
  static String fundHistory(int houseId) =>
      '${financeHouse(houseId)}/fund/history';

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

  // ===== Bulletin =====
  static String get bulletinBase => '$baseUrl/bulletin';

  // Upload image (POST multipart/form-data, key = "file")
  static String get bulletinUploadImage => '$bulletinBase/upload/image';

  // Notes
  static String bulletinNotesByHouse(int houseId) =>
      '$bulletinBase/houses/$houseId/notes';
  static String bulletinNoteById(String id) => '$bulletinBase/notes/$id';

  // Items
  static String bulletinItemsByHouse(int houseId) =>
      '$bulletinBase/houses/$houseId/items';
  static String bulletinItemById(String id) => '$bulletinBase/items/$id';

  // Comments
  static String bulletinCommentsByTarget(
    int houseId,
    String targetType,
    String targetId,
  ) => '$bulletinBase/houses/$houseId/comments/$targetType/$targetId';

  static String bulletinCommentById(String id) => '$bulletinBase/comments/$id';
}
