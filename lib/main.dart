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

main() async {
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

  // CHAMADA DO CHART
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
          id: tr[
              'id'], // Garantir que o campo do Map corresponde ao nome da variável no objeto Transacao
          title: tr['titulo'],
          value: tr['valor'],
          data: DateTime.parse(
              tr['data']), // Converter a string para DateTime, se necessário
          entrada: tr['entrada'],
        );
      }).toList();

      setState(() {
        _Transacoes.clear();
        _Transacoes.addAll(transacoesList);
        _totalValue = _Transacoes.fold(
            0.0, (sum, tr) => sum + (tr.entrada ? tr.value : -tr.value));
      });
    } catch (e) {
      print('Erro ao carregar transações: $e');
    }
  }

  // ADICIONA TRANSACAO
  _AddTransacao(
      String titulo, double valor, DateTime data, bool entrada) async {
    final newTransacao = Transacao(
      id: Random().nextDouble().toString(),
      title: titulo,
      value: valor,
      data: data,
      entrada: entrada,
    );

    try {
      await Database().addTransacao(titulo, valor, data, entrada);
      await _carregarTransacoes();
      // ATRIBUIÇÃO DA NOVA TRANSACAO NO CHART
    } catch (error) {
      print('erro: $error');
    }
    setState(() {
      _Transacoes.add(newTransacao);
      _totalValue += entrada ? valor : -valor;
    });
    Navigator.of(context).pop();
  }

  // EXCLUIR
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

          _Transacoes.removeAt(transacaoIndex);
        }
      });
  }

  // EDITAR
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

          _totalValue -=
              oldTransacao.entrada ? oldTransacao.value : -oldTransacao.value;
          _totalValue +=
              newEntrada ? newValue : -newValue; 

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

  @override
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
