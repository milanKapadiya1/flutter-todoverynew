import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_verynew/model/task_details.dart';
import 'package:todo_verynew/presentation/todos/firestore_collection.dart';
// import 'package:todo_verynew/util/app_constants.dart';
// import 'package:uuid/uuid.dart';

class FinishedTasksScreen extends StatefulWidget {
  const FinishedTasksScreen({super.key});

  @override
  State<FinishedTasksScreen> createState() => _FinishedTasksScreenState();
}

class _FinishedTasksScreenState extends State<FinishedTasksScreen> {
  final List<TaskDetails> _tasks = [];
  bool isLoading = true;
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchAllFinishedTasks();
  }

  Future<void> fetchAllFinishedTasks() async {
    setState(() {
      isLoading = true;
    });

    final todoSnap = await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .where('isDone', isEqualTo: true) // The key change
        .get();

    final todos = todoSnap.docs;

    _tasks.clear(); // Clear existing tasks
    todos
        .map((element) => _tasks.add(TaskDetails.fromJson(element.data())))
        .toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _deleteTask({
    required int index,
    required String taskId,
  }) async {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(taskId)
        .delete();

    setState(() {
      _tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Tasks'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Text(
                    'No finished tasks yet.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  itemCount: _tasks.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            task.description.isNotEmpty ? Text(task.description) : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteTask(index: index, taskId: task.id),
                          tooltip: 'Delete',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}