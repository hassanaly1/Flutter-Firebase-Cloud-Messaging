import 'package:app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpInputScreen extends StatelessWidget {
  final AuthController authController = Get.find();
  final TextEditingController smsCodeController = TextEditingController();

  OtpInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: smsCodeController,
              decoration: const InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                authController.verifySmsCode(smsCodeController.text.trim());
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
