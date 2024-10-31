import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_constants.dart';
import '../../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final position = await _authService.login(username, password);

    if (position == null) {
      setState(() {
        _errorMessage = 'Invalid login credentials';
      });
    } else {
      // Navigate to HomeScreen if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              'lib/assets/logo.png',
              fit: BoxFit.cover,
              width: 150,
              height: 150,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green[300]),
          ),
          SizedBox(
            height: 100,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 0, 80, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Username",
                      style: TextStyle(
                        fontSize: 16, // Set the desired font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4,10,4,10),
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                            filled: true, // Enable filling
                            fillColor: Colors.white),
                      ),
                    ),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 16, // Set the desired font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4,10,4,10),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible, // Toggle password visibility
                        decoration: InputDecoration(
                          filled: true, // Enable filling
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible; // Toggle the visibility state
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Submit'),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
