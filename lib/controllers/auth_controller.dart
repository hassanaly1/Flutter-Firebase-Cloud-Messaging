import 'dart:async';

import 'package:app/controllers/user_controller.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/views/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoading = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  late UserController userController;

  @override
  void onInit() {
    userController = Get.put(UserController());
    super.onInit();
  }

  void registerUser() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.registerWithEmailAndPassword(
          emailController.text.trim(), passwordController.text.trim());
      final user = userCredential.user;

      if (user != null) {
        // Send verification email
        await user.sendEmailVerification();
        Get.snackbar('Verification Sent',
            'Please check your email to verify your account.');

        // Start checking email verification status
        _checkEmailVerified();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _checkEmailVerified() {
    isLoading.value = true;
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user?.emailVerified ?? false) {
        timer.cancel();
        isLoading.value = false;
        Get.snackbar('Email Verified Successfully', 'Please login.');
        Get.offAll(() => LoginPage());

        // Save user to Firestore
        final newUser = UserModel(
          uid: user?.uid ?? '',
          email: emailController.text.trim(),
          fullName: fullNameController.text.trim(),
          role: 'User',
          phoneNumber: '',
          profile: '',
        );
        try {
          await userController.addUser(newUser);
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      }
    });
  }
}
