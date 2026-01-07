import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_urls.dart';
import '../models/finance_model.dart';

class FinanceService {
  final int houseId;
  final String? authToken;

  // Lưu thông tin lỗi gần nhất để dễ debug trên UI
  static String? lastDebtSummaryDebug;
  static String? lastDeleteAdHocError;

  FinanceService({this.houseId = 1, this.authToken});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null && authToken!.isNotEmpty)
      'Authorization': 'Bearer $authToken',
  };

  Uri _withQuery(String base, {int? month, int? year}) {
    final query = <String, String>{};
    if (month != null) query['month'] = month.toString();
    if (year != null) query['year'] = year.toString();
    return Uri.parse(
      base,
    ).replace(queryParameters: query.isEmpty ? null : query);
  }

  Future<FundSummary?> fetchFundSummary({int? month, int? year}) async {
    try {
      final uri = _withQuery(
        ApiUrls.fundSummary(houseId),
        month: month,
        year: year,
      );
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          return FundSummary.fromJson(body['data']);
        }
      }
      // Log giúp debug khi backend không trả dữ liệu
      // ignore: avoid_print
      print('fundSummary error ${res.statusCode}: ${res.body}');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('fundSummary exception: $e');
      return null;
    }
  }

  Future<List<CommonExpense>> fetchCommonExpenses({
    int? month,
    int? year,
  }) async {
    try {
      final uri = _withQuery(
        ApiUrls.commonExpenses(houseId),
        month: month,
        year: year,
      );
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((item) => CommonExpense.fromJson(item)).toList();
        }
      }
      // ignore: avoid_print
      print('commonExpenses error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('commonExpenses exception: $e');
      return [];
    }
  }

  Future<List<AdHocExpense>> fetchAdHocExpenses({int? month, int? year}) async {
    try {
      final uri = _withQuery(
        ApiUrls.adHocExpenses(houseId),
        month: month,
        year: year,
      );
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((item) => AdHocExpense.fromJson(item)).toList();
        }
      }
      // ignore: avoid_print
      print('adHocExpenses error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('adHocExpenses exception: $e');
      return [];
    }
  }

  Future<bool> updateAdHocExpense({
    required int expenseId,
    required int paidBy,
    required String title,
    String? description,
    required double totalAmount,
    required DateTime expenseDate,
    String splitMethod = 'equal',
    List<Map<String, dynamic>> splits = const [],
  }) async {
    final uri = Uri.parse('${ApiUrls.adHocExpenses(houseId)}/$expenseId');
    final payload = {
      'paidBy': paidBy,
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      'totalAmount': totalAmount,
      'expenseDate': expenseDate.toIso8601String(),
      'splitMethod': splitMethod,
      'splits': splits,
    };
    final res = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteAdHocExpense({required int expenseId}) async {
    final uri = Uri.parse('${ApiUrls.adHocExpenses(houseId)}/$expenseId');
    final res = await http.delete(uri, headers: _headers);
    if (res.statusCode == 200) {
      lastDeleteAdHocError = null;
      return true;
    }

    // parse message nếu có để hiển thị
    try {
      final body = jsonDecode(res.body);
      final msg = body is Map && body['message'] is String
          ? body['message']
          : null;
      lastDeleteAdHocError = msg ?? res.body;
    } catch (_) {
      lastDeleteAdHocError = res.body;
    }

    // ignore: avoid_print
    print('deleteAdHocExpense error ${res.statusCode}: ${res.body}');
    return false;
  }

  Future<List<Contribution>> fetchContributions({int? month, int? year}) async {
    try {
      final uri = _withQuery(
        ApiUrls.fundContributions(houseId),
        month: month,
        year: year,
      );
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((item) => Contribution.fromJson(item)).toList();
        }
      }
      // ignore: avoid_print
      print('contributions error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('contributions exception: $e');
      return [];
    }
  }

  Future<bool> addContribution({
    required int memberId,
    required double amount,
    required DateTime contributionDate,
    required int month,
    required int year,
    String? note,
  }) async {
    final uri = Uri.parse(ApiUrls.fundContributions(houseId));
    final payload = {
      'memberId': memberId,
      'amount': amount,
      'month': month,
      'year': year,
      'contributionDate': contributionDate.toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateFundSettings({
    required double contributionAmount,
    String contributionFrequency = 'monthly',
  }) async {
    final uri = Uri.parse(ApiUrls.fundSettings(houseId));
    final payload = {
      'contributionAmount': contributionAmount,
      'contributionFrequency': contributionFrequency,
    };
    final res = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<bool> addCommonExpense({
    required int paidBy,
    required String title,
    String? description,
    required double amount,
    required DateTime expenseDate,
    String? category,
  }) async {
    final uri = Uri.parse(ApiUrls.commonExpenses(houseId));
    final payload = {
      'paidBy': paidBy,
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      'amount': amount,
      'expenseDate': expenseDate.toIso8601String(),
      if (category != null) 'category': category,
    };
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteCommonExpense({required int expenseId}) async {
    final uri = Uri.parse('${ApiUrls.commonExpenses(houseId)}/$expenseId');
    final res = await http.delete(uri, headers: _headers);
    return res.statusCode == 200;
  }

  Future<List<DebtPair>> fetchDebtSummary() async {
    lastDebtSummaryDebug = null;
    try {
      final uri = Uri.parse(ApiUrls.debtSummary(houseId));
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final dynamic payload = body['data'];
          List<dynamic> dataList = const [];

          if (payload is List) {
            dataList = payload;
          } else if (payload is Map && payload['debtPairs'] is List) {
            dataList = payload['debtPairs'] as List;
          }

          return dataList.map((e) => DebtPair.fromJson(e)).toList();
        }
      }
      lastDebtSummaryDebug =
          'status: ${res.statusCode}, body: ${res.body.toString()}';
      // ignore: avoid_print
      print('debtSummary error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      lastDebtSummaryDebug = e.toString();
      // ignore: avoid_print
      print('debtSummary exception: $e');
      return [];
    }
  }

  Future<List<DebtItem>> fetchDebts({
    required int memberId,
    String? status,
  }) async {
    try {
      final query = <String, String>{'memberId': memberId.toString()};
      if (status != null && status.isNotEmpty) query['status'] = status;
      final uri = Uri.parse(
        ApiUrls.debts(houseId),
      ).replace(queryParameters: query);
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data =
              body['data']?['debts'] ?? body['data'] ?? [];
          return data.map((e) => DebtItem.fromJson(e)).toList();
        }
      }
      // ignore: avoid_print
      print('debts error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('debts exception: $e');
      return [];
    }
  }

  Future<List<FundHistoryItem>> fetchFundHistory({
    int? month,
    int? year,
    String type = 'all',
  }) async {
    try {
      final query = <String, String>{};
      if (month != null) query['month'] = month.toString();
      if (year != null) query['year'] = year.toString();
      if (type.isNotEmpty) query['type'] = type;
      final uri = Uri.parse(
        ApiUrls.fundHistory(houseId),
      ).replace(queryParameters: query.isEmpty ? null : query);
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final List<dynamic> data = body['data'] ?? [];
          return data.map((e) => FundHistoryItem.fromJson(e)).toList();
        }
      }
      // ignore: avoid_print
      print('fundHistory error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('fundHistory exception: $e');
      return [];
    }
  }

  Future<bool> payDebt({
    required int debtId,
    required double amountPaid,
    required DateTime paymentDate,
    String paymentMethod = 'cash',
    String? note,
  }) async {
    final uri = Uri.parse(ApiUrls.payDebt(houseId, debtId));
    final payload = {
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<bool> confirmDebtPayment({
    required int paymentId,
    bool confirmed = true,
    String? note,
  }) async {
    final uri = Uri.parse(ApiUrls.confirmDebtPayment(houseId, paymentId));
    final payload = {
      'confirmed': confirmed,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final res = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }

  Future<List<DebtPayment>> fetchDebtPayments({required int debtId}) async {
    try {
      final uri = Uri.parse(ApiUrls.debtPayments(houseId, debtId));
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          dynamic data = body['data'];

          List<dynamic> _decodeToList(dynamic value) {
            if (value is List) return value;
            if (value is String) {
              try {
                final decoded = jsonDecode(value);
                if (decoded is List) return decoded;
              } catch (_) {
                return const [];
              }
            }
            return const [];
          }

          final List<dynamic> list = () {
            if (data is List) return data;
            if (data is Map) return _decodeToList(data['payments']);
            return _decodeToList(data);
          }();

          final List<DebtPayment> mapped = [];
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              try {
                mapped.add(DebtPayment.fromJson(item));
              } catch (e) {
                // ignore: avoid_print
                print('debtPayments parse item error: $e');
              }
            }
          }
          return mapped;
        }
      }
      // ignore: avoid_print
      print('debtPayments error ${res.statusCode}: ${res.body}');
      return [];
    } catch (e) {
      // ignore: avoid_print
      print('debtPayments raw response error: $e');
      // ignore: avoid_print
      print('debtPayments exception: $e');
      return [];
    }
  }

  Future<bool> addAdHocExpense({
    required int paidBy,
    required String title,
    String? description,
    required double totalAmount,
    required DateTime expenseDate,
    String splitMethod = 'equal',
    List<Map<String, dynamic>> splits = const [],
  }) async {
    final uri = Uri.parse(ApiUrls.adHocExpenses(houseId));
    final payload = {
      'paidBy': paidBy,
      'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      'totalAmount': totalAmount,
      'expenseDate': expenseDate.toIso8601String(),
      'splitMethod': splitMethod,
      'splits': splits,
    };
    final res = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(payload),
    );
    return res.statusCode == 200;
  }
}
