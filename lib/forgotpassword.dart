import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isOtpSent = false;
  bool isLoading = false;

  Future<void> requestOtp() async {
    if (emailController.text.trim().isEmpty) {
      _showSnackBar("Please enter your email");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/auth/forgot-password",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => isOtpSent = true);
        _showSnackBar(data["message"] ?? "OTP sent to your email");
      } else {
        _showSnackBar(data["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      _showSnackBar("Server not reachable");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> resetPassword() async {
    if (otpController.text.trim().isEmpty ||
        newPasswordController.text.isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$',
    );

    if (!passwordRegex.hasMatch(newPasswordController.text)) {
      _showSnackBar(
        "Password must be at least 8 characters with letters and numbers",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "https://backend-production-551c.up.railway.app/api/auth/reset-password",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "newPassword": newPasswordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showSnackBar(data["message"] ?? "Password reset successful");
        Navigator.pop(context);
      } else {
        _showSnackBar(data["message"] ?? "Password reset failed");
      }
    } catch (e) {
      _showSnackBar("Error connecting to server");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9fd),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOtpSent ? "Verify OTP" : "Forgot Password",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              isOtpSent
                  ? "Enter the code sent to ${emailController.text.trim()}"
                  : "Enter your email to receive a password reset code",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _buildField(
              emailController,
              Icons.email_outlined,
              "Email Address",
              enabled: !isOtpSent,
            ),

            if (isOtpSent) ...[
              const SizedBox(height: 15),
              _buildField(otpController, Icons.vibration, "Enter 6-digit OTP"),
              const SizedBox(height: 15),
              _buildField(
                newPasswordController,
                Icons.lock_outline,
                "New Password",
                isPassword: true,
              ),
            ],

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : (isOtpSent ? resetPassword : requestOtp),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isOtpSent ? "Reset Password" : "Send OTP",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    IconData icon,
    String hint, {
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade200,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
