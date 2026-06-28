import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void showSuccess(String message) {
    Get.snackbar(
      'موفقیت',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String message) {
    Get.snackbar(
      'خطا',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
