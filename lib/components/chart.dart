import 'package:flutter/material.dart';
import 'package:app_despesas/transacao.dart';
import 'package:intl/intl.dart';
import 'chart_bar.dart';

class Chart extends StatelessWidget {
  final List<Transacao> recentTransacao;

  Chart(this.recentTransacao);

  List<Map<String, dynamic>> get groupedTransacoes {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(
        Duration(days: index),
      );

      double totalSum = 0.0;

      for (var i = 0; i < recentTransacao.length; i++) {
        bool sameDay = recentTransacao[i].data.day == weekDay.day;
        bool sameMonth = recentTransacao[i].data.month == weekDay.month;
        bool sameYear = recentTransacao[i].data.year == weekDay.year;

        if (sameDay && sameMonth && sameYear) {
          totalSum += recentTransacao[i].entrada ? recentTransacao[i].value : -recentTransacao[i].value;
        }
      }

      return {
        'day': DateFormat.E('pt_BR').format(weekDay).substring(0, 3), 
        'value': totalSum
      };
    }).reversed.toList();
  }

  double get _weekTotalValue {
    return groupedTransacoes.fold(0.0, (sum, tr) {
      return sum + tr['value'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: groupedTransacoes.map((tr) {
            return Flexible(
              fit: FlexFit.tight,
              child: ChartBar(
                label: tr['day'],
                value: tr['value'],
                percentage: _weekTotalValue == 0 ? 0 : (tr['value'] / _weekTotalValue),
              ),
            ); 
          }).toList(),
        ),
      ),
    );
  }
}
