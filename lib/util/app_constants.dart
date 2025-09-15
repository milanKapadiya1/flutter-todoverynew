import 'package:flutter/material.dart';

class AppConstans {
  AppConstans._();

  static showSnackBar(
    BuildContext context, {
    required String message,
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isSuccess
            ? const Color.fromARGB(255, 23, 238, 113)
            : const Color.fromARGB(255, 158, 16, 6),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
