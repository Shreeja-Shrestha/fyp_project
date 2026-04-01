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

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(password);
  }

  bool isLoading = false;
  bool rememberMe = false;

  Future<void> saveUserSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("user_id", user["id"]);
    await prefs.setString("user_name", user["name"]);
    await prefs.setString("user_email", user["email"]);
    await prefs.setString("user_role", user["role"]);
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showSnackBar("All fields are required");
      return;
    }
    if (!isValidEmail(emailController.text.trim())) {
      _showSnackBar("Enter a valid email address");
      return;
    }
    if (!isValidPassword(passwordController.text)) {
      _showSnackBar(
        "Password must be at least 8 characters with letters and numbers",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.18.11:3000/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text,
        }),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data["user"];
        final role = user["role"];
        await saveUserSession(user);
        _showSnackBar("Login successful");
        final token = data["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['message'] ?? "Login failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showSnackBar("Server not reachable");
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1. IMAGE WITH DEEP UPWARD CURVE
            ClipPath(
              clipper: DeepUpwardCurveClipper(),
              child: Container(
                height:
                    MediaQuery.of(context).size.height *
                    0.38, // Slightly taller to account for the deep curve
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/login.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10), // Reduced since curve is deep

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
                        onChanged: (val) => setState(() => rememberMe = val!),
                      ),
                      Text(
                        "Remember me",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: isLoading ? null : login,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Login", style: TextStyle(color: Colors.white)),
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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

/// THE CLIPPER FOR A VERY DEEP UPWARD CURVE
class DeepUpwardCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);

    // We move the control point much higher (size.height - 120)
    // to create a very deep curve "up" into the image.
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
