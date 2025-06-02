part of '../pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int leaveCount = 0;
  int absentCount = 0;
  int permissionCount = 0;
  int sickCount = 0;
  int alphaCount = 0;
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
    getAttendanceCounts();
  }

  Future<void> getAttendanceCounts() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Ambil semua data attendance user
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .get();

    // Reset jumlah
    int hadir = 0;
    int izin = 0;
    int sakit = 0;
    int alpha = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      // Pastikan ada key 'category' dan bertipe String
      String? category = data['category'];

      if (category != null) {
        switch (category.toLowerCase()) {
          case 'hadir':
            hadir++;
            break;
          case 'izin':
            izin++;
            break;
          case 'sakit':
            sakit++;
            break;
          case 'alpha':
            alpha++;
            break;
        }
      }
    }

    // Simpan ke state untuk ditampilkan
    setState(() {
      absentCount = hadir;
      permissionCount = izin;
      sickCount = sakit;
      alphaCount = alpha;
    });
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
              return const Text("");
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hello",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                Text(
                  '${snapshot.data!['first_name']} ${snapshot.data!['last_name']}',
                  style: const TextStyle(
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
            const SizedBox(height: 20),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: "Search",
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.search_sharp, size: 25, color: Colors.grey,),
                ),
                hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600
                ),
                labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Absensi Bulan Ini", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.blueAccent)),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildCountCard("Hadir", absentCount, Colors.white, Colors.greenAccent),
                    buildCountCard("Izin", permissionCount, Colors.white, Colors.orangeAccent),
                    buildCountCard("Sakit", sickCount, Colors.white, Colors.pinkAccent),
                    buildCountCard("Alpha", alphaCount, Colors.white, Colors.redAccent),
                  ],
                )
              ],
            ),
            const Text(
              'Academics',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.blueAccent),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildMenuItem(
                        Image.asset('assets/images/attendance.png', width: 50, height: 50),
                        "Students",
                            () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildMenuItem(
                        Image.asset('assets/images/assiment.png', width: 50, height: 50),
                        "Attendance",
                            () {
                          Navigator.pushNamed(context, '/home-attendance');
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildMenuItem(
                        Image.asset('assets/images/note.png', width: 50, height: 50),
                        "Notes",
                            () {
                          Navigator.pushNamed(context, '/note');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            const Text(
              'E-learning',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.blueAccent),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _courseMenuItem('Math'),
                    _courseMenuItem('English'),
                    _courseMenuItem('Arabic'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(Widget image, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, // ukuran kotak (lebar)
        height: 100, // ukuran kotak (tinggi)
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image,
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseMenuItem(String course){
   return GestureDetector(
     onTap: (){},
     child: Container(
       width: 140,
       margin: EdgeInsets.symmetric(horizontal: 8),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(16),
         boxShadow: [
           BoxShadow(
             color: Colors.black12,
             blurRadius: 6,
             offset: Offset(0, 3)
           ),
         ]
       ),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           SizedBox(height: 20),
           ClipRRect(
             borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
             child: Image.asset(
               'assets/images/course1.jpg',
               height: 100,
               width: double.infinity,
               fit: BoxFit.cover,
             ),
           ),
           const SizedBox(height: 8),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8.0),
             child: Text(
               course,
               style: const TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 14,
               ),
               textAlign: TextAlign.center,
             ),
           ),
           TextButton(
             onPressed: (){},
             child: Container(
               decoration: BoxDecoration(
                 color: Colors.blue,
                 borderRadius: BorderRadius.circular(10)
               ),
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 8),
                   child: const Text("Start", style: TextStyle(color: Colors.white),),
                 )),
             style: TextButton.styleFrom(
               foregroundColor: Colors.blue,
             ),
           ),
         ],
       ),
     ),
   );
  }

  Widget buildCountCard(String label, int count, Color color, Color backgroundColor) {
    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("$count", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }


}