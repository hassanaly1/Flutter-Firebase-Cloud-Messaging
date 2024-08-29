import 'package:app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Obx(() {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage:
                    NetworkImage(_authController.userModel.value.profile ?? ''),
              ),
            );
          }),
          title: Obx(() {
            return Text(_authController.userModel.value.fullName ?? 'User');
          }),
          backgroundColor: Colors.blueAccent,
          actions: [
            IconButton(
              onPressed: _authController.logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: Text(
              'Welcome, ${_authController.userModel.value.fullName ?? 'User'}!'),
        ),
      ),
    );
  }
}
