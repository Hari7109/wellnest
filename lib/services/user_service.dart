import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getStudentData(String regNo) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(regNo).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching student data: $e');
      return null;
    }
  }
}
