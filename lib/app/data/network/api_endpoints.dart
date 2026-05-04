class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';

  // User
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Expenses
  static const String expenses = '/expenses';
  static const String expenseById = '/expenses/'; // append id
  static const String expenseCategories = '/expenses/categories';
  static const String expenseSummary = '/expenses/summary';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';
}

