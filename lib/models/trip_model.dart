
class Trip {
  final String? id;
  final String name;    
  final String description;  
  final String category;     
  final double amount;      
  final bool paid;     

  // Constructor to initialize all fields
  Trip({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.amount,
    required this.paid,
  });


  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'amount': amount,
        'paid': paid,
      };

  // Factory constructor to create an Trip object from a Firestore document
  // based sa given code sa isang prof
  factory Trip.fromFirestore(dynamic doc) {
    final data = doc.data(); // Extract data from the document
    return Trip(
      id: doc.id, // Use Firestore document ID as trip ID
      name: data['name'],
      description: data['description'],
      category: data['category'],
      amount: data['amount'],
      paid: data['paid'],
    );
  }

  // Creates a copy of the Trip with a new or existing ID
  Trip copyWith({String? id}) => Trip(
        id: id ?? this.id,
        name: name,
        description: description,
        category: category,
        amount: amount,
        paid: paid,
      );
}