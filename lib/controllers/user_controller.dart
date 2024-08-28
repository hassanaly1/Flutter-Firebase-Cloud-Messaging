import 'package:app/models/user_model.dart';
import 'package:app/utils/exceptions/firebase_auth_exceptions.dart';
import 'package:app/utils/exceptions/firebase_exceptions.dart';
import 'package:app/utils/exceptions/format_exceptions.dart';
import 'package:app/utils/exceptions/platform_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new user to Firestore
  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('Users').doc(user.uid).set(user.toMap());
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong, please try again later.';
    }
  }

  // Update an existing user in Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
      Get.snackbar('Success', 'User updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      Get.snackbar('Success', 'User deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Fetch a single user
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc);
      } else {
        Get.snackbar('Error', 'User not found');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // Fetch all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) => UserModel.fromJson(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }

  // Check if a user exists in Firestore
  Future<bool> checkUserExists(String uid) async {
    try {
      final doc = await _firestore.collection('Users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      Get.snackbar('Error', 'Failed to check user existence: $e');
      return false;
    }
  }
}
