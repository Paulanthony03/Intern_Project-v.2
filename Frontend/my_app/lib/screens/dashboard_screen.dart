import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic>? users;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token != null) {
      var data = await ApiService.getUsers(token);

      setState(() {
        users = data;
      });
    }
  }

  // 🔹 CAROUSEL CARD UI
  Widget buildCarouselCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                (user["name"] ?? "U")[0],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),

            SizedBox(width: 15),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user["name"] ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    user["school"] ?? "",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "ID: ${user["intern_id"] ?? ""}",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),

      body: users == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 15),

                // 🔹 CAROUSEL SECTION
                CarouselSlider(
                  options: CarouselOptions(
                    height: 140,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: users!.map((user) {
                    return buildCarouselCard(user);
                  }).toList(),
                ),

                SizedBox(height: 10),

                // 🔹 TITLE
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "All Interns",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // 🔹 LIST SECTION
                Expanded(
                  child: ListView.builder(
                    itemCount: users!.length,
                    itemBuilder: (context, index) {
                      final user = users![index];

                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  (user["name"] ?? "U")[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),

                              SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user["name"] ?? "No Name",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(user["email"] ?? "-"),
                                    Text("ID: ${user["intern_id"] ?? "-"}"),
                                    Text(user["school"] ?? "-"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
