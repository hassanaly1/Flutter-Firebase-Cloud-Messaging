import 'package:app/controllers/auth_controller.dart';
import 'package:app/views/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  await authController.pickProfileImage();
                },
                child: Obx(
                  () => CircleAvatar(
                    radius: 50,
                    backgroundImage: authController.profileImage.value.path !=
                            ''
                        ? FileImage(authController.profileImage.value)
                        : const NetworkImage(
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: authController.fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
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
                        authController.registerUser();
                      },
                      child: const Text('Sign Up'),
                    )),
              TextButton(
                onPressed: () {
                  Get.to(() => const LoginPage());
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
