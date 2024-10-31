import 'components/chart.dart';
import 'components/transacao_form.dart';
import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'components/transacao_lista.dart';
import 'dart:math';

main() => runApp(AppDespesas());

class AppDespesas extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 156, 50, 255),
          primary: const Color.fromARGB(255, 156, 50, 255),
          secondary: const Color.fromARGB(255, 119, 30, 235),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transacao> _Transacoes = [
  ];

  List<Transacao> get _recentTransacoes {
    return _Transacoes.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  _AddTransacao(String titulo, double valor, DateTime date) {
    final newTransacao = Transacao(
      id: Random().nextDouble().toString(),
      title: titulo,
      value: valor,
      date: date,
    );

    setState(() {
      _Transacoes.add(newTransacao);
    });

    Navigator.of(context).pop();
  }

  _deleteTransacao(String id) {
    setState(() {
      _Transacoes.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  _openTransacaoFormModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return TransacaoForm(_AddTransacao);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Despesas pessoais',
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _openTransacaoFormModal(context))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Chart(_recentTransacoes),
            TransacaoLista(_Transacoes, _deleteTransacao),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () => _openTransacaoFormModal(context)),
    );
  }
}
