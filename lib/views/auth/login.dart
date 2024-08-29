import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/auth/forget_password.dart';
import 'package:app/views/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: authController.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: authController.passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        authController.loginUser();
                      },
                      child: const Text('Login'),
                    )),
              TextButton(
                onPressed: () {
                  Get.to(() => ForgetPasswordScreen());
                },
                child: const Text('Forget Password?'),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  Get.to(() => const SignupPage());
                },
                child: const Text('Don\'t have an account? Sign Up'),
              ),
              const SizedBox(height: 120),
              Obx(() => authController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        authController.signInWithGoogle();
                      },
                      child: const Text('Sign In With Google'),
                    )),
              ElevatedButton(
                onPressed: () {
                  authController.signInWithPhoneNumber('+923162136653');
                },
                child: const Text('Sign In with Phone Number'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
