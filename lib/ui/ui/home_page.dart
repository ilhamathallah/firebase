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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        automaticallyImplyLeading: false,
        title: FutureBuilder<Map<String, dynamic>>(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Text("User");
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello",
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 5),
                Text(
                  '${snapshot.data!['first_name']} ${snapshot.data!['last_name']}',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.blueGrey),
                )
              ],
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.notifications_none_rounded, size: 35,color: Colors.blueGrey,),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: "Search",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.search_sharp, size: 25,),
                ),
                hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                ),
                labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            SizedBox(height: 20,),
            Text(
              'Accademics',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 15),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuItem(Image.asset('assets/images/attendance.png', width: 50, height: 50), "Profile", () {
                    Navigator.pushNamed(context, '/profile');
                  }),
                  _buildMenuItem(Image.asset('assets/images/assiment.png', width: 50, height: 50), "Attendance", () {
                    Navigator.pushNamed(context, '/home-attendance');
                  }),
                  _buildMenuItem(Image.asset('assets/images/note.png', width: 50, height: 50), "Notes", () {
                    Navigator.pushNamed(context, '/note');
                  }),
                  // _buildMenuItem(Icons.new_releases, "Up Coming", () {
                  //   Navigator.pushNamed(context, '');
                  // }),
                ],
              ),
            ),
            Center(
              child: Text(
                'Version 1.0',
                style: subWelcomeTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Widget image, String title, VoidCallback onTap) {
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
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image, // Tidak perlu panggil Image.asset lagi
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
