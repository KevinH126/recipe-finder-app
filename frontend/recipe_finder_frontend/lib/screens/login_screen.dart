import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart'; 

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      print('Please enter both email and password.');
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        print('User logged in: ${response.user!.email}');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('Login failed: ${response.session}');
      }
    } catch (error) {
      print('Error during login: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        elevation: 0, 
        backgroundColor: Colors.blue[800], 
      ),
      body: Padding(
        padding: EdgeInsets.all(16), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), 
                ),
                filled: true, 
                fillColor: Colors.grey[200], 
              ),
            ),
            SizedBox(height: 16), 
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), 
                ),
                filled: true, 
                fillColor: Colors.grey[200], 
              ),
            ),
            SizedBox(height: 24), 
            
            ElevatedButton(
              onPressed: () => _signIn(context), 
              child: Text(
                'Login',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], 
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), 
                ),
              ),
            ),
            SizedBox(height: 16), 
            // Sign Up Text
            TextButton(
              onPressed: () {
                
              },
              child: Text(
                'Don\'t have an account? Sign Up',
                style: TextStyle(
                  color: Colors.blue[800], 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}