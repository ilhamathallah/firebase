part of '../../pages.dart';

class HomeAttendance extends StatefulWidget {
  const HomeAttendance({super.key});

  @override
  State<HomeAttendance> createState() => _HomeAttendanceState();
}

class _HomeAttendanceState extends State<HomeAttendance> {
  int leaveCount = 0;
  int sickCount = 0;
  int permissionCount = 0;
  int otherCount = 0;

  @override
  void initState() {
    super.initState();
    _getLeaveCount();
  }

  Future<void> _getLeaveCount() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot leaveSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .get();

    setState(() {
      sickCount = leaveSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Home Attendance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),
            const Text(
              "Manage Your Attendance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),

            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildMenuItem(Icons.check_circle, "Attendance", Colors.blue, () {
                  Navigator.pushNamed(context, '/attendance');
                }),
                _buildMenuItem(Icons.event_available, "Permission", Colors.blue, () {
                  Navigator.pushNamed(context, '/leave');
                }),
                _buildMenuItem(Icons.history, "History", Colors.blue, () {
                  Navigator.pushNamed(context, '/history');
                }),
                _buildStatCard('Sick', sickCount, Colors.red),
                _buildStatCard('Permission', permissionCount, Colors.green),
                _buildStatCard('other', otherCount, Colors.blue)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
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
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color),
          ),
          SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color),
          ),
        ],
      ),
    );
  }
}
