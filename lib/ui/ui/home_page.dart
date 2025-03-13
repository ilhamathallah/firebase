part of '../pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int leaveCount = 0;
  String? userId;
  late Future<Map<String, dynamic>> userData;
  final controllerName = TextEditingController();

  final FirebaseService _auth = FirebaseService();

  @override
  void initState() {
    super.initState();

    User? user = _auth.currentUser;

    userId = user!.uid;
    userData = _auth.getUserData(userId!);
    // _getLeaveCount();
  }

  Future<void> fetchUserName() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    if (userId == "unknown") return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        String firstName = userDoc.get('first_name') ?? '';
        String lastName = userDoc.get('last_name') ?? '';
        String fullName = '$firstName $lastName';

        if (mounted) {
          setState(() {
            controllerName.text =
                fullName; // Mengisi field dengan nama pengguna
          });
        }
      }
    } catch (e) {
      print("Error retrieving username: $e");
    }
  }

  // Future<void> _getLeaveCount() async {
  //   String userId = FirebaseAuth.instance.currentUser!.uid;
  //
  //   QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('attendance')
  //       .get();
  //
  //   setState(() {
  //     leaveCount = leaveSnapshot.docs.length;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('User data not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome back",
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            snapshot.data!['first_name'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            snapshot.data!['last_name'],
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildMenuItem(Icons.calendar_today, "Attendance",
                                () {
                              Navigator.pushNamed(context, '/home-attendance');
                            }, iconColor: Colors.blue, textColor: Colors.blue),
                            _buildMenuItem(Icons.note, "Notes", () {
                              Navigator.pushNamed(context, '/note');
                            }, iconColor: Colors.blue, textColor: Colors.blue),
                            _buildMenuItem(Icons.person, "Profile", () {
                              Navigator.pushNamed(context, '/profile');
                            }, iconColor: Colors.blue, textColor: Colors.blue),
                            _buildMenuItem(Icons.new_releases, "Up Coming", () {
                              Navigator.pushNamed(context, '');
                            },
                                iconColor: Colors.blueGrey,
                                textColor: Colors.blueGrey),
                          ],
                        ),
                      ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue,
                      //     borderRadius: BorderRadius.circular(50)
                      //   ),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8.0),
                      //       child: Text('$leaveCount'),
                      //     ))
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    'Version 1.0',
                    style: subWelcomeTextStyle,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {Color iconColor = Colors.blue, Color textColor = Colors.black}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor), // Warna ikon bisa diubah
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor), // Warna teks bisa diubah
            ),
          ],
        ),
      ),
    );
  }
}
