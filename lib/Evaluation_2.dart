import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Evaluation_Page extends StatefulWidget {
  final String teamCode;
  final String teamName;
  final int evalution_number;

  Evaluation_Page({
    required this.teamCode,
    required this.teamName,
    required this.evalution_number,
  });

  @override
  _Evaluation_PageState createState() => _Evaluation_PageState();
}

class _Evaluation_PageState extends State<Evaluation_Page> {
  final _formKey = GlobalKey<FormState>();
  bool firstEvaluationDone = false;

  final Map<String, dynamic> formData = {
    "teamCode": "",
    "teamName": "",
    "clarity": null,
    "progress": null,
    "technicalDepth": null,
    "innovation": null,
    "collaboration": null,
    "scalability": null,
  };

  @override
  void initState() {
    super.initState();
    formData['teamCode'] = widget.teamCode;
    formData['teamName'] = widget.teamName;
    checkFirstEvaluationStatus();
  }

  Future<void> checkFirstEvaluationStatus() async {
    final url = Uri.parse(
      'https://script.google.com/macros/s/AKfycbwaGc1uKBHC9K6U1PNEvdvq9IzuS5MPBFZ_W-Doti93okBGWkfxCdJMWsY84QLYrPC_/exec',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null &&
            (data['clarity'] != null ||
                data['progress'] != null ||
                data['technicalDepth'] != null ||
                data['innovation'] != null ||
                data['collaboration'] != null ||
                data['scalability'] != null)) {
          setState(() {
            firstEvaluationDone = true;
          });
        }
      }
    } catch (e) {
      print('Error checking evaluation status: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double total =
          (formData['clarity'] ?? 0).toDouble() +
          (formData['progress'] ?? 0).toDouble() +
          (formData['technicalDepth'] ?? 0).toDouble() +
          (formData['innovation'] ?? 0).toDouble() +
          (formData['collaboration'] ?? 0).toDouble() +
          (formData['scalability'] ?? 0).toDouble();

      Map<String, dynamic> finalData = {
        ...formData,
        'totalScore': total.round(),
      };

      final response = await http.post(
        Uri.parse(
          'https://script.google.com/macros/s/AKfycbyLGqVT8_jbr8h8cryLooSK9-2Pl0EjoXSKPCopncFzxdXlB6fmwXWAKg50a0dZ-hCq/exec',
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(finalData),
      );
    }
  }

  Widget _scoreInput(String label, String key, double maxScore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: "$label "),
                  TextSpan(
                    text: "(out of ${maxScore.toInt()})",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: formData[key]?.toString() ?? '',
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Colors.purple.shade50,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final number = double.tryParse(value);
                if (number == null) return 'Enter valid number';
                if (number > maxScore) return 'Max: $maxScore';
                return null;
              },
              onChanged: (value) {
                setState(() {
                  formData[key] = double.tryParse(value) ?? 0;
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Implement your edit functionality here
              print("Edit button pressed for $key");
            },
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Implement your delete functionality here
              print("Delete button pressed for $key");
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        elevation: 0,
        title: Text(
          'XYNTRA 25 EVAL SCANNER',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                color: Colors.purple[100],
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    widget.teamName.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.purple[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _scoreInput("Problem Clarity", "clarity", 15),
              _scoreInput("Progress", "progress", 25),
              _scoreInput("Technical Depth", "technicalDepth", 20),
              _scoreInput("Innovation", "innovation", 15),
              _scoreInput("Collaboration", "collaboration", 10),
              _scoreInput("Scalability", "scalability", 10),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "TOTAL SCORE :",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (() {
                          double total =
                              (formData['clarity'] ?? 0).toDouble() +
                              (formData['progress'] ?? 0).toDouble() +
                              (formData['technicalDepth'] ?? 0).toDouble() +
                              (formData['innovation'] ?? 0).toDouble() +
                              (formData['collaboration'] ?? 0).toDouble() +
                              (formData['scalability'] ?? 0).toDouble();
                          return total.round().toString();
                        })(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              firstEvaluationDone
                  ? Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        "1ST EVALUATION DONE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[800],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                    child: Text('UPDATE SCORE'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
