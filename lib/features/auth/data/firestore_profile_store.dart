import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/user_profile.dart';
import '../domain/user_profile_store.dart';

class FirestoreProfileStore implements UserProfileStore {
  FirestoreProfileStore(this.firestore);
  final FirebaseFirestore firestore;
  static const timeout = Duration(seconds: 12);
  @override
  Future<UserProfile?> read(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(timeout);
    final data = snapshot.data();
    return data == null ? null : UserProfile.fromJson({...data, 'uid': uid});
  }

  @override
  Future<void> save(UserProfile profile, {bool created = false}) => firestore
      .collection('users')
      .doc(profile.id)
      .set({
        ...profile.toJson(),
        if (created) 'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
      .timeout(timeout);
}
