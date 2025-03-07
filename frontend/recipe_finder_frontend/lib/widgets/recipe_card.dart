import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:typed_data';

class RecipeCard extends StatefulWidget {
  final dynamic recipe;

  RecipeCard({required this.recipe});

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  Map<String, dynamic>? _recipeDetails;
  bool _isLoading = false;

  Future<void> _fetchRecipeDetails(int id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.spoonacular.com/recipes/$id/information?apiKey=${dotenv.env['SPOONACULAR_API_KEY']}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _recipeDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load recipe details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching recipe details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetails(widget.recipe['id']);
  }

  Future<ImageProvider> _loadImage(String url) async {
    try {
      print('Loading image from: $url');
      final proxyUrl = 'http://localhost:5000/api/proxy?url=${Uri.encodeComponent(url)}';
      print('Proxy URL: $proxyUrl');
      final response = await http.get(Uri.parse(proxyUrl));
      if (response.statusCode == 200) {
        print('Image loaded successfully');
        return MemoryImage(Uint8List.fromList(response.bodyBytes));
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16), 
      child: Card(
        elevation: 4, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), 
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12), 
          onTap: () {
          },
          child: Padding(
            padding: EdgeInsets.all(16), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8), 
                  child: recipe['image'] != null
                      ? FutureBuilder<ImageProvider>(
                          future: _loadImage(recipe['image']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey[200], 
                                child: Center(child: CircularProgressIndicator()),
                              );
                            } else if (snapshot.hasError) {
                              return Container(
                                width: double.infinity,
                                height: 150,
                                color: Colors.grey[200], 
                                child: Icon(Icons.broken_image, color: Colors.grey[400]),
                              );
                            } else {
                              return Image(
                                image: snapshot.data!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        )
                      : Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[200], 
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        ),
                ),
                SizedBox(height: 16), 
                // Recipe Title
                Text(
                  recipe['title'] ?? 'No title available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16), 
                // Additional Recipe Details
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else if (_recipeDetails != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Servings
                      Text(
                        'Servings: ${_recipeDetails!['servings']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 16), 
                      // Ingredients
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8), 
                      // List of Ingredients
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (_recipeDetails!['extendedIngredients'] as List)
                            .map<Widget>((ingredient) => Text(
                                  '- ${ingredient['original']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}