import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTripApi {
  final FirebaseFirestore db = FirebaseFirestore.instance; // Firestore instance

  // Fetch all trips
  Stream<QuerySnapshot> getAllTrips() {
    return db.collection('trips').snapshots();
  }

  // Add a trip
  Future<String> addTrip(Map<String, dynamic> trip) async {
    try {
      trip['id'] = db.collection('trips').doc().id;
      await db.collection('trips').doc(trip['id']).set(trip);
      return "Successfully added trip!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }

  // Delete a trip
  Future<String> deleteTrip(String id) async {
    try {
      await db.collection('trips').doc(id).delete();
      return "Successfully deleted trip!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }

  // Edit a trip
  Future<String> editTrip(String id, Map<String, dynamic> updatedTrip) async {
    try {
      await db.collection('trips').doc(id).update(updatedTrip);
      return "Successfully updated trip!";
    } catch (e) {
      return "Error on ${e.toString()}";
    }
  }
}
