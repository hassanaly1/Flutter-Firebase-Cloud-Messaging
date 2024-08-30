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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var allUsers = <UserModel>[].obs;

  // Add a new user to Firestore
  Future<void> addUser(UserModel user) async {
    try {
      print('Attempting to add user: ${user.toMap()}');
      await _firestore.collection('Users').doc(user.uid).set(user.toMap());
      print('User added successfully');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      print('FirebaseException: ${e.code}');
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      print('FormatException');
      throw const MyFormatException();
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code}');
      throw MyPlatformException(e.code).message;
    } catch (e) {
      print('Unknown error: $e');
      throw 'Something went wrong, please try again later.';
    }
  }

  // Update an existing user in Firestore
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('Users').doc(user.uid).update(user.toMap());
      Get.snackbar('Success', 'User updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('Users').doc(uid).delete();
      // await AuthController().deleteProfileImage(userModel.value.profile!);
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
          await _firestore.collection('Users').doc(uid).get();
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
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .where('uid', isNotEqualTo: _auth.currentUser!.uid)
          .get();
      return allUsers.value =
          querySnapshot.docs.map((doc) => UserModel.fromJson(doc)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
      return [];
    }
  }

  Stream<List<UserModel>> getAllUsersByStream() {
    return _firestore
        .collection('Users')
        .where('uid', isNotEqualTo: _auth.currentUser!.uid)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return UserModel.fromJson(doc);
      }).toList();
    });
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
