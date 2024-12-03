

class Transacao {
  final String id;
  final String title;
  final double value;
  final DateTime data;
  final bool entrada;

  Transacao({
    required this.id,
    required this.title,
    required this.value,
    required this.data,
    required this.entrada,
  });
}
