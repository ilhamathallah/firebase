part of '../../../pages.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final nameController = TextEditingController();
  final fromController = TextEditingController();
  final untilController = TextEditingController();
  String dropValueCategories = "Please Choose";
  var categoryList = <String>["Please Choose", "Sick", "Permission", "Other"];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown";

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown";

    if (userId == "Unknown") {
      return;
    }

    try {
      DocumentSnapshot userDoc =
      await firestore.collection('user').doc(userId).get();
      print("User Doc: ${userDoc.data()}");

      String firstName = userDoc['firstName'];
      String lastName = userDoc['lastName'];
      String fullName = '$firstName $lastName';
    } catch (e) {
      print("Error Fetch User: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Permission Page",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: <Widget>[
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Please fill the form below",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Your Name",
                      labelStyle: TextStyle(color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// Dropdown Leave Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Leave Type",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: dropValueCategories,
                            style: TextStyle(color: Colors.blue),
                            items: categoryList.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                dropValueCategories = value!;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  /// Date Pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField("From", fromController),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDateField("Until", untilController),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Submit Button
                  SizedBox(
                    width: size.width * 0.9,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            dropValueCategories == "Please Choose" ||
                            fromController.text.isEmpty ||
                            untilController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Please fill all the form"),
                                ],
                              ),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          submitAbsent(
                            nameController.text,
                            dropValueCategories,
                            fromController.text,
                            untilController.text,
                          );
                        }
                      },
                      label: const Text("Submit", style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Date Field Builder
  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(9999),
            );
            if (pickedDate != null) {
              controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
            }
          },
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.blueAccent),
            hintText: "Select date",
            hintStyle: TextStyle(color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  /// Submit Function
  Future<void> submitAbsent(
      String name, String note, String from, String until) async {
    showLoaderDialog(context);

    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';
    print("USER ID =  $userId");
    if (userId == 'Unknown') {
      print("ERROR: User ID is unknowner");
      return;
    }

    DocumentReference UserDocRef = firestore.collection('users').doc(userId);
    CollectionReference attendanceCollection =
    UserDocRef.collection('attendance');

    attendanceCollection.add({
      'name': name,
      'description': note,
      'datetime': '$from-$until',
      'createdAt': FieldValue.serverTimestamp(),
    }).then(
          (result) {
        print("Data has been saved whit ID = ${result.id}");
        setState(
              () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Data has been saved",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: Colors.greenAccent,
                behavior: SnackBarBehavior.floating,
                shape: StadiumBorder(),
                duration: Duration(seconds: 3),
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeAttendance(),
              ),
            );
          },
        );
      },
    ).catchError((error) {
      print("filed to save data: $error");
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Upss...$error",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          shape: StadiumBorder(),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      content: Row(
        children: <Widget>[
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
          Container(
            margin: const EdgeInsets.only(left: 7),
            child: const Text("Please Wait..."),
          ),
        ],
      ),
    );
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

}
