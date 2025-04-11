import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Evaluation_2.dart';

class TeamInfoPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String teamId;

  TeamInfoPage({required this.data, required this.teamId});

  @override
  _TeamInfoPageState createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  late Map<String, dynamic> teamData;
  bool isEvaluation1 = true;

  final Color purple = const Color(0xFF6A1B9A); // Deep purple
  final Color lightPurple = const Color(0xFFE1BEE7); // Soft purple

  @override
  void initState() {
    super.initState();
    teamData = Map<String, dynamic>.from(widget.data);
  }

  Widget _buildLabeledField(String label, String? value) {
    return Row(
      children: [
        Text(
          "$label :",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          // decoration: BoxDecoration(
          //   border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
          // ),
          child: Text(value ?? '', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> members = List<String>.from(teamData['members'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightPurple,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'XYNTRA 25 EVAL SCANNER',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 1,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              color: purple.withOpacity(0.2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  teamData['team_name']?.toUpperCase() ?? 'TEAM NAME',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: purple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildLabeledField("TEAM CODE", "< ${widget.teamId} />"),
            const Divider(thickness: 2),
            _buildLabeledField("COLLEGE", teamData['college']),
            const Divider(thickness: 2),
            _buildLabeledField("LOCATION", teamData['location']),
            const Divider(thickness: 2),
            _buildLabeledField("LEAD CONTACT", teamData['lead_contact']),

            const Divider(thickness: 1),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "MEMBERS",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...members.map(
              (member) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                height: 40,
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(member, style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EVALUATION :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => isEvaluation1 = true);
                          log('Evaluation : ${isEvaluation1 ? 'I' : 'II'}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isEvaluation1 ? purple : lightPurple,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "I",
                            style: TextStyle(
                              color:
                                  isEvaluation1 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => isEvaluation1 = false);
                          log('Evaluation : ${isEvaluation1 ? 'I' : 'II'}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: !isEvaluation1 ? purple : lightPurple,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            "II",
                            style: TextStyle(
                              color:
                                  !isEvaluation1 ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          setState(() => isEvaluation1 = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Evaluation_Page(
                    teamCode: widget.teamId,
                    teamName: teamData['team_name'] ?? '',
                    evalution_number: isEvaluation1 ? 1 : 2,
                  ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          height: 50,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
            color: purple,
          ),
          child: Container(
            padding: EdgeInsets.all(2),
            child: Center(
              child: Text(
                "EVALUATE",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
