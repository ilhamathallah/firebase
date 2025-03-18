part of '../pages.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseService _auth = FirebaseService();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool isLoading = false;
  String? profileImage;
  File? imageFile;
  String? _selectedImage;

  String? userId;
  late Future<Map<String, dynamic>> userData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();

    User? user = _auth.currentUser;

    userId = user!.uid;
    userData = _auth.getUserData(userId!);
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/sign-in');
  }

  Future<void> _updateProfile() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();

    await _auth.updateProfile(firstName, lastName);

    setState(() => isLoading = false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            const SizedBox(height: 40),
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                  labelText: 'First Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                  labelText: 'Last Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: _updateProfile,
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(context: context, builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.male, color: Colors.blue),
            title: const Text('Pilih Gambar Laki-laki'),
            onTap: () {
              setState(() => _selectedImage = 'assets/icons/male_person.png');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.female, color: Colors.pink),
            title: const Text('Pilih Gambar Perempuan'),
            onTap: () {
              setState(() => _selectedImage = 'assets/icons/female_person.png');
              Navigator.pop(context);
            },
          ),
        ],
      );
    });
  }

  Future<void> _uploadImage(File imageFile) async {
    setState(() => isLoading = true);

    String userId = FirebaseAuth.instance.currentUser!.uid;
    Reference reference =
        FirebaseStorage.instance.ref().child('profile/$userId');

    UploadTask uploadTask = reference.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    await _auth.uploadProfileImage(imageUrl);
    setState(() {
      profileImage = imageUrl;
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Profile image updated successfully'),
      backgroundColor: Colors.green,
    ));
  }

  Future<void> _loadProfileData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String userId = user.uid;
    Map<String, dynamic> userData = await _auth.getUserData(userId);

    setState(() {
      firstNameController.text = userData['first_name'] ?? '';
      lastNameController.text = userData['last_name'] ?? '';
      profileImage = userData['profile_image'] ?? '';
    });
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _selectedImage != null
                ? AssetImage(_selectedImage!)
                : null, // Jika tidak dipilih, kosong
            child: _selectedImage == null
                ? const Icon(Icons.person, size: 50, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
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
          "Student",
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: Colors.blue),
        ),
        centerTitle: true,
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
            child: ListView(
              children: [
                Row(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${snapshot.data!['first_name']} ${snapshot.data!['last_name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _updateProfile();
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        Text(
                          'Roll : ${snapshot.data!['role']}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // kiri
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Registration email',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${snapshot.data!['email']}',
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admission number',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '000247',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Academic year',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '2023-2026',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of admission',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '1 July 2020',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Main Menu",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue),
                          ),
                        ),
                        Divider(),
                        FirebaseAuth.instance.currentUser!.emailVerified
                            ? Text(
                                "✔️ Email Verified",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : ListTile(
                                leading: Icon(
                                  Icons.verified_rounded,
                                  color: Colors.grey,
                                ),
                                title: Text(
                                  'Email Verification',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 14),
                                ),
                                onTap: () async {
                                  await FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Verification email send')),
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                        ListTile(
                          leading: Icon(
                            Icons.lock_reset,
                            color: Colors.grey,
                          ),
                          title: Text(
                            'Change Password',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/change-password');
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.logout,
                            color: Colors.grey,
                          ),
                          title: Text(
                            'Logout',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          onTap: () {
                            _signOut();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
