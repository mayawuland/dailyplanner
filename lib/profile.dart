import 'package:dailyplanner/feedback.dart';
import 'package:dailyplanner/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:dailyplanner/models/user_model.dart';
import 'package:dailyplanner/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dailyplanner/login.dart';
import 'package:dailyplanner/encryption_service.dart';

class ProfilePage extends StatefulWidget {
  final String username;

  ProfilePage({required this.username});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User?> _user;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _user = UserController.getUser(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF8f14b8),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFc553ec),
        ),
        child: FutureBuilder<User?>(
          future: _user,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No user data found'));
            }

            final user = snapshot.data!;

            // Dekripsi username dan password sebelum ditampilkan
            final decryptedUsername =
            CaesarCipher.decrypt(user.username, 3);
            final decryptedPassword =
            CaesarCipher.decrypt(user.password, 3);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://cdn.idntimes.com/content-images/post/20240207/33bac083ba44f180c1435fc41975bf36-ca73ec342155d955387493c4eb78c8bb.jpg', // Ganti URL ini dengan URL foto profil
                    ),
                  ),
                  SizedBox(height: 16),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    color: Color(0xFF8f14b8),
                    child: ListTile(
                      title: Text(
                        'Username',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Text(
                        decryptedUsername,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    color: Color(0xFF8f14b8),
                    child: ListTile(
                      title: Text(
                        'Password',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _isPasswordVisible ? decryptedPassword : '●●●●●●●●',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
            icon: Icon(Icons.note_alt_outlined, color: Colors.grey),
            label: 'notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, color: Colors.white),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedbackPage(username: widget.username),
              ),
            );
          } else if (index == 2) {
            //
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