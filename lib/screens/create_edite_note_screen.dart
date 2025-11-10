import 'package:flutter/material.dart';
import 'package:notes/database/notes_db.dart';

class CreateEditeNoteScreen extends StatefulWidget {
  const CreateEditeNoteScreen({super.key, this.note});
  final Notes? note;
  @override
  State<CreateEditeNoteScreen> createState() => _CreateEditeNoteScreenState();
}

class _CreateEditeNoteScreenState extends State<CreateEditeNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
  }

  // SAVE NOTE ====
  Future<void> saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill All Fields')));
      return;
    }
    setState(() => isLoading = true);
    final note = Notes(
      id: widget.note?.id,
      title: title,
      content: content,
      createdTime: widget.note?.createdTime ?? DateTime.now(),
    );

    if (widget.note != null) {
      await NoteDatabase.instance.update(note);
    } else {
      await NoteDatabase.instance.create(note);
    }
    Navigator.pop(context);
  }

  // DELETE NOTE ====
  Future<void> deleteNote() async {
    setState(() => isLoading = true);
    await NoteDatabase.instance.delete(widget.note!.id!);
    setState(() => isLoading = false);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        actions: [
          IconButton(
            onPressed: () {
              deleteNote();
            },
            icon: Icon(Icons.delete, size: 30),
          ),
          IconButton(
            onPressed: () {
              saveNote();
            },
            icon: Icon(Icons.save, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
                TextField(
                  controller: _contentController,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 12,
                  decoration: InputDecoration(
                    hintText: 'Type Something ....',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
