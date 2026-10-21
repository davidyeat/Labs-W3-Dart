// HINT: how to reject a wrong call, and how to test it.
// Not part of the LMS: same syntax, different topic.
import 'package:test/test.dart';

class Wallet {
  double balance = 0;

  void pay(double amount) {
    // Rule: you can't pay more than you have
    if (amount > balance) {
      throw Exception('Not enough money');
    }
    balance -= amount;
  }
}

void main() {
  test('pay reduces the balance', () {
    final wallet = Wallet();
    wallet.balance = 100;
    wallet.pay(30);
    expect(wallet.balance, 70);
  });

  test('paying more than the balance is rejected', () {
    final wallet = Wallet();
    expect(() => wallet.pay(50), throwsException);
    expect(wallet.balance, 0); // nothing changed
  });
}
