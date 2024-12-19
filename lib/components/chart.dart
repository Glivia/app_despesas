import 'package:flutter/material.dart';
import 'package:app_despesas/transacao.dart';
import 'package:intl/intl.dart';
import 'chart_bar.dart';

class Chart extends StatelessWidget {
  final List<Transacao> recentTransacao;

  Chart(this.recentTransacao);

  List<Map<String, dynamic>> get agrupaTransacoes {
    return List.generate(7, (index) {//gera lista com 7 elementos, cada dia da semana
      final weekDay = DateTime.now().subtract(//calcula a data de cada dia voltando 7 dias a partir da data atual
        Duration(days: index),//subtração do index em dias
      );

      double totalSum = 0.0;//soma total inicia zerado

      for (var i = 0; i < recentTransacao.length; i++) {
        bool Dia = recentTransacao[i].data.day == weekDay.day;//verifica se a transação ocorreu no mesmo dia
        bool Mes = recentTransacao[i].data.month == weekDay.month;//mesmo mês
        bool Ano = recentTransacao[i].data.year == weekDay.year;//mesmo ano

        if (Dia && Mes && Ano) {//se for mesmo dia, mes e ano
          totalSum += recentTransacao[i].entrada ? recentTransacao[i].value : -recentTransacao[i].value;//soma o valor ao valor total
        }//se for entrada ele soma, se for saida subtrai
      }

      return {
        'day': DateFormat.E('pt_BR').format(weekDay).substring(0, 3),//abrevia os dias da semana
        'value': totalSum
      };
    }).reversed.toList();//inverte a lista para o dia mais antigo seja o primeiro da lista e atual seja o ultimo
  }

  double get _TotalValueSemanal {
    return agrupaTransacoes.fold(0.0, (sum, tr) {//acumula os valores
      return sum + tr['value'];//soma o valor de cada transação ao total acumulado
    });
  }

  @override
  Widget build(BuildContext context) {//card dos charts
    return Card(
      elevation: 6,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: agrupaTransacoes.map((tr) {
            return Flexible(
              fit: FlexFit.tight,//cada barra ocupa o maior espaço possível igualmente
              child: ChartBar(
                label: tr['day'],//dia da semana
                value: tr['value'],//valor do dia
                percentage: _TotalValueSemanal == 0 ? 0 : (tr['value'] / _TotalValueSemanal),//calcula a porcentagem do valor total da semana
              ),
            ); 
          }).toList(),
        ),
      ),
    );
  }
}