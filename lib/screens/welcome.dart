import 'package:flutter/material.dart';
import 'package:lorem_ipsum/auth/signin.dart';
import 'package:lorem_ipsum/auth/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String id = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/welcome.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 4),
                const SizedBox(
                  height: 140,
                ),
                // Title Text
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Build\n',
                        style: TextStyle(color: Colors.black, fontSize: 70),
                      ),
                      TextSpan(
                        text: 'healthy\n',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 70,
                        ),
                      ),
                      TextSpan(
                        text: 'habits',
                        style: TextStyle(color: Colors.black, fontSize: 70),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 3),
                // Let's Start Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, SignInScreen.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Let's Start",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign up text
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        WidgetSpan(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, SignUpScreen.id);
                            },
                            child: Text(
                              'Sign up here',
                              style: TextStyle(
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
