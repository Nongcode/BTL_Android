import 'package:flutter/foundation.dart';

/// Simple cross-screen notifier to signal finance data changes.
class FinanceSync {
  FinanceSync._();

  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static void bump() {
    version.value = version.value + 1;
  }
}
