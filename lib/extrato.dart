import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'transacao.dart';
import 'database/supabase.dart';
import 'main.dart';

class Extrato extends StatefulWidget {
  @override
  _Extrato createState() => _Extrato();
}

class _Extrato extends State<Extrato> {
  final List<Transacao> _transacoes = [];

  double _totalEntradas = 0.0;
  double _totalSaidas = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();
  }

  _carregarTransacoes() async {
    try {
      final transacoes = await Database().getTransacoes();

      List<Transacao> transacoesList = transacoes.map((tr) {
        return Transacao(
          id: tr['id'],
          title: tr['titulo'],
          value: tr['valor'],
          data: DateTime.parse(tr['data']),
          entrada: tr['entrada'],
        );
      }).toList();

      double entradas = 0.0;
      double saidas = 0.0;
      for (var tr in transacoesList) {
        if (tr.entrada) {
          entradas += tr.value;
        } else {
          saidas += tr.value;
        }
      }

      setState(() {
        _transacoes.clear();
        _transacoes.addAll(transacoesList);
        _totalEntradas = entradas;
        _totalSaidas = saidas;
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final transacoesAgrupadas = <String, List<Transacao>>{};
    for (var tr in _transacoes) {
      final dateKey = DateFormat('dd/MM/yyyy').format(tr.data);
      if (!transacoesAgrupadas.containsKey(dateKey)) {
        transacoesAgrupadas[dateKey] = [];
      }
      transacoesAgrupadas[dateKey]!.add(tr);
    }

    final datasOrdenadas = transacoesAgrupadas.keys.toList()..sort((a, b) {
      final dateA = DateFormat('dd/MM/yyyy').parse(a);
      final dateB = DateFormat('dd/MM/yyyy').parse(b);
      return dateB.compareTo(dateA); 
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Extrato',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
          ),
        ),
      centerTitle: true, 
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Entradas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'R\$${_totalEntradas.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                // Saídas com seta
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Saídas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'R\$${_totalSaidas.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: datasOrdenadas.length,
              itemBuilder: (ctx, index) {
                final data = datasOrdenadas[index];
                final transacoes = transacoesAgrupadas[data]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        data,
                        style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                        ),
                      ),
                    ),
                    ...transacoes.map((tr) {
                      Color transacaoColor = tr.entrada ? Colors.green : Colors.red;
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transacaoColor,
                            child: Icon(
                            tr.entrada ? Icons.arrow_downward : Icons.arrow_upward,
                             color: Colors.white,
                            ),
                          ),
                          title: Text(
                           tr.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Text(
                            'R\$${tr.value.toStringAsFixed(2)}',
                            style: TextStyle(
                            color: transacaoColor,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
       bottomNavigationBar: Container(
     margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
    child: NavigationBarTheme(
    data: NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.all(
        IconThemeData(color: Colors.grey),
      ),
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(color: Colors.grey), 
      ),
    ),
    child: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (int index) {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false, 
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Extrato()),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.autorenew_rounded),
          label: 'Transações',
        ),
        NavigationDestination(
          icon: Icon(Icons.attach_money_outlined),
          selectedIcon: Icon(Icons.attach_money),
          label: 'Extrato',
        ),
      ],
    ),
    ),
  ),
    );
  }
}