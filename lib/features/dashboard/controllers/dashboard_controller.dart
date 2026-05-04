import 'package:get/get.dart';
import 'package:expense_insight/app/common/widgets/custom_snackbar.dart';
import 'package:expense_insight/app/data/models/dashboard_model.dart';
import 'package:expense_insight/app/data/network/api_exceptions.dart';
import 'package:expense_insight/features/dashboard/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository = DashboardRepository();

  final isLoading = false.obs;
  final Rx<DashboardModel?> dashboard = Rx<DashboardModel?>(null);
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      final response = await _repository.getDashboard(
        month: selectedMonth.value,
        year: selectedYear.value,
      );

      if (response['success'] == true && response['data'] != null) {
        dashboard.value = DashboardModel.fromJson(response['data']);
      }
    } catch (e) {
      CustomSnackbar.error(ApiExceptions.handleError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    fetchDashboard();
  }

  void previousMonth() {
    if (selectedMonth.value == 1) {
      selectedMonth.value = 12;
      selectedYear.value--;
    } else {
      selectedMonth.value--;
    }
    fetchDashboard();
  }

  void nextMonth() {
    if (selectedMonth.value == 12) {
      selectedMonth.value = 1;
      selectedYear.value++;
    } else {
      selectedMonth.value++;
    }
    fetchDashboard();
  }
}

