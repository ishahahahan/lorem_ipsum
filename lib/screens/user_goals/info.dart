import 'package:flutter/material.dart';
import 'package:lorem_ipsum/main.dart';
import 'package:lorem_ipsum/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  static const String id = '/bmi';

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _desiredWeightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _desiredWeightController.dispose();
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
                    height: 48,
                  ),
                  Text(
                    'Get Started on Your',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Goals',
                    style: TextStyle(
                        color: Color(0xff2FB555),
                        fontSize: 24,
                        fontWeight: FontWeight.w600),
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
                            height: 30,
                          ),
                          const Text(
                            "Your Name",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "What is your current height?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          TextField(
                            controller: _heightController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Enter height in cm",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "What is your current weight?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          TextField(
                            controller: _currentWeightController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Enter weight in kg",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "What is your desired weight?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          TextField(
                            controller: _desiredWeightController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Enter weight in kg",
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: () async {
                                bool isLoading;
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  final String name =
                                      _nameController.text.trim();
                                  final double height = double.parse(
                                      _heightController.text.trim());
                                  final double currentWeight = double.parse(
                                      _currentWeightController.text.trim());
                                  final double desiredWeight = double.parse(
                                      _desiredWeightController.text.trim());

                                  await supabase.from('user_profile').update({
                                    'name': name,
                                    'height': height,
                                    'weight': currentWeight,
                                    'desired_weight': desiredWeight,
                                  }).eq(
                                      'user_id', supabase.auth.currentUser!.id);

                                  if (mounted) {
                                    Navigator.pushNamedAndRemoveUntil(context,
                                        HomeScreen.id, (route) => false);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
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
}
