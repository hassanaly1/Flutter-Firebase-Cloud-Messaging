import 'dart:async';

import 'package:app/controllers/user_controller.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/views/auth/login.dart';
import 'package:app/views/auth/otp.dart';
import 'package:app/views/auth/signup.dart';
import 'package:app/views/home.dart';
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
  late String _verificationId;

  @override
  void onInit() {
    userController = Get.put(UserController());
    super.onInit();
  }

  Future<void> loginUser() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.loginWithEmailAndPassword(
          emailController.text.trim(), passwordController.text.trim());

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (user.emailVerified) {
          // User is logged in and email is verified
          Get.offAll(() => const HomeScreen());
        } else {
          // User is logged in but email is not verified
          Get.offAll(() => SignupPage());
          Get.snackbar('Error', 'Please verify your email before logging in.');
        }
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUser() async {
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

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.snackbar('Success', 'Logged out successfully');
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void signInWithGoogle() async {
    try {
      isLoading.value = true;
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential.user;

      if (user != null) {
        print('Phone number: ${user.phoneNumber}');
        // Check if the user already exists in Firestore
        final isExistingUser = await userController.checkUserExists(user.uid);

        if (!isExistingUser) {
          // Save user to Firestore if they don't exist
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? '',
            role: 'User',
            phoneNumber: user.phoneNumber ?? '',
            profile: user.photoURL ?? '',
          );
          await userController.addUser(newUser);
        }

        Get.snackbar(
            'Success', 'Signed in with Google and user saved to Firestore');
        // Navigate to another screen if needed
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Start the phone number sign-in process
  void signInWithPhoneNumber(String phoneNumber) async {
    try {
      isLoading.value = true;
      await _authService.signInWithPhoneNumber(phoneNumber,
          (String verificationId) {
        _verificationId = verificationId;
        Get.snackbar(
            'OTP Sent', 'A verification code has been sent to $phoneNumber');
        // Navigate to the OTP input screen, for example:
        Get.to(() => OtpInputScreen());
      });
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Verify the SMS code
  void verifySmsCode(String smsCode) async {
    try {
      isLoading.value = true;
      final userCredential =
          await _authService.verifySmsCode(_verificationId, smsCode);
      final user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in Firestore
        final isExistingUser = await userController.checkUserExists(user.uid);

        if (!isExistingUser) {
          // Save user to Firestore if they don't exist
          final newUser = UserModel(
            uid: user.uid,
            email: user.email ?? '',
            fullName: user.displayName ?? '',
            role: 'User',
            phoneNumber: user.phoneNumber ?? '',
            profile: user.photoURL ?? '',
          );
          await userController.addUser(newUser);
        }

        Get.snackbar('Success', 'Phone number verified and user signed in');
        Get.offAll(() => const HomeScreen());
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
