class PaymentService {
  /// Simulates a secure payment flow without requiring a backend or Stripe keys.
  Future<bool> makePayment(double amount, String currency) async {
    try {
      // Simulate network delay for "Creating Payment Intent"
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate Stripe Payment Sheet presentation and processing
      await Future.delayed(const Duration(seconds: 2));
      
      // In a mock flow, we return true to indicate success.
      // You can change this to false to test the failure/cancellation UI.
      return true;
    } catch (e) {
      return false;
    }
  }
}
