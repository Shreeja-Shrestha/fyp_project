import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProfilePage extends StatefulWidget {
  final int userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  bool isLoading = true; // start loading

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    bioController = TextEditingController();

    loadProfile();
  }

  /// 🔥 LOAD USER DATA
  Future<void> loadProfile() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.18.11:3000/api/users/profile/${widget.userId}",
        ),
      );

      final data = jsonDecode(response.body);

      setState(() {
        nameController.text = data["name"] ?? "";
        emailController.text = data["email"] ?? "";
        phoneController.text = data["phone"] ?? "";
        bioController.text = data["tagline"] ?? "";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  /// 🔥 PROFILE COMPLETION
  int getCompletion() {
    int total = 4;
    int filled = 0;

    if (nameController.text.isNotEmpty) filled++;
    if (emailController.text.isNotEmpty) filled++;
    if (phoneController.text.isNotEmpty) filled++;
    if (bioController.text.isNotEmpty) filled++;

    return ((filled / total) * 100).toInt();
  }

  /// 🔥 UPDATE PROFILE
  Future<void> updateProfile() async {
    /// VALIDATION
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Name is required")));
      return;
    }

    if (!emailController.text.contains("@")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid email")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.put(
        Uri.parse("http://192.168.18.11:3000/api/users/update"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": widget.userId,
          "name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "tagline": bioController.text,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true); // refresh profile page
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Update failed")));
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completion = getCompletion();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// PROFILE COMPLETION
                  Column(
                    children: [
                      Text("Profile $completion% complete"),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: completion / 100),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// EMAIL
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// PHONE
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// BIO
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      border: OutlineInputBorder(),
                      hintText: "Tell us about yourself",
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 20),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : updateProfile,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Update Profile"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
