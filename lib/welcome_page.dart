import 'package:dailyplanner/addschedule.dart';
import 'package:dailyplanner/checklist.dart';
import 'package:dailyplanner/conversion.dart';
import 'package:dailyplanner/feedback.dart';
import 'package:dailyplanner/login.dart';
import 'package:dailyplanner/profile.dart';
import 'package:dailyplanner/showschedule.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  final String username;

  WelcomePage({required this.username});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  late List<TriviaQuestion> triviaQuestions = [];
  late List<bool> showCorrectAnswerList = [];
  late PageController _pageController;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTriviaQuestions();
    _pageController = PageController();
  }

  Future<void> _fetchTriviaQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          triviaQuestions = (data['results'] as List).map((item) =>
              TriviaQuestion.fromJson(item)).toList();
          showCorrectAnswerList =
              List.generate(triviaQuestions.length, (index) => false);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load trivia questions';
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to connect to the server';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF8f14b8),
      ),
      backgroundColor: Color(0xFFc553ec),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: triviaQuestions.length,
              itemBuilder: (context, index) {
                final question = triviaQuestions[index];
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Color(0xFF8f14b8),
                      child: ListTile(
                        title: Text(
                          question.question,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 8),
                            if (showCorrectAnswerList[index])
                              Text(
                                '${question.correctAnswer}',
                                style: TextStyle(fontSize: 20.0, color: Colors.white),
                              ),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            showCorrectAnswerList[index] =
                            !showCorrectAnswerList[index];
                          });
                        },
                        trailing: showCorrectAnswerList[index] ? null : Icon(
                            Icons.keyboard_arrow_down, color: Colors.white,),
                        dense: true,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              children: [
                _buildMenuItem(Icons.add_circle, 'Add Schedule', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddSchedulePage(username: widget.username),
                    ),
                  );
                }, Color(0xFF8f14b8)),
                _buildMenuItem(Icons.calendar_today, 'Schedule List', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ScheduleListPage(username: widget.username),
                    ),
                  );
                }, Color(0xFF8f14b8)),
                _buildMenuItem(Icons.check_circle, 'Mark as Done', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MarkAsDonePage(username: widget.username),
                    ),
                  );
                }, Color(0xFF8f14b8)),
                _buildMenuItem(Icons.attach_money, 'Currency', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CurrencyConverterPage(),
                    ),
                  );
                }, Color(0xFF8f14b8)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8f14b8),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined, color: Colors.grey),
            label: 'notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.grey),
            label: 'profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.grey),
            label: 'logout',
          ),
        ],
        onTap: (int index) async {
          if (index == 0) {
            //
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackPage(username: widget.username),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(username: widget.username),
              ),
            );
          } else if (index == 3) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', false);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData iconData, String label, VoidCallback onTap,
      Color color) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        elevation: 2.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, size: 50, color: Colors.white),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

  class TriviaQuestion {
  final String type;
  final String difficulty;
  final String category;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  TriviaQuestion({
    required this.type,
    required this.difficulty,
    required this.category,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      type: json['type'],
      difficulty: json['difficulty'],
      category: json['category'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }
}
