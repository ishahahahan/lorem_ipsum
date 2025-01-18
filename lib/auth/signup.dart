import 'package:flutter/material.dart';
import 'package:lorem_ipsum/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String id = '/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 60, left: 30, right: 30, bottom: 30),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sign Up',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Let\'s sign up to your account and start your calorie management',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color(0xFF90EE90), // Light green
                    Color(0xFFFFFF8D),
                  ]),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 60,
                          ),
                          _buildInputField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'Enter Email',
                            isRequired: true,
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Enter Password',
                            isRequired: true,
                            isPassword: true,
                          ),
                          const SizedBox(height: 80),
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final email = _emailController.text.trim();
                                  final password =
                                      _passwordController.text.trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    return;
                                  }

                                  try {
                                    // Attempt to sign in
                                    final AuthResponse res =
                                        await supabase.auth.signUp(
                                      email: email,
                                      password: password,
                                    );

                                    final Session? session = res.session;
                                    final User? user = res.user;

                                    if (session == null || user == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Check your email for verification"),
                                        ),
                                      );
                                    } else {
                                      // Navigator.pushReplacementNamed(context, MainScreen.id);
                                      print("User: $user");
                                    }
                                  } on AuthException catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.message),
                                      ),
                                    );
                                  } catch (e) {
                                    // Handle other exceptions
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('An error occurred'),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                ),
              ),
          ],
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black54,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black38,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black38,
                width: 1.0,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 20),
          ),
        ),
      ],
    );
  }
}
