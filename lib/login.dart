import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'home.dart';
import 'signup.dart';
import 'forgotpassword.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false;

  static const String loginUrl =
      "https://backend-production-551c.up.railway.app/api/auth/login";

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> saveUserSession(Map<String, dynamic> user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("user_id", int.tryParse(user["id"].toString()) ?? 0);
    await prefs.setString("user_name", user["name"]?.toString() ?? "");
    await prefs.setString("user_email", user["email"]?.toString() ?? "");
    await prefs.setString("user_role", user["role"]?.toString() ?? "user");
    await prefs.setString("token", token);
    await prefs.setBool("remember_me", rememberMe);
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }

    if (!isValidEmail(email)) {
      _showSnackBar("Enter a valid email address");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data["user"];
        final token = data["token"]?.toString() ?? "";

        if (user == null || token.isEmpty) {
          _showSnackBar("Invalid login response");
          return;
        }

        await saveUserSession(user, token);

        if (!mounted) return;

        _showSnackBar("Login successful");

        final role = user["role"]?.toString() ?? "user";

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                role == "admin" ? const AdminDashboardPage() : const HomePage(),
          ),
        );
      } else {
        _showSnackBar(data["message"]?.toString() ?? "Login failed");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Server not reachable");
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
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ClipPath(
              clipper: DeepUpwardCurveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.38,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/login.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Login to Access Your",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const Text(
              "Travel Tickets",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xff1a73e8),
              ),
            ),

            const SizedBox(height: 30),

            _inputField(
              "enter your email",
              Icons.email_outlined,
              emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 15),

            _inputField(
              "enter your password",
              Icons.lock_outline,
              passwordController,
              obscure: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (val) {
                          setState(() => rememberMe = val ?? false);
                        },
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    disabledBackgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xff1a73e8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
        onSubmitted: (_) {
          if (obscure && !isLoading) login();
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Theme.of(context).iconTheme.color),
          hintText: hint,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class DeepUpwardCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();

    path.lineTo(0, size.height);

    path.quadraticBezierTo(
      size.width / 2,
      size.height - 130,
      size.width,
      size.height,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
