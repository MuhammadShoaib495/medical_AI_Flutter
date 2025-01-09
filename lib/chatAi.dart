import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models.dart'; // Assuming your models are in this file

Future<AnswerResponse> getAnswerFromAPI(String question) async {
  const url = 'http://10.0.2.2:8080/ask-question/';  // FastAPI URL

  // Create the request body
  final requestBody = QuestionRequest(question: question).toJson();

  // Send the POST request to FastAPI
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode(requestBody),
  );

  // Check if the request was successful
 if (response.statusCode == 200) {
   // Decode the response explicitly in UTF-8
   final responseJson = utf8.decode(response.bodyBytes);
   final data = json.decode(responseJson);

   return AnswerResponse.fromJson(data);
 } else {
   throw Exception('Failed to load answer');
 }
}
class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final TextEditingController _controller = TextEditingController();
  String _answer = '';
  bool _isLoading = false;
  String cleanResponse(String response) {
    // Remove bold markdown formatting **text**
    response = response.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');

    // Remove italics markdown formatting *text*
    response = response.replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '');

    return response;
  }

  // Function to send the question to the API and get the answer
  void _askQuestion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final answerResponse = await getAnswerFromAPI(_controller.text);
      setState(() {
        _answer =  cleanResponse(answerResponse.answer);
      });
      print("API Response: $_answer");
    } catch (e) {
      setState(() {
        _answer = 'Error: Could not get an answer.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ask a Medical Question AI'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Enter your question',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _askQuestion,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Ask'), // Show loading indicator while waiting
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _answer.isEmpty ? 'Waiting for answer...' : _answer,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
