part of '../pages.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _addNote() async {
    if (_titleController.text.isNotEmpty &&
        _imageUrlController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      await _firebaseService.addNote(
        _titleController.text,
        _imageUrlController.text,
        _contentController.text,
      );
      _clearFields();
    }
  }

  void _deleteNote(String noteId) async {
    await _firebaseService.deleteNotes(noteId);
  }

  void _updateNote(
      String noteId, String title, String imageUrl, String content) async {
    _titleController.text = title;
    _imageUrlController.text = imageUrl;
    _contentController.text = content;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Update Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _buildTextFields(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _firebaseService.updateNote(
                  noteId,
                  _titleController.text,
                  _contentController.text,
                  _imageUrlController.text,
                );
                Navigator.pop(context);
                _clearFields();
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _titleController.clear();
    _imageUrlController.clear();
    _contentController.clear();
  }

  List<Widget> _buildTextFields() {
    return [
      TextFormField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: "Title",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      const SizedBox(height: 15),
      TextFormField(
        controller: _imageUrlController,
        decoration: InputDecoration(
          hintText: "Image URL",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 15),
      TextFormField(
        controller: _contentController,
        decoration: InputDecoration(
          hintText: "Content",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        maxLines: 3,
      ),
    ];
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
          "Note",
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
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 12),
                  ..._buildTextFields(),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _addNote,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Save Note',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // List Notes
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firebaseService.getNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No notes found',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        color: Colors.white,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              doc['imageUrl'],
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            doc['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            doc['content'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _updateNote(
                                  doc.id,
                                  doc['title'],
                                  doc['imageUrl'],
                                  doc['content'],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNote(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
