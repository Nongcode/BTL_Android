class MemberStatus {
  final int memberId;
  final String memberName;
  final String status; // contributed | pending | overdue
  final double amount;
  final DateTime? contributedAt;
  final String? note;

  MemberStatus({
    required this.memberId,
    required this.memberName,
    required this.status,
    required this.amount,
    required this.contributedAt,
    required this.note,
  });

  factory MemberStatus.fromJson(Map<String, dynamic> json) {
    return MemberStatus(
      memberId: json['member_id'] ?? json['memberId'] ?? 0,
      memberName: json['member_name'] ?? json['memberName'] ?? 'Thành viên',
      status: json['status'] ?? 'pending',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      contributedAt: json['contributed_at'] != null
          ? DateTime.tryParse(json['contributed_at'].toString())
          : null,
      note: json['note'],
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

class FundSummary {
  final int houseId;
  final int month;
  final int year;
  final double contributionAmount;
  final int totalMembers;
  final int contributedCount;
  final double totalContributions;
  final double totalExpenses;
  final double currentBalance;
  final List<MemberStatus> memberStatus;

  FundSummary({
    required this.houseId,
    required this.month,
    required this.year,
    required this.contributionAmount,
    required this.totalMembers,
    required this.contributedCount,
    required this.totalContributions,
    required this.totalExpenses,
    required this.currentBalance,
    required this.memberStatus,
  });

  factory FundSummary.fromJson(Map<String, dynamic> json) {
    final List<MemberStatus> members = (json['memberStatus'] as List? ?? [])
        .map((item) => MemberStatus.fromJson(item))
        .toList();

    return FundSummary(
      houseId: json['houseId'] ?? 0,
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      contributionAmount: _toDouble(json['contributionAmount']),
      totalMembers: json['totalMembers'] ?? members.length,
      contributedCount: json['contributedCount'] ?? 0,
      totalContributions: _toDouble(json['totalContributions']),
      totalExpenses: _toDouble(json['totalExpenses']),
      currentBalance: _toDouble(json['currentBalance']),
      memberStatus: members,
    );
  }
}

class CommonExpense {
  final int id;
  final String title;
  final String? description;
  final double amount;
  final String paidByName;
  final int paidBy;
  final DateTime expenseDate;

  CommonExpense({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.paidByName,
    required this.paidBy,
    required this.expenseDate,
  });

  factory CommonExpense.fromJson(Map<String, dynamic> json) {
    return CommonExpense(
      id: json['expense_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      amount: _toDouble(json['amount']),
      paidByName: json['paid_by_name'] ?? json['paidByName'] ?? '',
      paidBy: json['paid_by'] ?? json['paidBy'] ?? 0,
      expenseDate:
          DateTime.tryParse(
            (json['expense_date'] ?? json['expenseDate'] ?? '').toString(),
          ) ??
          DateTime.now(),
    );
  }
}

class AdHocSplit {
  final int memberId;
  final String memberName;
  final double amountOwed;
  final double sharePercentage;

  AdHocSplit({
    required this.memberId,
    required this.memberName,
    required this.amountOwed,
    required this.sharePercentage,
  });

  factory AdHocSplit.fromJson(Map<String, dynamic> json) {
    return AdHocSplit(
      memberId: json['memberId'] ?? json['member_id'] ?? 0,
      memberName: json['memberName'] ?? json['member_name'] ?? '',
      amountOwed: _toDouble(json['amountOwed'] ?? json['amount_owed']),
      sharePercentage: _toDouble(
        json['sharePercentage'] ?? json['share_percentage'],
      ),
    );
  }
}

class AdHocExpense {
  final int id;
  final String title;
  final String? description;
  final double totalAmount;
  final String paidByName;
  final int paidBy;
  final DateTime expenseDate;
  final String splitMethod;
  final List<AdHocSplit> splits;

  AdHocExpense({
    required this.id,
    required this.title,
    required this.description,
    required this.totalAmount,
    required this.paidByName,
    required this.paidBy,
    required this.expenseDate,
    required this.splitMethod,
    required this.splits,
  });

  factory AdHocExpense.fromJson(Map<String, dynamic> json) {
    final List<dynamic> splitJson = json['splits'] as List? ?? [];
    return AdHocExpense(
      id: json['expense_id'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      totalAmount: _toDouble(json['total_amount'] ?? json['amount']),
      paidByName: json['paid_by_name'] ?? json['paidByName'] ?? '',
      paidBy: json['paid_by'] ?? json['paidBy'] ?? 0,
      expenseDate:
          DateTime.tryParse(
            (json['expense_date'] ?? json['expenseDate'] ?? '').toString(),
          ) ??
          DateTime.now(),
      splitMethod: json['splitMethod'] ?? json['split_method'] ?? 'equal',
      splits: splitJson.map((e) => AdHocSplit.fromJson(e)).toList(),
    );
  }
}

class Contribution {
  final int id;
  final int memberId;
  final String memberName;
  final double amount;
  final String status;
  final DateTime? contributedAt;
  final String? note;

  Contribution({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.status,
    required this.contributedAt,
    required this.note,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['contribution_id'] ?? json['id'] ?? 0,
      memberId: json['member_id'] ?? json['memberId'] ?? 0,
      memberName: json['member_name'] ?? json['memberName'] ?? '',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      status: json['status'] ?? 'pending',
      contributedAt: json['contributed_at'] != null
          ? DateTime.tryParse(json['contributed_at'].toString())
          : null,
      note: json['note'],
    );
  }
}
