import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parfumista/widgets/bottom_navigation.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _currentIndex = 2;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _suggestionController = TextEditingController();
  TextEditingController _impressionController = TextEditingController();
  List<Map<String, String>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _saveFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> feedback = {
      'name': _nameController.text,
      'suggestion': _suggestionController.text,
      'impression': _impressionController.text,
    };
    _feedbackList.add(feedback);

    // Convert feedbackList to JSON string and save it
    String feedbackStringList = jsonEncode(_feedbackList);
    await prefs.setString('feedbackList', feedbackStringList);
    _clearFields();
    setState(() {});
  }

  Future<void> _loadFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String feedbackStringList = prefs.getString('feedbackList') ?? '[]';

    // Decode JSON string back to List<Map<String, String>>
    _feedbackList = List<Map<String, String>>.from(
        jsonDecode(feedbackStringList)
            .map((item) => Map<String, String>.from(item)));
    setState(() {});
  }

  void _clearFields() {
    _nameController.clear();
    _suggestionController.clear();
    _impressionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.amberAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        title: Text(
          'Feedback',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.amber[50],
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _suggestionController,
                decoration: InputDecoration(
                  labelText: 'Saran terhadap mata kuliah PAM',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _impressionController,
                decoration: InputDecoration(
                  labelText: 'Kesan terhadap mata kuliah PAM',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _saveFeedback,
                child: Text('Kirim Feedback'),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: ListView.builder(
                  itemCount: _feedbackList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nama: ${_feedbackList[index]['name']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Saran: ${_feedbackList[index]['suggestion']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Kesan: ${_feedbackList[index]['impression']}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DynamicBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/favorite');
              break;
            case 2:
              Navigator.pushNamed(context, '/feedback');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
