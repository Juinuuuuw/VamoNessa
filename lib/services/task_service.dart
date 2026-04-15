import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Task>> getTasks(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList(),
        );
  }

  Future<void> createTask({
    required String eventId,
    required String title,
    String description = '',
    String? assignedTo,
    String? assignedToName,
    DateTime? dueDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final task = Task(
      id: '',
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      dueDate: dueDate,
      createdBy: user.uid,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .add(task.toMap());
  }

  Future<void> updateTaskStatus(
    String eventId,
    String taskId,
    String newStatus,
  ) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .doc(taskId)
        .update({'status': newStatus});
  }

  Future<void> deleteTask(String eventId, String taskId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  Future<void> assignTask(
    String eventId,
    String taskId,
    String userId,
    String userName,
  ) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('tasks')
        .doc(taskId)
        .update({'assignedTo': userId, 'assignedToName': userName});
  }
}
