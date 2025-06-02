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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Attendance",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blue),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle("Quick Access"),
          const SizedBox(height: 12),
          _buildMenuButton(Icons.check_circle, "Attendance", '/attendance'),
          _buildMenuButton(Icons.event_available, "Permission", '/leave'),
          _buildMenuButton(Icons.history, "History", '/history'),
          const SizedBox(height: 30),

          _buildSectionTitle("Your Calendar"),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2000),
              lastDay: DateTime(2100),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.blue),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
                weekendStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, _) {
                  Color? color = eventColors[DateTime(day.year, day.month, day.day)];
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
                          color: color != null ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              calendarStyle: const CalendarStyle(
                selectedTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                todayTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Legend"),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend("Permission", Colors.green),
              _buildLegend("Sick", Colors.red),
              _buildLegend("Other", Colors.blue),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label, String routeName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, routeName),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
