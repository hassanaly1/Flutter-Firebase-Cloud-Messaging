import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

class MyCustomToast {
  final String text;
  final Color backgroundColor;

  MyCustomToast({
    required this.text,
    required this.backgroundColor,
  });

  void show(BuildContext context) {
    final toast = ToastCard(
      leading: const Icon(
        Icons.flutter_dash,
        size: 28,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );

    DelightToastBar(
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: toast,
      ),
    ).show(context);
  }
}
