import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/trip_model.dart';
import '../../../../providers/trip_provider.dart';
import '../../../../providers/auth_provider.dart';
import 'modal_trip.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  bool _isLoaded = false; // Tracks if trips have already been loaded

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load trips once the user is signed in
    if (!_isLoaded) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<TripListProvider>().loadTrips();
        _isLoaded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Trip> trips = context.watch<TripListProvider>().trips;

    return Scaffold(
          // Custom AppBar with purple background and white, bold title
          appBar: AppBar(
            title: const Text(
              "My Trips",
              style: TextStyle(
                color: Colors.white,  
                fontWeight: FontWeight.bold,  
              ),
            ),
            backgroundColor: Colors.purple, 
            actions: [
              // Logout button in app bar
              ElevatedButton.icon(
                onPressed: () => context.read<UserAuthProvider>().signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ],
          ),

      // Show message if no trips, otherwise show list
      body: trips.isEmpty
          ? const Center(
              child: Text("No Trips Found. Click the button to add!"),
            )
          : ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                Trip trip = trips[index];

                return Dismissible(
                  key: Key(trip.id.toString()),
                  onDismissed: (direction) {
                    // Delete trip on swipe
                    context.read<TripListProvider>().deleteTrip(trip.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${trip.name} dismissed')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    child: const Icon(Icons.delete),
                  ),
                  child: ListTile(
                    // Trip name as the title
                    title: Text(
                      trip.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show amount and category
                        Text('₱${trip.amount.toStringAsFixed(2)} - ${trip.category}'),
                        Row(
                          children: [
                            // Show check or cancel icon based on paid status
                            Icon(
                              trip.paid ? Icons.check_circle : Icons.cancel,
                              color: trip.paid ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            // Show "Paid" or "Not Paid" 
                            Text(
                              trip.paid ? 'Paid' : 'Not Paid',
                              style: TextStyle(
                                color: trip.paid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Show trip details on tap
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Trip Details'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${trip.name}'),
                              Text('Description: ${trip.description}'),
                              Text('Category: ${trip.category}'),
                              Text('Amount: ₱${trip.amount.toStringAsFixed(2)}'),
                              Text('Status: ${trip.paid ? 'Paid' : 'Not Paid'}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    // Edit and delete buttons
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  TripModal(type: 'Edit', trip: trip),
                            );
                          },
                          icon: const Icon(Icons.create_outlined),
                        ),
                        // Delete button opens modal in 'Delete' mode
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  TripModal(type: 'Delete', trip: trip),
                            );
                          },
                          icon: const Icon(Icons.delete_outlined),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

      // Floating button to  a new trip
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => const TripModal(type: 'Add'),
          );
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
