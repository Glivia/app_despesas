

class Transacao {//inicio class transação 
  final String id;
  final String title;
  final double value;
  final DateTime data;
  final bool entrada;

  Transacao({ //dizendo que sao parametros obrigatorios
    required this.id,
    required this.title,
    required this.value,
    required this.data,
    required this.entrada,
  });
}