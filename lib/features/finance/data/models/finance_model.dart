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

class DebtMemberRef {
  final int memberId;
  final String memberName;

  DebtMemberRef({required this.memberId, required this.memberName});

  factory DebtMemberRef.fromJson(Map<String, dynamic> json) {
    return DebtMemberRef(
      memberId: json['memberId'] ?? json['member_id'] ?? 0,
      memberName: json['memberName'] ?? json['member_name'] ?? '',
    );
  }
}

class DebtPair {
  final DebtMemberRef debtor;
  final DebtMemberRef creditor;
  final double totalOwed;
  final double paidAmount;
  final double remainingAmount;
  final String status;

  DebtPair({
    required this.debtor,
    required this.creditor,
    required this.totalOwed,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
  });

  factory DebtPair.fromJson(Map<String, dynamic> json) {
    return DebtPair(
      debtor: DebtMemberRef.fromJson(json['debtor'] ?? {}),
      creditor: DebtMemberRef.fromJson(json['creditor'] ?? {}),
      totalOwed: _toDouble(json['totalOwed']),
      paidAmount: _toDouble(json['paidAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      status: json['status'] ?? 'pending',
    );
  }
}

class DebtItem {
  final int debtId;
  final int creditorId;
  final String creditorName;
  final int expenseId;
  final double originalAmount;
  final double remainingAmount;
  final String status;
  final String fromExpense;
  final DateTime createdAt;

  DebtItem({
    required this.debtId,
    required this.creditorId,
    required this.creditorName,
    required this.expenseId,
    required this.originalAmount,
    required this.remainingAmount,
    required this.status,
    required this.fromExpense,
    required this.createdAt,
  });

  factory DebtItem.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return DebtItem(
      debtId: json['debtId'] ?? json['debt_id'] ?? 0,
      creditorId: json['creditorId'] ?? json['creditor_id'] ?? 0,
      creditorName: json['creditorName'] ?? json['creditor_name'] ?? '',
      expenseId: _parseInt(json['expenseId'] ?? json['expense_id']),
      originalAmount: _toDouble(
        json['originalAmount'] ?? json['original_amount'],
      ),
      remainingAmount: _toDouble(
        json['remainingAmount'] ?? json['remaining_amount'],
      ),
      status: json['status'] ?? 'pending',
      fromExpense: json['fromExpense'] ?? '',
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

class DebtPayment {
  final int paymentId;
  final int debtId;
  final double amountPaid;
  final DateTime paymentDate;
  final String paymentMethod;
  final bool confirmed;
  final String? confirmedBy;
  final DateTime? confirmedAt;

  DebtPayment({
    required this.paymentId,
    required this.debtId,
    required this.amountPaid,
    required this.paymentDate,
    required this.paymentMethod,
    required this.confirmed,
    this.confirmedBy,
    this.confirmedAt,
  });

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      paymentId: json['paymentId'] ?? json['payment_id'] ?? 0,
      debtId: json['debtId'] ?? json['debt_id'] ?? 0,
      amountPaid: _toDouble(json['amountPaid'] ?? json['amount_paid']),
      paymentDate:
          DateTime.tryParse((json['paymentDate'] ?? '').toString()) ??
          DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? json['payment_method'] ?? '',
      confirmed: json['confirmed'] ?? false,
      confirmedBy: json['confirmedBy'] ?? json['confirmed_by'],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.tryParse(json['confirmedAt'].toString())
          : null,
    );
  }
}
