part of '../../../pages.dart';

class Attendance extends StatefulWidget {
  final XFile? image;
  const Attendance({super.key, this.image});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  XFile? image;
  String strAddress = '';
  String strDate = '';
  String strTime = '';
  String strDateTime = '';
  String strStatus = 'Attendance';
  bool isLoading = false;
  int dateHour = 0;
  int dateMinute = 0;
  double dLat = 0.0;
  double dLong = 0.0;
  final controllerName = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";


  @override
  void initState() {
    super.initState();

    fetchUserName();

    image = widget.image;
    setDateTime();
    setStatusAbsent();

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
  }

  Future<void> fetchUserName() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";

    if (userId == "unknown") return;

    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        String firstName = userDoc.get('first_name') ?? '';
        String lastName = userDoc.get('last_name') ?? '';
        String fullName = '$firstName $lastName'; // Menggabungkan nama

        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            controllerName.text = fullName; // Mengisi field dengan nama pengguna
          });
        }
      }
    } catch (e) {
      print("Error retrieving username: $e");
    }
  }


  Future<void> submitAbsen(String alamat, String nama, String status) async {

    String userId = FirebaseAuth.instance.currentUser?.uid ?? "unknown";
    print("User ID: $userId"); // Debugging

    if (userId == "unknown") {
      print("Error: User ID not found");
      return;
    }

    DocumentReference userDocRef = firestore.collection('users').doc(userId);
    CollectionReference attendanceCollection = userDocRef.collection('attendance');

    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Name cannot be empty!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    showLoaderDialog(context);

    try {
      await attendanceCollection.add({
        'address': alamat,
        'name': nama,
        'description': status,
        'datetime': strDateTime,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text("Yeay! Attendance Report Succeeded!", style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.orangeAccent,
        behavior: SnackBarBehavior.floating,
      ));

      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const HomeAttendance()));
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text("Ups, $e", style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    setState(() {
      isLoading = false;
      getAddressFromLongLat(position);
    });
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude);
    Placemark place = placemarks[0];

    setState(() {
      dLat = position.latitude;
      dLong = position.longitude;
      strAddress =
      "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
    });
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showLocationError("Location services are disabled."
          " Please enable the services.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showLocationError("Location permit denied.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showLocationError("Location permission denied forever, we cannot access.");
      return false;
    }
    return true;
  }

  void showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.location_off, color: Colors.white),
          const SizedBox(width: 10),
          Text(message, style: const TextStyle(color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.blueGrey,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blueGrey)),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("Checking the data..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void setDateTime() {
    var dateNow = DateTime.now();
    var dateFormat = DateFormat('dd MMMM yyyy');
    var dateTimeFormat = DateFormat('HH:mm:ss');
    var dateHourFormat = DateFormat('HH');
    var dateMinuteFormat = DateFormat('mm');

    setState(() {
      strDate = dateFormat.format(dateNow);
      strTime = dateTimeFormat.format(dateNow);
      strDateTime = "$strDate | $strTime";

      dateHour = int.parse(dateHourFormat.format(dateNow));
      dateMinute = int.parse(dateMinuteFormat.format(dateNow));
    });
  }

  void setStatusAbsent() {
    if (dateHour < 8 || (dateHour == 8 && dateMinute <= 30)) {
      strStatus = 'Attendance';
    } else if (dateHour < 18) {
      strStatus = 'Late';
    } else {
      strStatus = 'Absent';
    }
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

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
        child: Card(
            color: Colors.white,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.blueAccent,
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 12,
                      ),
                      Icon(Icons.face_retouching_natural_outlined, color: Colors.white),
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Please make a selfie photo!",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 20),
                  child: Text(
                    "Capture Photo",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraPage()));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                    width: size.width,
                    height: 150,
                    child: DottedBorder(
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      color: Colors.blueAccent,
                      strokeWidth: 1,
                      dashPattern: const [5, 5],
                      child: SizedBox.expand(
                        child: FittedBox(
                          child: image != null
                              ? Image.file(File(image!.path), fit: BoxFit.cover)
                              : const Icon(
                            Icons.camera_enhance_outlined,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    enabled: false,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    controller: controllerName,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      labelText: "Your Name",
                      hintText: "Please enter your name",
                      hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey),
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
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "Your Location",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
                isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: 5 * 24,
                    child: TextField(
                      enabled: false,
                      maxLines: 5,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                        hintText: strAddress != null
                            ? strAddress
                            : strAddress = 'Your Location',
                        hintStyle: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                        fillColor: Colors.transparent,
                        filled: true,
                      ),
                    ),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(30),
                    child: Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blueAccent,
                          child: InkWell(
                            splashColor: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              if (image == null || controllerName.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Please Fill all the forms!",
                                          style: TextStyle(color: Colors.white))
                                    ],
                                  ),
                                  backgroundColor: Colors.blueGrey,
                                  shape: StadiumBorder(),
                                  behavior: SnackBarBehavior.floating,
                                ));
                              } else {
                                submitAbsen(strAddress, controllerName.text.toString(), strStatus);
                              }
                            },
                            child: const Center(
                              child: Text(
                                "Report Now",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            )),
      ),
    );
  }
}