import 'package:flutter/material.dart';

class ChartBar extends StatelessWidget { //class do chat bar
  final String label;
  final double value;
  final double percentage;

  ChartBar({//passando parametros como obrigatorios
    required this.label,//titulo
    required this.value,//valor
    required this.percentage,//porcentagem
   
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(//container do chart
          height: 20,
          child: FittedBox(child: Text('${value.toStringAsFixed(2)}'))),
        SizedBox(height: 5),
        Container(//conteiner das barras
          height: 60,
          width: 10,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 184, 184, 184),
                    width: 1.0,
                  ),
                  color: const Color.fromARGB(255, 184, 184, 184),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(//barra de carregamento do chart
                 heightFactor: percentage.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                     color: const Color.fromARGB(255, 19, 138, 92),
                  borderRadius: BorderRadius.circular(3), 
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}