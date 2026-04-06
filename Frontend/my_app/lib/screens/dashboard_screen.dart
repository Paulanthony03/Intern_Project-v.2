import 'package:flutter/material.dart';
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

  // ================= HEADER =================
  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back 👋",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                "Admin Dashboard",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(Icons.person, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget buildModernCard(Map<String, dynamic> user) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    (user["name"] ?? "U")[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "edit") {
                      showEditUserDialog(user);
                    } else if (value == "delete") {
                      showDeleteConfirmation(user["id"]);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Delete")),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            Text(
              user["name"] ?? "No Name",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            Text(
              user["email"] ?? "-",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),

            Divider(height: 20),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Active",
                style: TextStyle(fontSize: 10, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CRUD =================

  void showAddUserDialog() {
    final name = TextEditingController();
    final email = TextEditingController();
    final school = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: school,
              decoration: InputDecoration(labelText: "School"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString("token");

              await ApiService.createUser(token!, {
                "name": name.text,
                "email": email.text,
                "school": school.text,
              });

              Navigator.pop(context);
              loadUsers();
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void showEditUserDialog(Map<String, dynamic> user) {
    final name = TextEditingController(text: user["name"]);
    final email = TextEditingController(text: user["email"]);
    final school = TextEditingController(text: user["school"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name),
            TextField(controller: email),
            TextField(controller: school),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString("token");

              await ApiService.updateUser(token!, user["id"], {
                "name": name.text,
                "email": email.text,
                "school": school.text,
              });

              Navigator.pop(context);
              loadUsers();
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(dynamic id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Student"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString("token");

              await ApiService.deleteUser(token!, id);
              Navigator.pop(context);
              loadUsers();
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // ================= MAIN =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddUserDialog,
        child: Icon(Icons.add),
      ),

      body: users == null
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildHeader(),

                // SEARCH
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search students...",
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // STATS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      buildStatCard(
                        "Total",
                        users!.length.toString(),
                        Icons.people,
                        Colors.blue.shade50,
                      ),
                      SizedBox(width: 10),
                      buildStatCard(
                        "Active",
                        users!.length.toString(),
                        Icons.check_circle,
                        Colors.green.shade50,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                // SECTION TITLE
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Students",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: showAddUserDialog,
                        child: Text("Add New"),
                      ),
                    ],
                  ),
                ),

                // GRID
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: users!.length,
                    itemBuilder: (context, index) {
                      return buildModernCard(users![index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
