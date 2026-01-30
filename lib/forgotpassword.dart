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

  // STEP 1: Request the OTP
  Future<void> requestOtp() async {
    if (emailController.text.isEmpty) {
      _showSnackBar("Please enter your email");
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/auth/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() => isOtpSent = true);
        _showSnackBar("OTP sent to your email");
      } else {
        _showSnackBar("User not found or server error");
      }
    } catch (e) {
      _showSnackBar("Server not reachable");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // STEP 2: Verify OTP and Reset Password
  Future<void> resetPassword() async {
    if (otpController.text.isEmpty || newPasswordController.text.isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3000/api/auth/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "otp": otpController.text.trim(),
          "newPassword": newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Password reset successful! Please login.");
        Navigator.pop(context); // Go back to Login
      } else {
        _showSnackBar("Invalid or expired OTP");
      }
    } catch (e) {
      _showSnackBar("Error connecting to server");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
                  ? "Enter the code sent to ${emailController.text}"
                  : "Enter your email to receive a password reset code",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // EMAIL FIELD (Always visible)
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
