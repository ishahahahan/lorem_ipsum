import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lorem_ipsum/main.dart';
import 'package:lorem_ipsum/screens/activity_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:pie_chart/pie_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String id = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  bool mounted = true;

  @override
  void dispose() {
    mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F6F6), Color(0xFFF6F6F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with greeting and notification
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main calorie card
                      _buildCalorieCard(),
                      const SizedBox(height: 20),

                      // Macronutrients row
                      _buildMacronutrientsRow(),
                      const SizedBox(height: 20),

                      const Text(
                        'Your Meal Log',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 10),

                      // Meal log section
                      _buildMealLogSection(),
                    ],
                  ),
                ),
              ),

              // Bottom navigation bar
              _buildBottomNavigationBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<double> _calculateCalories() async {
    final res = await supabase.from('food_intake').select('calories');

    if (res.isEmpty) {
      return 0.0;
    }
    double calories = res[0]['calories'];

    return calories;
  }

  Widget _buildCalorieCard() {
    return FutureBuilder<double>(
      future: _calculateCalories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          double calories = snapshot.data ?? 0.0;
          print('Calories: $calories');
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Goal',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    '4537 cal',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildPieChart({
                            'Consumed': (1282 + calories).toDouble(),
                            'Remaining': (4537 - 1282 - calories).toDouble(),
                          }, [
                            Colors.orange,
                            Colors.grey[200] ?? Colors.grey
                          ], 60, 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(4537 - 1282 - calories).toInt()}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Calories left',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMacronutrientsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMacroCard('Carbs', 97, 237, 140, Colors.orange),
        _buildMacroCard('Protein', 40, 93, 53, Colors.red),
        _buildMacroCard('Fat', 43, 63, 20, Colors.green),
      ],
    );
  }

  Widget _buildPieChart(
    Map<String, double> dataMap,
    List<Color> colorList,
    double radius,
    double ringStrokeWidth,
  ) {
    return SizedBox(
      width: 200,
      height: 200,
      child: PieChart(
        chartType: ChartType.ring,
        chartRadius: radius,
        colorList: colorList,
        initialAngleInDegree: 270,
        ringStrokeWidth: ringStrokeWidth,
        legendOptions: const LegendOptions(
          showLegends: false,
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: false,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
        ),
        dataMap: dataMap,
      ),
    );
  }

  Widget _buildMacroCard(
    String title,
    int value,
    int total,
    int left,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPieChart(
                    {
                      'Consumed': (total - left).toDouble(),
                      'Remaining': left.toDouble(),
                    },
                    [color, Colors.grey[200] ?? Colors.grey],
                    40,
                    5,
                  ),
                  Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '/${total}g',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            Text(
              '${left}g left',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<Map<String, dynamic>>> _buildMealLogSection() {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.value([]),
        builder: (context, snapshot) {
          return const Center(
            child: Text('Please sign in to view your meal log'),
          );
        },
      );
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: supabase
          .from('food_intake')
          .select()
          .eq('user_id', user.id)
          .order('meal_time', ascending: false)
          .then((response) => response),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final data = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data
              .map(
                (item) => _buildMealCard(
                  'assets/images/burger.png',
                  '${item['calories'].toInt()} cal',
                  item['meal_time'].toString(),
                  [
                    'Carbs: ${item['carbohydrates'].toInt()}g',
                    'Protein: ${item['protein'].toInt()}g',
                    'Fat: ${item['fats'].toInt()}g',
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

Widget _buildMealCard(
  String imagePath,
  String calories,
  String time,
  List<String> nutrients, {
  bool isSelected = false,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      border: isSelected
          ? Border.all(color: const Color(0xFF4CAF50), width: 2)
          : null,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        // Format time,
                        time.substring(12, 16),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8,
                    children: nutrients
                        .map(
                          (nutrient) => Text(
                            '• $nutrient',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBottomNavigationBar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home, true, context, false),
        _buildNavItem(Icons.fitness_center, false, context, false),
        _buildCircularNavItem(context),
        _buildNavItem(Icons.bar_chart, false, context, false),
        _buildNavItem(Icons.person_outline, false, context, true),
      ],
    ),
  );
}

Widget _buildNavItem(
    IconData icon, bool isSelected, BuildContext context, bool logout) {
  return InkWell(
    child: Icon(
      icon,
      size: 28,
      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
    ),
    onTap: () {
      if (logout) {
        supabase.auth.signOut();
        Navigator.pushNamed(context, '/');
        return;
      }
      isSelected = true;

      Navigator.pushNamed(context, ActivityScreen.id);
    },
  );
}

Widget _buildCircularNavItem(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.3,
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  print('Scan food');
                  Map<String, dynamic> nutritionData = {};
                  bool isLoading = false;
                  try {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );

                    if (image != null) {
                      nutritionData = {};
                      print('image selected: ${image.path}');

                      var uri = Uri.parse('http://10.79.9.136:5000/predict');
                      print('uri: $uri');

                      var request = http.MultipartRequest(
                        'POST',
                        uri,
                      );

                      var stream = http.ByteStream(image.openRead());
                      var length = await image.length();

                      var multipartFile = http.MultipartFile(
                          'file', // This name must match 'image' in your Flask code
                          stream,
                          length,
                          filename: image.path.split('/').last);

                      request.files.add(multipartFile);
                      print("sending request");

                      //     var response = await request.send();
                      //     var responseBody =
                      //         await response.stream.bytesToString();

                      //     if (response.statusCode == 200) {
                      //       print('responseBody: $responseBody');
                      //       setState(() {
                      //         nutritionData = jsonDecode(responseBody);
                      //       });
                      //     } else {
                      //       print('Server error: ${response.statusCode}');
                      //       throw HttpException(
                      //           'Server error: ${response.statusCode}');
                      //     }
                      //   }
                      // } catch (e) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Error: ${e.toString()}')),
                      //   );
                      // } finally {
                      //   setState(() {
                      //     isLoading = false;
                      //   });
                      // }

                      try {
                        var streamedResponse = await request.send().timeout(
                          const Duration(seconds: 60),
                          onTimeout: () {
                            throw TimeoutException(
                                'Request timed out after 30 seconds');
                          },
                        );
                        print(
                            'Response received: ${streamedResponse.statusCode}'); // Debug point 9

                        var response =
                            await http.Response.fromStream(streamedResponse);

                        double parseArrayString(String value) {
                          return double.parse(
                              value.replaceAll(RegExp(r'[\[\]]'), ''));
                        }

                        // Alert Dialog Box
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Nutrition Data'),
                                content: Text(
                                    "Calories: ${parseArrayString(nutritionData['calories'])}\n"
                                    "Carbs: ${parseArrayString(nutritionData['carbohydrates'])}\n"
                                    "Protein: ${parseArrayString(nutritionData['protein'])}\n"
                                    "Fat: ${parseArrayString(nutritionData['fat'])}"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        print('object');
                                        final now =
                                            DateTime.now().toIso8601String();

                                        final data = {
                                          'user_id':
                                              supabase.auth.currentUser!.id,
                                          'calories': parseArrayString(
                                              nutritionData['calories']
                                                  .toString()),
                                          'carbohydrates': parseArrayString(
                                              nutritionData['carbohydrates']
                                                  .toString()),
                                          'protein': parseArrayString(
                                              nutritionData['protein']
                                                  .toString()),
                                          'fats': parseArrayString(
                                              nutritionData['fat'].toString()),
                                          'meal_time': now,
                                          'created_at': now,
                                        };

                                        await supabase
                                            .from('food_intake')
                                            .insert([data]);

                                        print('77');
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Food intake recorded')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            });
                        print(
                            'Response body: ${response.body}'); // Debug point 10

                        if (response.statusCode == 200) {
                          nutritionData = jsonDecode(response.body);
                          print(
                              'Data processed successfully'); // Debug point 11
                        } else {
                          throw HttpException(
                              'Server error: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Network error: $e'); // Debug point 12
                        rethrow;
                      }
                    }
                  } catch (e) {
                    print('Error occurred: $e'); // Debug point 13
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    isLoading = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Scan food',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> nutritionData = {};
                  bool isLoading = false;
                  try {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );

                    if (image != null) {
                      isLoading = true;
                      nutritionData = {};

                      print('image selected: ${image.path}');

                      var uri = Uri.parse('http://10.79.9.136:6000/predict');
                      print('uri: $uri');

                      var request = http.MultipartRequest(
                        'POST',
                        uri,
                      );

                      var stream = http.ByteStream(image.openRead());
                      var length = await image.length();

                      var multipartFile = http.MultipartFile(
                          'file', // This name must match 'image' in your Flask code
                          stream,
                          length,
                          filename: image.path.split('/').last);

                      request.files.add(multipartFile);
                      print("sending request");

                      //     var response = await request.send();
                      //     var responseBody =
                      //         await response.stream.bytesToString();

                      //     if (response.statusCode == 200) {
                      //       print('responseBody: $responseBody');
                      //       setState(() {
                      //         nutritionData = jsonDecode(responseBody);
                      //       });
                      //     } else {
                      //       print('Server error: ${response.statusCode}');
                      //       throw HttpException(
                      //           'Server error: ${response.statusCode}');
                      //     }
                      //   }
                      // } catch (e) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(content: Text('Error: ${e.toString()}')),
                      //   );
                      // } finally {
                      //   setState(() {
                      //     isLoading = false;
                      //   });
                      // }

                      try {
                        var streamedResponse = await request.send().timeout(
                          const Duration(seconds: 30),
                          onTimeout: () {
                            throw TimeoutException(
                                'Request timed out after 30 seconds');
                          },
                        );
                        print(
                            'Response received: ${streamedResponse.statusCode}'); // Debug point 9

                        var response =
                            await http.Response.fromStream(streamedResponse);
                        print(
                            'Response body: ${response.body}'); // Debug point 10

                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('${nutritionData['name']}'),
                                content: Text(
                                    "Calories: ${nutritionData['calories']}\n"
                                    "Carbs: ${nutritionData['carbohydrates']}\n"
                                    "Protein: ${nutritionData['protein']}\n"
                                    "Fat: ${nutritionData['fat']}"),
                                actions: [
                                  TextButton(
                                    onPressed: () async {
                                      try {
                                        final now =
                                            DateTime.now().toIso8601String();

                                        final data = {
                                          'user_id':
                                              supabase.auth.currentUser!.id,
                                          'calories': nutritionData['calories'],
                                          'carbohydrates':
                                              nutritionData['carbohydrates'],
                                          'protein': nutritionData['protein'],
                                          'fats': nutritionData['fat'],
                                          'meal_time': now,
                                          'created_at': now,
                                        };

                                        await supabase
                                            .from('food_intake')
                                            .insert([data]);

                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Food intake recorded')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                              );
                            });

                        if (response.statusCode == 200) {
                          nutritionData = jsonDecode(response.body);

                          print(
                              'Data processed successfully'); // Debug point 11
                        } else {
                          throw HttpException(
                              'Server error: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Network error: $e'); // Debug point 12
                        rethrow;
                      }
                    }
                  } catch (e) {
                    print('Error occurred: $e'); // Debug point 13
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    isLoading = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Scan barcode',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.add,
        color: Colors.black,
        size: 28,
      ),
    ),
  );
}
