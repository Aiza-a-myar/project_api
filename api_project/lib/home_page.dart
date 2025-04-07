import 'package:flutter/material.dart';
import 'student_model.dart';
import 'api_service.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Student> students = [];

  @override
  void initState() {
    super.initState();
    _loadFromDatabase(); // Load saved data initially (if any)
  }

  // Load from SQLite
  Future<void> _loadFromDatabase() async {
    final data = await DatabaseHelper.instance.getStudents();
    setState(() {
      students = data;
    });
  }

  // Load from API and save to SQLite
  Future<void> _loadDataFromAPI() async {
    final apiStudents = await ApiService.fetchStudents();
    for (var student in apiStudents) {
      await DatabaseHelper.instance.insertStudent(student);
    }
    _loadFromDatabase(); // Refresh UI from DB
  }

  // Delete all data
  Future<void> _removeAllData() async {
    await DatabaseHelper.instance.deleteAllStudents();
    setState(() {
      students.clear();
    });
  }

  // Delete a single student
  Future<void> _deleteStudentById(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _loadFromDatabase(); // Refresh the list after delete
  }

  Widget _buildStudentCard(Student s) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: ListTile(
        title: Text("${s.coursetitle} (${s.coursecode})"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Marks: ${s.obtainedmarks}"),
            Text("Student: ${s.studentname} (${s.rollno})"),
            Text("Semester: ${s.mysemester} | Shift: ${s.shift}"),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            if (s.id != null) {
              _deleteStudentById(s.id!);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Data'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _loadDataFromAPI,
                child: const Text("Load Data"),
              ),
              ElevatedButton(
                onPressed: _removeAllData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Remove Data"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("No data loaded."))
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) =>
                  _buildStudentCard(students[index]),
            ),
          ),
        ],
      ),
    );
  }
}
