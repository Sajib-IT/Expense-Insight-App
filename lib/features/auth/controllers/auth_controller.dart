import 'package:get/get.dart';

class AuthController extends GetxController {
  // Observables
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // TODO: Add login/register logic when API is provided

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }
}

