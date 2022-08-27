import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/database/database.dart';
import 'package:todo/models/note_model.dart';
import 'package:todo/screens/add_notes_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Note>> noteList;

  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');

  DatabaseHelper databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    noteList = DatabaseHelper.instance.getNoteList();
  }

  Widget buildNote(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          ListTile(
            title: Text(
              note.title!,
              style: TextStyle(
                color: Colors.blueGrey.shade500,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${dateFormatter.format(note.date!)} - ${note.priorty}',
              style: TextStyle(
                color: Colors.blueGrey.shade300,
                fontSize: 18,
                decoration: note.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                note.status = value! ? 1 : 0;

                DatabaseHelper.instance.updateNote(note);
                _updateNoteList();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              activeColor: Colors.grey,
              value: note.status == 1 ? true : false,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddNotesScreen(
                  updateNoteList: _updateNoteList(),
                  note: note,
                ),
              ),
            ),
          ),
          Divider(
            height: 5,
            color: Colors.grey.shade100,
            thickness: 2,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade500,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) {
                return AddNotesScreen(
                  updateNoteList: _updateNoteList,
                );
              },
            ),
          );
        },
      ),
      body: FutureBuilder(
        future: noteList,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedNoteCount = snapshot.data!
              .where((Note note) => note.status == 1)
              .toList()
              .length;
          return ListView.builder(
            itemCount: int.parse(snapshot.data!.length.toString()) + 1,
            padding: const EdgeInsets.symmetric(vertical: 80),
            itemBuilder: (BuildContext contx, int index) {
              if (index == 0) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks to do',
                        style: TextStyle(
                          color: Colors.blueGrey.shade500,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Tasks completed: $completedNoteCount of ${snapshot.data.length}',
                        style: TextStyle(
                          color: Colors.blueGrey.shade300,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return buildNote(snapshot.data![index - 1]);
            },
          );
        },
      ),
    );
  }
}
