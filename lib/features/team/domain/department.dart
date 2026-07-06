class Department {
  const Department({
    required this.id,
    required this.name,
    this.employeeCount = 0,
    this.managerName = '',
  });

  final String id;
  final String name;

  /// Mock-only headcount/manager fluff for the admin departments screen —
  /// `GET /departments` on the real backend returns neither, so both default
  /// to empty when built from live data.
  final int employeeCount;
  final String managerName;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
        id: json['id'] as String,
        name: json['name'] as String,
      );
}
