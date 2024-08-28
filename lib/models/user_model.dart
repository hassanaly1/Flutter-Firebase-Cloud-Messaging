import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? email;
  String? fullName;
  String? role;
  String? profile;
  String? phoneNumber;

  UserModel(
      {this.uid,
      this.email,
      this.fullName,
      this.role,
      this.profile,
      this.phoneNumber});

  // Convert UserModel to a map to send to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role,
      'profile': profile,
      'phoneNumber': phoneNumber
    };
  }

  // Create a UserModel from a Firestore document
  factory UserModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      fullName: data['fullName'],
      role: data['role'],
      profile: data['profile'],
      phoneNumber: data['phoneNumber'],
    );
  }
}
