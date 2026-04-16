import 'package:flutter_demo/ui/demos/3_state_management/state_management_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('number notifier starts at 1', () {
    final manager = StateManagementManager();
    final number = manager.numberNotifier.value;
    expect(number, 1);
  });
}