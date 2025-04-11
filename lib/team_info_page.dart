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
  bool e1Status = false;
  bool e2Status = false;
  String button_text = "EVALUATE";
  late final e1_marks;
  late final e2_marks;

  final Color purple = const Color(0xFF6A1B9A); // Deep purple
  final Color lightPurple = const Color(0xFFE1BEE7); // Soft purple

  @override
  void initState() {
    super.initState();
    teamData = Map<String, dynamic>.from(widget.data);
    fetchEvaluationStatus(widget.teamId);
  }

  Future<void> fetchEvaluationStatus(String teamCode) async {
    final url = Uri.parse(
      'https://script.google.com/macros/s/AKfycbwaGc1uKBHC9K6U1PNEvdvq9IzuS5MPBFZ_W-Doti93okBGWkfxCdJMWsY84QLYrPC_/exec?check_evaluation_status=true&team_code=$teamCode',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          e1Status = data['e1_status'] ?? false;
          e2Status = data['e2_status'] ?? false;
          log('Eval 1 : $e1Status , Eval 2 : $e2Status');
          button_text =
              e1Status
                  ? (e2Status ? "FINAL EVALUATION DONE" : "EVALUATION 1 DONE")
                  : "EVALUATE";
        });
        if (e1Status) {
          e1_marks = await fetchTeamMarks(
            teamCode: widget.teamId,
            eval_number: 1, // or 2 depending
          );
          log('$e1_marks');
        }

        if (e2Status) {
          e2_marks = await fetchTeamMarks(
            teamCode: widget.teamId,
            eval_number: 2, // or 2 depending
          );
          log('$e2_marks');
        }

        log('E1 Marks = $e1_marks \n E2 Marks = $e2_marks');
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching evaluation statusasdfgh: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchTeamMarks({
    required String teamCode,
    required int eval_number,
  }) async {
    print("Fetching marks for team code: $teamCode");
    String eval_sheet_name = eval_number == 1 ? "E1%20Scores" : "E2%20Scores";

    final url = Uri.parse(
      'https://script.google.com/macros/s/AKfycbwaGc1uKBHC9K6U1PNEvdvq9IzuS5MPBFZ_W-Doti93okBGWkfxCdJMWsY84QLYrPC_/exec?fetch_team_marks=true&eval_sheet=$eval_sheet_name&team_code=$teamCode',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Fetched Marks: $data");
        return data;
      } else {
        print("Failed to fetch marks. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching team marks: $e");
      return null;
    }
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
            if (e1Status || e2Status) ...[
              const Divider(thickness: 1),
              const SizedBox(height: 5),
              if (e1Status)
                GestureDetector(
                  onTap: () {
                    // Your navigation or action logic here
                    // log($e)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Evaluation_Page(
                              teamCode: widget.teamId,
                              teamName: teamData['team_name'] ?? '',
                              evalution_number: isEvaluation1 ? 1 : 2,
                              marksData: e1_marks,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.green.shade50,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.remove_red_eye, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            "View 1st Evaluation Scores",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              if (e2Status)
                GestureDetector(
                  onTap: () {
                    // Your navigation or action logic here
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => Evaluation_Page(
                              teamCode: widget.teamId,
                              teamName: teamData['team_name'] ?? '',
                              evalution_number: isEvaluation1 ? 1 : 2,
                              marksData: e2_marks,
                            ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.green.shade50,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.green.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.remove_red_eye, color: Colors.green),
                          SizedBox(width: 10),
                          Text(
                            "View 2nd Evaluation Scores",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap:
            (e1Status && e2Status)
                ? null
                : () {
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
            color: (e1Status && e2Status) ? Colors.green : purple,
          ),
          child: Container(
            padding: EdgeInsets.all(2),
            child: Center(
              child: Text(
                button_text,
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
