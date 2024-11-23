import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _numQuestions = 5;
  String _selectedCategory = "9"; // Default category ID for General Knowledge
  String _selectedDifficulty = "Easy";
  String _selectedType = "multiple";

  final List<Map<String, String>> _categories = [
    {"id": "9", "name": "General Knowledge"},
    {"id": "21", "name": "Sports"},
    {"id": "11", "name": "Movies"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Setup"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Number of Questions:",
                style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton<int>(
              value: _numQuestions,
              isExpanded: true,
              items: [5, 10, 15].map((value) {
                return DropdownMenuItem(value: value, child: Text("$value"));
              }).toList(),
              onChanged: (value) => setState(() => _numQuestions = value!),
            ),
            SizedBox(height: 16),
            Text("Select Category:",
                style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton<String>(
              value: _selectedCategory,
              isExpanded: true,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category['id'],
                  child: Text(category['name']!),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            SizedBox(height: 16),
            Text("Select Difficulty:",
                style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton<String>(
              value: _selectedDifficulty,
              isExpanded: true,
              items: ["Easy", "Medium", "Hard"].map((value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedDifficulty = value!),
            ),
            SizedBox(height: 16),
            Text("Select Question Type:",
                style: Theme.of(context).textTheme.bodyLarge),
            DropdownButton<String>(
              value: _selectedType,
              isExpanded: true,
              items: [
                {"value": "multiple", "label": "Multiple Choice"},
                {"value": "boolean", "label": "True/False"},
              ].map((option) {
                return DropdownMenuItem(
                  value: option['value'],
                  child: Text(option['label']!),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        numQuestions: _numQuestions,
                        category: _selectedCategory,
                        difficulty: _selectedDifficulty.toLowerCase(),
                        type: _selectedType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Start Quiz"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
