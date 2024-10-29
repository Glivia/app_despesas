import 'package:app_despesas/components/chart.dart';
import 'components/chart.dart';
import 'components/transacao_form.dart';
import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'components/transacao_lista.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

main() => runApp(AppDespesas());

@override
class AppDespesas extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.purple.shade900,
          secondary: Colors.purple.shade400,
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
    Transacao(
      id: 't1',
      title: 'novo tenis de corrida',
      value: 310.76,
      date: DateTime.now().subtract(Duration(days: 3)),
    ),
    Transacao(
      id: 't2',
      title: 'conta de luz',
      value: 200.70,
      date: DateTime.now().subtract(Duration(days: 2)),
    )
  ];

  List<Transacao> get _recentTransacoes {
    return _Transacoes.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(Duration(days: 7),
      ));
    }).toList();
  }

  _AddTransacao(String titulo, double valor) {
    final newTransacao = Transacao(
      id: Random().nextDouble().toString(),
      title: titulo,
      value: valor,
      date: DateTime.now(),
    );

    setState(() {
      _Transacoes.add(newTransacao);
    });

    Navigator.of(context).pop();
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
          style: GoogleFonts.roboto(
            textStyle: TextStyle(fontSize: 20),
          ),
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
            TransacaoLista(_Transacoes),
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
