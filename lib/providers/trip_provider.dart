import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/trip_model.dart';

class TripListProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance; 
  List<Trip> _trips = []; // Internal list of trips

  // Getter to expose the private for _trips list
  List<Trip> get trips => _trips;

  // Loads all trips associated with the currently authenticated user
  Future<void> loadTrips() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _db
        .collection('trips')
        .where('uid', isEqualTo: uid)
        .get();

    // Convert documents to Trip objects
    _trips = snapshot.docs
        .map((doc) => Trip.fromFirestore(doc))
        .toList();

    notifyListeners(); 
  }

  // Adds a new trip to Firestore and updates the local list
  Future<void> addTrip(Trip trip, String userId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid; 
    if (uid == null) return;

  Map<String, dynamic> tripData = trip.toJson();
  tripData['uid'] = uid;

  // Add the trip data to the 'trips' collection in Firestore
  final docRef = await _db.collection('trips').add(tripData);

    // Add the newly created trip
    _trips.add(trip.copyWith(id: docRef.id));
    notifyListeners();
  }

  Future<void> editTrip(String id, Map<String, dynamic> data) async {
    await _db.collection('trips').doc(id).update(data); 
    await loadTrips();
  }

  // Deletes an trip
  Future<void> deleteTrip(String id) async {
    await _db.collection('trips').doc(id).delete(); // Delete from Firestore
    _trips.removeWhere((e) => e.id == id); // Remove locally
    notifyListeners(); 
  }
}
