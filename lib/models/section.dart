// lib/models/section.dart

class Section {
  final int id;
  final String code;

  const Section({required this.id, required this.code});

  factory Section.fromMap(Map<String, dynamic> m) {
    return Section(
      id: (m['id'] as num).toInt(),
      code: (m['code'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
      };
}
