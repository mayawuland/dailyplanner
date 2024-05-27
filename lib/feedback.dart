import 'package:dailyplanner/login.dart';
import 'package:dailyplanner/profile.dart';
import 'package:dailyplanner/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  final String username;

  FeedbackPage({required this.username});

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Feedback', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF8f14b8),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFc553ec),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/maya.jpg'),
              ),
              SizedBox(height: 16),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                color: Color(0xFF8f14b8),
                child: ListTile(
                  title: Text(
                    'Name',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    'Maya Wulandari',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                color: Color(0xFF8f14b8),
                child: ListTile(
                  title: Text(
                    'Student ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    '123210050',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                color: Color(0xFF8f14b8),
                child: ListTile(
                  title: Text(
                    'Feedback',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    'My impression of this course is mixed. On one hand, I feel somewhat overwhelmed by the assignments given, but on the other hand, Im glad I have the opportunity to explore things that arent taught in the practical sessions. Fortunately, I was still able to complete everything on time. My message is that I want to get an A!',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF8f14b8),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined, color: Colors.white),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomePage(username: widget.username),
              ),
            );
          } else if (index == 1) {
            //
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
}
