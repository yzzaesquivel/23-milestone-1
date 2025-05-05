import 'package:flutter/material.dart';
import 'package:my_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../../models/trip_model.dart';
import '../../../../providers/trip_provider.dart';


class TripModal extends StatefulWidget {
  final String type; // Determines whether it's Add, Edit, or Delete
  final Trip? trip; 

  const TripModal({
    super.key,
    required this.type,
    this.trip,
  });

  @override
  State<TripModal> createState() => _TripModalState();
}

class _TripModalState extends State<TripModal> {
  // Text controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _category; 
  bool _paid = false; 
  final _formKey = GlobalKey<FormState>(); 

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill the form fields with existing trip data
    if (widget.trip != null) {
      _nameController.text = widget.trip!.name;
      _descriptionController.text = widget.trip!.description;
      _amountController.text = widget.trip!.amount.toString();
      _category = widget.trip!.category;
      _paid = widget.trip!.paid;
    }
  }

  // Return a title widget based on the modal type
  Text _buildTitle() {
    switch (widget.type) {
      case 'Add':
        return const Text("Add New Trip");
      case 'Edit':
        return const Text("Edit Trip");
      case 'Delete':
        return const Text("Delete Trip");
      default:
        return const Text("");
    }
  }

  // Build modal content depending on action type
  Widget _buildContent(BuildContext context) {
    // For deleting, just show a confirmation message
    if (widget.type == 'Delete') {
      return Text("Are you sure you want to delete '${widget.trip!.name}'?");
    }

    // For adding/editing, show a form
    return SizedBox(
      width: 300,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input field for name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Trip Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Enter an Trip Name first.' : null,
            ),
            // Input field for description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Add a Description.' : null,
            ),
            // Input field for amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter the amount.';
                if (int.tryParse(value) == null) return 'Enter a VALID amount only.';
                return null;
              },
            ),
            // Dropdown for category selection
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Select Category'),
              items: <String>[
                'Bills',
                'Transportation',
                'Food',
                'Utilities',
                'Health',
                'Entertainment',
                'Miscellaneous'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue;
                });
              },
              validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please select a category.' : null,
            ),
            // Checkbox for paid status
            CheckboxListTile(
              title: const Text('Paid'),
              value: _paid,
              onChanged: (bool? value) {
                setState(() {
                  _paid = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ],
        ),
      ),
    );
  }

  TextButton _dialogAction(BuildContext context) {
    return TextButton(
      onPressed: () {
        final tripProvider = context.read<TripListProvider>();
        final userProvider = context.read<UserAuthProvider>();

        final userId = userProvider.user?.uid;
        if (userId == null) {
          // Show a message if the user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not authenticated.")),
          );
          return;
        }

        // If the user confirms deletion
        if (widget.type == 'Delete') {
          if (widget.trip != null) {
            tripProvider.deleteTrip(widget.trip!.id!);
          }
          Navigator.of(context).pop();
        } else {
          // Validate form before proceeding
          if (_formKey.currentState!.validate()) {
            final newTrip = Trip(
              name: _nameController.text,
              description: _descriptionController.text,
              category: _category!,
              amount: double.parse(_amountController.text),
              paid: _paid,
            );

            if (widget.type == 'Add') {
              tripProvider.addTrip(newTrip, userId);
            } else if (widget.type == 'Edit') {
              tripProvider.editTrip(widget.trip!.id!, newTrip.toJson());
            }

            Navigator.of(context).pop();
          }
        }
      },
      child: Text(widget.type), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(), 
      content: _buildContent(context),
      actions: [
        _dialogAction(context), 
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
