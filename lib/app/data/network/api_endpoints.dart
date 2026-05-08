class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh-token';

  // User
  static const String profile = '/users/profile';
  static const String profileAvatar = '/users/profile/avatar';

  // Categories
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // Expenses
  static const String expenses = '/expenses';
  static String expenseById(String id) => '/expenses/$id';
  static String expenseReceipt(String id) => '/expenses/$id/receipt';

  // Budgets
  static const String budgets = '/budgets';
  static String budgetById(String id) => '/budgets/$id';

  // Dashboard
  static const String dashboard = '/dashboard';

  // AI Extract
  static const String aiExtractReceipt = '/ai-extract/receipt';
  static const String aiExtractText = '/ai-extract/text';
}
