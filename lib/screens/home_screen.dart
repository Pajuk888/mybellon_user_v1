import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'job_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isAvailable = false;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser!.email!;
    // Fetch initial availability status
    FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          isAvailable = doc['available'];
        });
      }
    });
  }

  void updateAvailability(bool availability) {
    setState(() {
      isAvailable = availability;
    });
    FirebaseFirestore.instance.collection('users').doc(userEmail).update({
      'available': availability,
    }).then((_) {
      print("User availability updated successfully");
      print("User Email: $userEmail, Availability: $availability");
    }).catchError((error) {
      print("Failed to update availability: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyBellon User Home'),
      ),
      body: Container(
        color: Colors.lightGreen, // Set background color to light-green
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('job_posts')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final jobCount = snapshot.data!.docs.length;
                return Text('Number of job posts: $jobCount');
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('I\'m available'),
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    updateAvailability(value);
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JobListScreen()),
                );
              },
              child: Text('View Job List'),
            ),
          ],
        ),
      ),
    );
  }
}
