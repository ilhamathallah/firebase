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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, Color> eventColors = {
    DateTime(2023, 5, 2): Colors.green,
    DateTime(2023, 5, 7): Colors.red,
    DateTime(2023, 5, 8): Colors.green,
    DateTime(2023, 5, 11): Colors.red,
    DateTime(2023, 5, 15): Colors.green,
    DateTime(2023, 5, 19): Colors.blue,
    DateTime(2023, 5, 21): Colors.green,
    DateTime(2023, 5, 23): Colors.yellow,
    DateTime(2023, 5, 24): Colors.yellow,
    DateTime(2023, 5, 26): Colors.blue,
    DateTime(2023, 5, 28): Colors.red,
    DateTime(2023, 5, 30): Colors.green,
  };

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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Attendance",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  _buildMenuItem(Icons.check_circle, "Attendance", Colors.blue,
                      () {
                    Navigator.pushNamed(context, '/attendance');
                  }),
                  _buildMenuItem(
                      Icons.event_available, "Permission", Colors.blue, () {
                    Navigator.pushNamed(context, '/leave');
                  }),
                  _buildMenuItem(Icons.history, "History", Colors.blue, () {
                    Navigator.pushNamed(context, '/history');
                  }),
                  // _buildStatCard('Sick', sickCount, Colors.red),
                  // _buildStatCard('Permission', permissionCount, Colors.green),
                  // _buildStatCard('Other', otherCount, Colors.blue),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    TableCalendar(
                      focusedDay: _focusedDay,
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                        weekendStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, _) {
                          Color? color = eventColors[
                              DateTime(day.year, day.month, day.day)];
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color ?? Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                "${day.day}",
                                style: TextStyle(
                                  color: color != null
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      calendarStyle: const CalendarStyle(
                        selectedTextStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle
                        ),
                        todayTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        )
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegend("Permission", Colors.green),
                  _buildLegend("Sick", Colors.red),
                  _buildLegend("Other", Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 15, height: 15, decoration: BoxDecoration(color: color)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
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
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            count.toString(),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
