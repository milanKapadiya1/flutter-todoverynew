import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_verynew/model/task_details.dart';
import 'package:todo_verynew/presentation/todos/firestore_collection.dart';
import 'package:todo_verynew/util/app_constants.dart';

import 'package:uuid/uuid.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final List<TaskDetails> _tasks = [];
  bool isLoading = false;
  final firestore = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    fetchAllTasksOptimised();
  }

  Future<void> fetchAllTasksOptimised() async {
    setState(() {
      isLoading = true;
    });
    final todoSnap = await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .where('isDone', isEqualTo: false)
        .get();

    final todos = todoSnap.docs;

 
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

  Future<void> createNewTask(TaskDetails task) async {
    final firestore = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      AppConstans.showSnackBar(context, message: 'no uid found');
      return;
    }
    
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(task.id)
        .set(task.toJson()); 

    // await fetchAllTasksOptimised();
   
  }

Future<void> markAsCompleted(TaskDetails task) async {
  try {
    await firestore
        .collection(FirestoreCollections.todoListCollection)
        .doc(uid)
        .collection(FirestoreCollections.todosCollection)
        .doc(task.id)
        .update({"isDone": true});

    if (!mounted) return;
    AppConstans.showSnackBar(
      context,
      isSuccess: true,
      message: 'your task is marked as done',
    );

    if (!mounted) return;
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });
  } catch (e) {
    if (!mounted) return;
    AppConstans.showSnackBar(
      context,
      isSuccess: false,
      message: 'Failed to mark task as done: $e',
    );
  }
}
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
     final uid = FirebaseAuth.instance.currentUser?.uid;
     final uuid = const Uuid();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final desc = descController.text.trim();
              if (title.isNotEmpty) {
                final newTask = TaskDetails(title: title, description: desc, id: uuid.v1());
                setState(() {
                  _tasks.add(newTask);
                });
                Navigator.pop(context);
                await createNewTask(newTask);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TodoEasy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(
                  child: Text(
                    'No tasks yet.\nTap + to add your first task!',
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
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (value) async {
                            await markAsCompleted(task);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone ? TextDecoration.lineThrough : null,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add Task',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}