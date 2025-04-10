import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TeamInfoPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String teamId;

  TeamInfoPage({required this.data, required this.teamId});

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  late Map<String, dynamic> teamData;

  @override
  void initState() {
    super.initState();
    // Defensive copy to prevent mutation
    teamData = Map<String, dynamic>.from(widget.data);
  }

  Future<void> submitScore(BuildContext context, int score) async {
    // Replace YOUR_SCRIPT_ID with your actual Google Apps Script ID
    final scriptId = 'AKfycbxVeRRFM2VwKQ76XNBd6Tuuw2_tlIulvyGXWCJrUE27CpWdsCMizcbyncP6F0z3raEF'; // Replace with your actual script ID
    final url = Uri.parse(
      'https://script.google.com/macros/s/$scriptId/exec?teamId=${widget.teamId}',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamId': widget.teamId,
          'teamName': teamData['team_name'],
          'score': score,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            teamData['score'] = score;
            teamData['score_history'] = List.from(teamData['score_history'] ?? [])..add(score);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Score submitted successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Submission failed: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> members = List<String>.from(teamData['members'] ?? []);
    final List<int> scoreHistory = List<int>.from(teamData['score_history'] ?? []);

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.purple,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/logo.png', height: 150, width: 150, fit: BoxFit.contain),
                Image.asset('assets/cslogo.png', height: 150, width: 150, fit: BoxFit.contain),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Team ID: ${widget.teamId}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple[700])),
              SizedBox(height: 8),
              Text(teamData['team_name'] ?? '',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple[900])),
              SizedBox(height: 16),
              Text('College:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
              Text(teamData['college'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              SizedBox(height: 25),
              Text('Team Members:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
              SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            members[index][0].toUpperCase(),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(members[index], style: TextStyle(fontSize: 16)),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 25),

              if (scoreHistory.isNotEmpty) ...[
                Text('Score History:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                SizedBox(height: 10),
                Container(
                  height: 100,
                  child: ListView.builder(
                    itemCount: scoreHistory.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.history, color: Colors.deepPurple),
                        title: Text("Score: ${scoreHistory[index]}"),
                      );
                    },
                  ),
                ),
              ],

              SizedBox(height: 20),

              if (teamData.containsKey('score'))
                Text(
                  'Current Score: ${teamData['score']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple[700]),
                ),

              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final TextEditingController scoreController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Enter Score'),
                        content: TextField(
                          controller: scoreController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: "Enter team's score"),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          ElevatedButton(
                            child: Text('Submit'),
                            onPressed: () {
                              final int? score = int.tryParse(scoreController.text);
                              if (score != null) {
                                Navigator.of(context).pop();
                                submitScore(context, score);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('⚠️ Please enter a valid number!')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Submit Score'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
