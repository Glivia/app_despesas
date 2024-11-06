import 'package:app_despesas/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'components/chart.dart';
import 'components/transacao_form.dart';
import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'components/transacao_lista.dart';
import 'dart:math';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

main() => runApp(AppDespesas());

class AppDespesas extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],

      home: MyHomePage(),

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 144, 255, 23),
          primary: const Color.fromARGB(255, 0, 193, 108),
          secondary: const Color.fromARGB(255, 144, 255, 23),
          brightness: Brightness.light,
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

  final List<Transacao> _Transacoes = [];

  double _totalValue = 0.0;

  //CHAMADA DO CHART
  List<Transacao> get _recentTransacoes {
    return _Transacoes.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }


  //ADICIONA TRANSACAO
  _AddTransacao(String titulo, double valor, DateTime date, bool entrada) {
    final newTransacao = Transacao(
      id: Random().nextDouble().toString(),
      title: titulo,
      value: valor,
      date: date,
      entrada: entrada,
    );

    //ATRIBUIÇAO DA NOVA TRANSACAO NO CHART
    setState(() {
      _Transacoes.add(newTransacao);
      _totalValue += entrada ? valor : -valor;
    });

    Navigator.of(context).pop();
  }

  //EXCLUIR
  _deleteTransacao(String id) {
    setState(() {
       final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id);
        final deleteTransacao = _Transacoes[transacaoIndex];

        _totalValue -= deleteTransacao.entrada ? deleteTransacao.value : -deleteTransacao.value;
       _Transacoes.removeAt(transacaoIndex);

        _Transacoes.removeWhere((tr) {
        return tr.id == id;
      });
    });
  }

  //EDITAR
  _editTransacao(String id, String newTitle, double newValue, DateTime newDate,
      bool newEntrada) {
    final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id);
    if (transacaoIndex >= 0) {
      setState(() {
        final oldTransacao = _Transacoes[transacaoIndex];

        _totalValue -=
            oldTransacao.entrada ? oldTransacao.value : -oldTransacao.value;
        _totalValue += newEntrada ? newValue : -newValue; //ALTERAR VALOR DO TOTALVALUE

        _Transacoes[transacaoIndex] = Transacao(
          id: id,
          title: newTitle,
          value: newValue,
          date: newDate,
          entrada: newEntrada,
        );//ATUALIZAR TRANSACAO
      });
    }
  }

  //CHAMADA DO FORM
  _openTransacaoFormModal(BuildContext context, {Transacao? transacao}) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return TransacaoForm(_AddTransacao,
              transacao: transacao, onEdit: _editTransacao);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Altera a cor das barras do ícone
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Despesas pessoais',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.all(0),
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Transações'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money_rounded),
              title: Text('Extrato'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Chart(_recentTransacoes),
            Center(
              child: Text(
                'R\$${_totalValue.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _totalValue >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ),
            TransacaoLista(_Transacoes, _deleteTransacao, _editTransacao,
                _openTransacaoFormModal),
          ],
        ),
      ),

        //BOTAO DE ADICIONAR
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: CircleBorder(),
          onPressed: () => _openTransacaoFormModal(context)),
    );
  }
}
