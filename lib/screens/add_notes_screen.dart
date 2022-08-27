import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/database/database.dart';
import 'package:todo/models/note_model.dart';
import 'package:todo/screens/home_page.dart';

class AddNotesScreen extends StatefulWidget {
  final Note? note;
  final Function? updateNoteList;

  const AddNotesScreen({
    Key? key,
    this.note,
    this.updateNoteList,
  }) : super(key: key);

  @override
  State<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends State<AddNotesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  DateTime _date = DateTime.now();
  String _pr = 'High';
  String _title = '';
  String btnText = 'Add Task';
  String titleText = 'Add Task';

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final List<String> _priorties = ['High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _title = widget.note!.title!;
      _date = widget.note!.date!;
      _pr = widget.note!.priorty!;
      setState(() {
        btnText = "Update Task";
        titleText = "Update Task";
      });
    } else {
      setState(() {
        btnText = "Add Task";
        titleText = "Add Task";
      });
    }

    _dateController.text = _dateFormat.format(_date);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormat.format(date);
    }
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      debugPrint('$_title, $_pr ,$_date');
      Note note = Note(title: _title, date: _date, priorty: _pr);

      if (widget.note == null) {
        note.status = 0;
        DatabaseHelper.instance.insertNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      } else {
        note.id = widget.note!.id;
        note.status = widget.note!.status;
        DatabaseHelper.instance.updateNote(note);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      }

      widget.updateNoteList!();
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteNote(widget.note!.id!);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
    );
    widget.updateNoteList!();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 80,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.blueGrey.shade500,
                        size: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Text(
                      titleText,
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please enter a title'
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          onTap: _handleDatePicker,
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: DropdownButtonFormField(
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down_circle,
                            color: Colors.grey.shade500,
                          ),
                          iconSize: 22,
                          iconEnabledColor: Colors.grey.shade500,
                          items: _priorties.map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(
                                e,
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey.shade800),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey.shade800),
                          decoration: InputDecoration(
                            labelText: 'Priorty',
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // ignore: unnecessary_null_comparison
                          validator: (value) =>
                              // ignore: unnecessary_null_comparison
                              _pr == null ? 'Please select a priorty ' : null,
                          onChanged: (value) {
                            setState(() {
                              _pr = value.toString();
                            });
                          },
                          value: _pr,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade500,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blueGrey.shade500),
                          onPressed: _submit,
                          child: Text(
                            btnText,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      widget.note != null
                          ? Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.grey.shade500),
                                onPressed: _delete,
                                child: const Text(
                                  'Delete Task',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
