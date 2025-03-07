import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> recipes = [];
  String cuisine = '';
  String diet = '';
  int time = 0;

  Future<void> fetchRecipes() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/recipes?cuisine=$cuisine&diet=$diet&time=$time'),
    );
    if (response.statusCode == 200) {
      setState(() {
        recipes = jsonDecode(response.body)['results'];
      });
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Finder'),
        centerTitle: true,
        elevation: 0, 
        backgroundColor: const Color.fromARGB(255, 199, 224, 255), 
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Cuisine',
                    border: OutlineInputBorder(), 
                  ),
                  onChanged: (value) => cuisine = value,
                ),
                SizedBox(height: 16), 
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Diet',
                    border: OutlineInputBorder(), 
                  ),
                  onChanged: (value) => diet = value,
                ),
                SizedBox(height: 16), 
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Cooking Time (mins)',
                    border: OutlineInputBorder(), 
                  ),
                  onChanged: (value) => time = int.tryParse(value) ?? 0,
                ),
                SizedBox(height: 16), 
                ElevatedButton(
                  onPressed: fetchRecipes,
                  child: Text('Search Recipes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800], 
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(recipe: recipes[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}