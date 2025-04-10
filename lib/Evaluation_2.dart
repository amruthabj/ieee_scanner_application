import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Evaluation2Page extends StatefulWidget {
  final String teamCode;
  final String teamName;

  Evaluation2Page({required this.teamCode, required this.teamName});

  @override
  _Evaluation2PageState createState() => _Evaluation2PageState();
}

class _Evaluation2PageState extends State<Evaluation2Page> {
  final _formKey = GlobalKey<FormState>();

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
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double total = (formData['clarity'] ?? 0) +
          (formData['progress'] ?? 0) +
          (formData['technicalDepth'] ?? 0) +
          (formData['innovation'] ?? 0) +
          (formData['collaboration'] ?? 0) +
          (formData['scalability'] ?? 0);

      Map<String, dynamic> finalData = {
        ...formData,
        'totalScore': total.round()
      };

      final response = await http.post(
        Uri.parse('https://script.google.com/macros/s/AKfycby6Lc_e6O9r5Kf7tB1BXEfV-_lTXkN-KaLzW9l3H-ueNTwjrqMZT9pvoaLRelQ3dFUw/exec'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(finalData),
      );

    }
  }

  Widget _buildTextField(String label, String key,
      {bool isNumber = false, bool readOnly = false}) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: (formData[key] != null && !isNumber) ? formData[key].toString() : '',
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade300 : Colors.purple.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && double.tryParse(value) == null) return 'Enter a valid number';
        return null;
      },
      onSaved: (value) => formData[key] = isNumber ? double.tryParse(value ?? "") ?? 0.0 : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        title: Text('Evaluation - Round 2'),
        backgroundColor: Colors.purple[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Team Code', 'teamCode', readOnly: true),
              SizedBox(height: 10),
              _buildTextField('Team Name', 'teamName', readOnly: true),
              SizedBox(height: 10),
              _buildTextField('Problem Clarity & Approach (out of 15)', 'clarity', isNumber: true),
              SizedBox(height: 10),
              _buildTextField('Progress & Functionality (out of 25)', 'progress', isNumber: true),
              SizedBox(height: 10),
              _buildTextField('Technical Depth (out of 20)', 'technicalDepth', isNumber: true),
              SizedBox(height: 10),
              _buildTextField('Innovation & Originality (out of 15)', 'innovation', isNumber: true),
              SizedBox(height: 10),
              _buildTextField('Team Collaboration (out of 10)', 'collaboration', isNumber: true),
              SizedBox(height: 10),
              _buildTextField('Scalability & Real-World Impact (out of 10)', 'scalability', isNumber: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[800],
                  foregroundColor: Colors.white, // <-- Text color white
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Submit Evaluation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
