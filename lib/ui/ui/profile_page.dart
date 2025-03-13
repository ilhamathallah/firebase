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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedImage != null) {
      setState(() => imageFile = File(pickedImage.path));
      _uploadImage(imageFile!);
    }
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
            radius: 60,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: profileImage != null && profileImage!.isNotEmpty
                ? NetworkImage(profileImage!) as ImageProvider
                : const AssetImage('assets/image/hiu.png'),
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
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
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
          "Profile Page",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userData,
        builder: (context, snapshot){
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
                SizedBox(height: 30,),
                Center(child: _buildProfileImage()),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    '${snapshot.data!['role']}',
                    style: subWelcomeTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 5,),
                Center(
                  child: Text(
                    '${snapshot.data!['email']}',
                    style: subWelcomeTextStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                  onPressed: _updateProfile,
                  icon: const Icon(Icons.save, color: Colors.white,),
                  label: const Text('Save', style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Main Menu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blue),),
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
                          leading: Icon(Icons.verified_rounded, color: Colors.grey,),
                          title: Text('Email Verification', style: TextStyle(color: Colors.black54, fontSize: 14),),
                          onTap: () async {
                            await FirebaseAuth.instance.currentUser!.sendEmailVerification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Verification email send')),
                            );
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        ListTile(
                          leading: Icon(Icons.lock_reset, color: Colors.grey,),
                          title: Text('Change Password', style: TextStyle(color: Colors.black54, fontSize: 14),),
                          onTap: (){
                            Navigator.pushNamed(context, '/change-password');
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.grey,),
                          title: Text('Logout', style: TextStyle(color: Colors.black54, fontSize: 14),),
                          onTap: (){
                            _signOut();
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
