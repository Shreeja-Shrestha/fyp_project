import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp()); //first widgets flutter holds
}

//statelessidget ley no changing data hold garcha
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({
    super.key,
  }); //parent class ie;statelesswidget lai key pathauxa

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //background handle garxa,body rakhxa,basically, its a screen layout
      // Remove backgroundColor or make it transparent if needed
      backgroundColor: const Color.fromRGBO(255, 255, 255, 0.912),
      body: Container(
        // actutally an empty box jasko through hamle color,size dina sakxam.
        // This container sets the page background if you want something behind everything
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              //  IMAGE WITH CURVED BOTTOM
              ClipPath(
                // since login page ma curve image paste gardaixu tesko lagi shape define garna
                clipper: BottomCurveClipper(),
                child: Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("image.jpg"), // your image here
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Column(
                children: const [
                  Text(
                    "Login to Access Your",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Travel Tickets",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              //  EMAIL INPUT
              _inputField(hint: "enter your email", icon: Icons.email_outlined),

              const SizedBox(height: 15),

              // PASSWORD INPUT
              _inputField(
                hint: "enter your password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 15),

              // REMEMBER and FORGOT
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (v) {}),
                        const Text("Remember me"),
                      ],
                    ),
                    const Text(
                      "Forgot password?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //  LOGIN BUTTON
              Container(
                width: 250,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  Widget _inputField({
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: Icon(icon),
            hintText: hint,
          ),
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
