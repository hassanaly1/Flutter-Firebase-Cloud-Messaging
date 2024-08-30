import 'dart:io';

import 'package:app/controllers/auth_controller.dart';
import 'package:app/controllers/user_controller.dart';
import 'package:app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

final ImagePicker _picker = ImagePicker();
final Rx<File?> _profileImage = Rx<File?>(null);
final Rxn<String?> _profileImageUrl = Rxn<String?>(null);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AuthController _authController;
  late UserController _userController;

  void _fetchCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final userDoc = await _firestore.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        _authController.userModel.value = UserModel.fromJson(userDoc);
      }
    }
  }

  @override
  void initState() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        // Get.offAll(() => const LoginPage());
        // Get.snackbar('OOPS', 'login Session Expired, Please login again');
      } else {
        print('User is currently signed in!');
        _fetchCurrentUser();
      }
    });
    if (Get.isRegistered<AuthController>()) {
      _authController = Get.find();
      _userController = Get.find();
    } else {
      _authController = Get.put(AuthController());
      _userController = Get.find();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          title: const Text('Home'),
          actions: [
            IconButton(
              onPressed: _authController.logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () {
              if (_authController.userModel.value.fullName == null) {
                return const MyListTileShimmerEffect();
              } else {
                return Column(
                  children: [
                    MyCustomListTile(user: _authController.userModel.value),
                    const Divider(thickness: 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const IconButton(
                            onPressed: null,
                            icon: Icon(
                              CupertinoIcons.add,
                              color: Colors.transparent,
                            )),
                        Text(
                          'My Users',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          onPressed: () {
                            _showUserDialog(context: context);
                          },
                          icon: const Icon(CupertinoIcons.add),
                        ),
                      ],
                    ),
                    Expanded(
                        child: StreamBuilder<List<UserModel>>(
                      stream: _userController.getAllUsersByStream(),
                      builder:
                          (context, AsyncSnapshot<List<UserModel>> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong');
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const MyListTileShimmerEffect();
                        } else {
                          final users = snapshot.data;
                          return users!.isEmpty
                              ? Image.network(
                                  'https://cdni.iconscout.com/illustration/premium/thumb/user-not-found-illustration-download-in-svg-png-gif-file-formats--no-absence-search-failure-empty-states-pack-science-technology-illustrations-7882965.png?f=webp')
                              : ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final user = users[index];
                                    return MyCustomListTile(user: user);
                                  },
                                );
                        }
                      },
                    ))
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class MyCustomListTile extends StatefulWidget {
  const MyCustomListTile({
    super.key,
    required this.user,
  });

  final UserModel? user;

  @override
  State<MyCustomListTile> createState() => _MyCustomListTileState();
}

class _MyCustomListTileState extends State<MyCustomListTile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showDeleteConfirmationDialog({required UserModel user}) {
    final userController = Get.find<UserController>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text('Are you sure you want to delete ${user.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                userController.deleteUser(user.uid ?? '');
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: widget.user?.profile != '' &&
                widget.user?.profile != null
            ? NetworkImage(widget.user?.profile ?? '')
            : const NetworkImage(
                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
      ),
      title: Text(
        widget.user?.fullName ?? 'Progziel Technologies',
        maxLines: 1,
      ),
      subtitle: Text(
        widget.user?.email ?? 'progiel@gmail.com',
        maxLines: 1,
      ),
      trailing: Visibility(
        visible: widget.user?.uid != _auth.currentUser?.uid,
        child: Wrap(
          children: [
            IconButton(
              onPressed: () {
                _showUserDialog(user: widget.user, context: context);
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () {
                _showDeleteConfirmationDialog(user: widget.user!);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyListTileShimmerEffect extends StatelessWidget {
  const MyListTileShimmerEffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: const Color(0xffE6E8EB),
        highlightColor: const Color(0xffF9F9FB),
        child: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            titleAlignment: ListTileTitleAlignment.top,
            leading: Shimmer.fromColors(
              baseColor: const Color(0xffE6E8EB),
              highlightColor: const Color(0xffF9F9FB),
              child: const CircleAvatar(
                radius: 30,
              ),
            ),
            title: Shimmer.fromColors(
              baseColor: const Color(0xffE6E8EB),
              highlightColor: const Color(0xffF9F9FB),
              child: Container(
                width: 150,
                height: 15,
                color: Colors.white,
              ),
            ),
            subtitle: Shimmer.fromColors(
              baseColor: const Color(0xffE6E8EB),
              highlightColor: const Color(0xffF9F9FB),
              child: Container(
                width: 150,
                height: 10,
                color: Colors.white70,
              ),
            ),
          ),
        ));
  }
}

void _showUserDialog({required BuildContext context, UserModel? user}) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final fullNameController = TextEditingController(text: user?.fullName ?? '');
  final emailController = TextEditingController(text: user?.email ?? '');

  final userController = Get.find<UserController>();

  // Initialize profile image URL
  if (user != null && user.profile != null && user.profile!.isNotEmpty) {
    _profileImageUrl.value = user.profile!;
  } else {
    _profileImageUrl.value = null;
    _profileImage.value = null;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(user == null ? 'Add User' : 'Update User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () async {
                await _pickProfileImage();
              },
              child: Obx(
                () {
                  // Display the image based on the available data
                  if (_profileImage.value != null) {
                    // Display selected local image
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_profileImage.value!),
                    );
                  } else if (_profileImageUrl.value != null) {
                    // Display user's existing profile image from URL
                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_profileImageUrl.value!),
                    );
                  } else {
                    // Display default placeholder image
                    return const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                      ),
                    );
                  }
                },
              ),
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String? profileImageUrl;

              // Check if a new image is selected
              if (_profileImage.value != null) {
                // Delete the previous profile image if it exists
                if (user?.profile != null && user!.profile!.isNotEmpty) {
                  await _deleteProfileImage(user.profile!);
                }

                // Upload the new profile image and get the new URL
                profileImageUrl = await _uploadProfileImage(
                    user?.uid ?? firestore.collection('Users').doc().id);

                // Ensure that the new URL is not null
                if (profileImageUrl != null) {
                  _profileImageUrl.value = profileImageUrl; // Update observable
                }
              } else {
                // Use the existing profile image URL if no new image is selected
                profileImageUrl = user?.profile;
              }

              // Update or add user data to Firestore
              if (user == null) {
                // For new user
                String uid = firestore
                    .collection('Users')
                    .doc()
                    .id; // Generate a unique ID
                userController.addUser(
                  UserModel(
                    uid: uid,
                    fullName: fullNameController.text,
                    email: emailController.text,
                    profile: profileImageUrl,
                  ),
                );
              } else {
                // For updating existing user
                userController.updateUser(
                  UserModel(
                    uid: user.uid,
                    fullName: fullNameController.text,
                    email: emailController.text,
                    profile: profileImageUrl,
                  ),
                );
              }

              Navigator.of(context).pop();
            },
            child: Text(user == null ? 'Add' : 'Update'),
          ),
        ],
      );
    },
  );
}

// Function to pick a profile image from the gallery
Future<void> _pickProfileImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    _profileImage.value = File(pickedFile.path);
    _profileImageUrl.value = null; // Clear the URL when a new image is selected
    print('Image selected: ${_profileImage.value?.path}');
  } else {
    Get.snackbar('Error', 'No image selected');
  }
}

// Upload Profile Image to Firebase Storage
Future<String?> _uploadProfileImage(String userId) async {
  try {
    if (_profileImage.value == null) return null; // No image selected

    // Get reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child('profiles/$userId');

    // Upload the file
    final uploadTask = await storageRef.putFile(_profileImage.value!);

    // Get the download URL of the uploaded file
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    return downloadUrl;
  } catch (e) {
    Get.snackbar('Error', 'Failed to upload image');
    return null;
  }
}

// Delete the previous profile image from Firebase Storage
Future<void> _deleteProfileImage(String imageUrl) async {
  try {
    final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);

    await storageRef.delete();
  } catch (e) {
    Get.snackbar('Error', 'Failed to delete old profile image: $e');
  }
}
