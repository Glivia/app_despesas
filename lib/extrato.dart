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
  final List<Transacao> _transacoes = [];//lista para armazenar as transações cadastradas

  double _totalEntradas = 0.0;//inicia valor zerado
  double _totalSaidas = 0.0;//inicia valor zerado

  @override
  void initState() {
    super.initState();
    _carregarTransacoes();//carrega as transações na página
  }

  _carregarTransacoes() async {
    try {
      final transacoes = await Database().getTransacoes();//busca as transações no banco pelo get

      List<Transacao> transacoesList = transacoes.map((tr) {
        return Transacao(
          id: tr['id'],
          title: tr['titulo'],
          value: (tr['valor'] as num).toDouble(),
          data: DateTime.parse(tr['data']),
          entrada: tr['entrada'],
        );
      }).toList();//converte em lista

      double entradas = 0.0;//inicia entradas
      double saidas = 0.0;//inicia saidas
      for (var tr in transacoesList) {//Itera as transações da lista para calcular o valor de entrada e saida
        if (tr.entrada) {
          entradas += tr.value;//se for entrada soma aqui
        } else {
          saidas += tr.value;//se for saida soma aqui
        }
      }

      setState(() {//atualiza os dados da interface
        _transacoes.clear();//limpa a interface
        _transacoes.addAll(transacoesList);//adiciona todas novamente
        _totalEntradas = entradas;//atualiza valor das entradas
        _totalSaidas = saidas;//atualiza valor das saidas
      });
    } catch (erro) {
      print('Erro ao carregar transações: $erro');//print erro
    }
  }

  @override
  Widget build(BuildContext context) {//construindo a interface
    final transacoesAgrupadas = <String, List<Transacao>>{};//cria uma lista agrupando por datas
    for (var tr in _transacoes) {
      final dateKey = DateFormat('dd/MM/yyyy').format(tr.data);//formata a data como chave para agrupar
      if (!transacoesAgrupadas.containsKey(dateKey)) {//verifica se a chave esta na lista
        transacoesAgrupadas[dateKey] = [];//cria uma nova
      }
      transacoesAgrupadas[dateKey]!.add(tr);//senão adiciona em uma existente
    }

    final datasOrdenadas = transacoesAgrupadas.keys.toList()..sort((a, b) {//ordena por ordem decrecente
      final dateA = DateFormat('dd/MM/yyyy').parse(a);//converte para data
      final dateB = DateFormat('dd/MM/yyyy').parse(b);
      return dateB.compareTo(dateA); //compara as datas para gerar a ordem
    });

    return Scaffold(
      appBar: AppBar(//iniciando appbar
        automaticallyImplyLeading: false,//retira o botão de retorno automático
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
                      Color transacaoColor = tr.entrada ? Color.fromARGB(255, 10, 69, 46) : Color.fromARGB(255, 186, 35, 35);
                   return Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                            color: Colors.transparent,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: transacaoColor,
                                child: Icon( tr.entrada ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text( tr.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Text( 'R\$${tr.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: transacaoColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15, 
                                ),
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey[400], thickness: 1), 
                        ],
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
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
              if (index == 0) {//index da página principal
                Navigator.pushAndRemoveUntil( context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                  (route) => false,//retira o retorno automático
                );
              } else if (index == 1) {//index página do extrato
                Navigator.push( context,
                MaterialPageRoute(builder: (context) => Extrato()),
                );}
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
