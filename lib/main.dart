import 'package:app_despesas/database/supabase.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'components/chart.dart';
import 'components/transacao_form.dart';
import 'package:flutter/material.dart';
import 'components/transacao_lista.dart';
import 'dart:math';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'transacao.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'extrato.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vpknkuadfqjdmkcqafxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwa25rdWFkZnFqZG1rY3FhZnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNzAyMTksImV4cCI6MjA0Njk0NjIxOX0.OsJrJTxsJQxCAgYDNRg9ase5oIRxXTeTNNEbpTfKoLA',
  );

  runApp(AppDespesas());
}

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
        scaffoldBackgroundColor: const Color.fromARGB(255, 225, 225, 225),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 69, 46),
          primary: const Color.fromARGB(255, 24, 172, 115),
          secondary: const Color.fromARGB(255, 10, 69, 46),
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
  double _totalEntradas = 0.0;
  double _totalSaidas = 0.0;

  List<Transacao> get _recentTransacoes {
    return _Transacoes.where((tr) {
      return tr.data.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

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
          value: (tr['valor'] as num).toDouble(),
          data: DateTime.parse(tr['data']),
          entrada: tr['entrada'],
        );
      }).toList();

      setState(() {
        _Transacoes.clear();
        _Transacoes.addAll(transacoesList);
        _totalValue = _Transacoes.fold(0.0, (sum, tr) => sum + (tr.entrada ? tr.value : -tr.value));
        _totalEntradas = _Transacoes.where((tr) => tr.entrada).fold(0.0, (sum, tr) => sum + tr.value);
        _totalSaidas = _Transacoes.where((tr) => !tr.entrada).fold(0.0, (sum, tr) => sum + tr.value);
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  _AddTransacao(String titulo, double valor, DateTime data, bool entrada) async {
    final newTransacao = Transacao(
      id: Random().nextDouble().toString(),
      title: titulo,
      value: valor,
      data: data,
      entrada: entrada,
    );

    try {
      setState(() {
        _Transacoes.add(newTransacao);
        _totalValue += entrada ? valor : -valor;
        if (entrada) {
          _totalEntradas += valor;
        } else {
          _totalSaidas += valor;
        }
      });
      await Database().addTransacao(titulo, valor, data, entrada);
      await _carregarTransacoes();
    } catch (error) {
      print('erro: $error');
    }

    Navigator.of(context).pop();
  }

  _deleteTransacao(String id) async {
    try {
      await Database().deleteTransacao(id);
    } catch (e) {
      print("Erro ao deletar transação: $e");
    }
    setState(() {
      final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id);
      if (transacaoIndex >= 0) {
        final deleteTransacao = _Transacoes[transacaoIndex];

        _totalValue -= deleteTransacao.entrada
            ? deleteTransacao.value
            : -deleteTransacao.value;

        if (deleteTransacao.entrada) {
          _totalEntradas -= deleteTransacao.value;
        } else {
          _totalSaidas -= deleteTransacao.value;
        }

        _Transacoes.removeAt(transacaoIndex);
      }
    });
  }

  _editTransacao(String id, String newTitle, double newValue, DateTime newDate,
      bool newEntrada) async {
    final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id);
    if (transacaoIndex >= 0) {
      try {
        await Database()
            .updateTransacao(id, newTitle, newValue, newDate, newEntrada);
      } catch (e) {
        print("erro:$e");
      }
      setState(() {
        final oldTransacao = _Transacoes[transacaoIndex];

        _totalValue -= oldTransacao.entrada ? oldTransacao.value : -oldTransacao.value;
        _totalValue += newEntrada ? newValue : -newValue;

        if (oldTransacao.entrada) {
          _totalEntradas -= oldTransacao.value;
        } else {
          _totalSaidas -= oldTransacao.value;
        }

        if (newEntrada) {
          _totalEntradas += newValue;
        } else {
          _totalSaidas += newValue;
        }

        _Transacoes[transacaoIndex] = Transacao(
          id: id,
          title: newTitle,
          value: newValue,
          data: newDate,
          entrada: newEntrada,
        );
      });
    }
  }

  _openTransacaoFormModal(BuildContext context, {Transacao? transacao}) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return TransacaoForm(_AddTransacao,
              transacao: transacao, onEdit: _editTransacao);
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Despesas pessoais',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
                selectedIcon: Icon(Icons.attach_money, color: Colors.green,),
                label: 'Extrato',
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:[
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 24, 172, 115),
              height: 150,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Saldo Atual',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'R\$${_totalValue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 24, 172, 115),
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
                            color:  Color.fromARGB(255, 10, 69, 46),
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Entradas',
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$${_totalEntradas.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 10, 69, 46),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                      children: [
                          Icon( Icons.arrow_upward, color: Color.fromARGB(255, 186, 35, 35),size: 18,),
                          SizedBox(width: 4),
                          Text('Saídas',
                            style: TextStyle(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$${_totalSaidas.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 186, 35, 35),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Chart(_recentTransacoes),
            TransacaoLista(
              _Transacoes,
              _deleteTransacao,
              _editTransacao,
              _openTransacaoFormModal,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: CircleBorder(),
          onPressed: () => _openTransacaoFormModal(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
