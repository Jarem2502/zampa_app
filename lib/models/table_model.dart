class TableModel {
  final int id;
  final String name;
  final int capacity;
  final String status;

  TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Mesa',
      capacity: json['capacity'] ?? 4,
      status: json['status'] ?? 'ocupada',
    );
  }
}
