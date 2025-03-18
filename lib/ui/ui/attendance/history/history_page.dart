part of '../../../pages.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final dataService = DataServiceHistoryAttendance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "History",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 35,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataService.getAttendanceStream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('There is not data'));
          }

          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return AttendanceCardWidget(
                data: data[index].data() as Map<String, dynamic>,
                attendanceId: data[index].id,
              );
            },
          );
        },
      ),
    );
  }
}

class DataServiceHistoryAttendance {
  final auth = FirebaseAuth.instance;

//   get id attendance users
  CollectionReference getUserAttendance() {
    final String? userId = auth.currentUser!.uid;
    if (userId == null) {
      throw Exception("User is not Logged in!");
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance');
  }

//   get data attendance users
  Stream<QuerySnapshot> getAttendanceStream() {
    return getUserAttendance()
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
