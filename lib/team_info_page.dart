import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    teamData = Map<String, dynamic>.from(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> members = List<String>.from(teamData['members'] ?? []);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
            SizedBox(height: 16),
            Text('Location:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            Text(teamData['location'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),
            Text('Lead Contact:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            Text(teamData['lead_contact'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 16),
            Text('Team Members:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
            SizedBox(height: 8),
            members.isEmpty
                ? Text('No team members available', style: TextStyle(color: Colors.grey[600]))
                : Column(
              children: List.generate(
                members.length,
                    (index) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      members[index],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 80), // add spacing for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEvaluation1 = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isEvaluation1 ? Colors.purple : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Evaluation 1', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEvaluation1 = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Evaluation2Page(
                      teamCode: widget.teamId,
                      teamName: teamData['team_name'] ?? '',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !isEvaluation1 ? Colors.purple : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Evaluation 2', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
