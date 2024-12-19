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

  //Inicio do banco de dados
  await Supabase.initialize(
    url: 'https://vpknkuadfqjdmkcqafxz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZwa25rdWFkZnFqZG1rY3FhZnh6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzEzNzAyMTksImV4cCI6MjA0Njk0NjIxOX0.OsJrJTxsJQxCAgYDNRg9ase5oIRxXTeTNNEbpTfKoLA',
  );

 //Inicializando o App
  runApp(AppDespesas());
}

class AppDespesas extends StatelessWidget {//classe padrões do app
  Widget build(BuildContext context) {
    return MaterialApp( 

      //tradução do app pra pt-br
      localizationsDelegates: [ 
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],

    //inicia a pagina principal
      home: MyHomePage(),
    //theme do app(caracteristicas principais)
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 225, 225, 225),//background
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 10, 69, 46), //cor base
          primary: const Color.fromARGB(255, 24, 172, 115),//cor principal
          secondary: const Color.fromARGB(255, 10, 69, 46),//cor secundaria
          brightness: Brightness.light,//tema claro
        ),
      ),
    );
  }
}

//classe da tela principal
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();//inicializando pagina principal ao abrir o app
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transacao> _Transacoes = [];//iniciando lista de transações vazio

  double _totalValue = 0.0;//iniciando saldo zerado
  double _totalEntradas = 0.0;//iniciando valor entradas zerado
  double _totalSaidas = 0.0;//iniciando valor saidas zerao

  List<Transacao> get _recentTransacoes { //filtro transações do chart
    return _Transacoes.where((tr) { //retorna o valor da transação quando 
    return tr.data.isAfter(DateTime.now().subtract( Duration(days: 7), ));//filtro dos 7 dias (datas entre a data atual - 7 dias = true)
    }).toList();//gera lista com esses valores
  }

  @override//indicador de substituição
  void initState() {//declarando metodo que vai ser executado ao iniciar app
    super.initState();//carrega informações padrões
    _carregarTransacoes();//carrega as transações 
  }

  _carregarTransacoes() async {//iniciando função de carregar transações
    try {
      final transacoes = await Database().getTransacoes();//varivável que armazena lista mapeada retornada pelo get do banco

      List<Transacao> transacoesList = transacoes.map((tr) {//converte a lista de mapa para objeto
        return Transacao(//retorna todos os itens do mapa para objetos
          id: tr['id'],
          title: tr['titulo'],
          value: (tr['valor'] as num).toDouble(),
          data: DateTime.parse(tr['data']),
          entrada: tr['entrada'],
        );
      }).toList();//converte em uma nova lista

      setState(() {//atualizando com os novos dados
        _Transacoes.clear();//limpa tudo
        _Transacoes.addAll(transacoesList);//adiciona todas as transações convertidas em lista no transacoesList
        _totalValue = _Transacoes.fold(0.0, (sum, tr) => sum + (tr.entrada ? tr.value : -tr.value));//atualiza o saldo
        _totalEntradas = _Transacoes.where((tr) => tr.entrada).fold(0.0, (sum, tr) => sum + tr.value);//atualiza valor das entradas
        _totalSaidas = _Transacoes.where((tr) => !tr.entrada).fold(0.0, (sum, tr) => sum + tr.value);//atualiza valor das saidas
      });
    } catch (erro) {//se der erro
      print('Erro ao carregar transações: $erro');
    }
  }

  _AddTransacao(String titulo, double valor, DateTime data, bool entrada) async {//inicio da função de adiçao com os parametros recebidos
    final newTransacao = Transacao(//nova transacao
      id: Random().nextDouble().toString(),//gera ID
      title: titulo,
      value: valor,
      data: data,
      entrada: entrada,
    );

    try {
      setState(() {
        _Transacoes.add(newTransacao);//adiciona nova transação na tela
        _totalValue += entrada ? valor : -valor;//atualiza valor total dependendo da entrada
        if (entrada) {
          _totalEntradas += valor;//se entrada for true, soma nas entradas
        } else {
          _totalSaidas += valor;//senao, vai ser nas saidas
        }
      });
      await Database().addTransacao(titulo, valor, data, entrada);//envia novos dados para o banco
      await _carregarTransacoes();//envia para o carregarTransacoes
    } catch (erro) {
      print('erro: $erro');
    }

    Navigator.of(context).pop();//fecha o formulário
  }

  _deleteTransacao(String id) async {//função de deletar que recebe o ID do que vai ser deletado
    try {
      await Database().deleteTransacao(id);//chama o método deleteTransacao 
        setState(() {
      final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id);//procura na lista o id solicitado
      if (transacaoIndex >= 0) {//verifica se o id encontrado é válido
        final deleteTransacao = _Transacoes[transacaoIndex]; //armazena id que foi encontrado na variável

        _totalValue -= deleteTransacao.entrada ? deleteTransacao.value : -deleteTransacao.value;
        //se for entrada, subtrai, se for saida, soma

        if (deleteTransacao.entrada) {//atualiza valor das entradas e saidas
          _totalEntradas -= deleteTransacao.value; //subtrai se for entrada
        } else {
          _totalSaidas -= deleteTransacao.value; //subtrai se for saida
        }

        _Transacoes.removeAt(transacaoIndex);//remove da lista Transacoes
      }
    });
    } catch (erro) {
      print("Erro ao deletar transação: $erro");//print erro
    }
  
  }

  _editTransacao(String id, String newTitle, double newValue, DateTime newDate, bool newEntrada) async {//chamando função e os parametros que recebe
    final transacaoIndex = _Transacoes.indexWhere((tr) => tr.id == id); //procura pelo ID
    if (transacaoIndex >= 0) { //verifica se é valido
      try {
        await Database().updateTransacao(id, newTitle, newValue, newDate, newEntrada);//atualizando os dados no banco

         setState(() {
        final oldTransacao = _Transacoes[transacaoIndex];//armazena os dados antes de atualizar

        _totalValue -= oldTransacao.entrada ? oldTransacao.value : -oldTransacao.value; //altera valor da entrada
        _totalValue += newEntrada ? newValue : -newValue;

        if (oldTransacao.entrada) {
          _totalEntradas -= oldTransacao.value;//se a antiga for entrada, subtrai de entrada
        } else {
          _totalSaidas -= oldTransacao.value;//se for saida, subtrai de saida
        }

        if (newEntrada) {
          _totalEntradas += newValue;//soma se for nova entrada
        } else {
          _totalSaidas += newValue;//soma se for nova saida
        }

        _Transacoes[transacaoIndex] = Transacao( //substituindo a antiga pela nova
          id: id,//mantem o mesmo ID, só altera os valores
          title: newTitle,
          value: newValue,
          data: newDate,
          entrada: newEntrada,
        );

      });
      } catch (erro) {
        print("erro:$erro");//print erro
      } }
  }

  _openTransacaoFormModal(BuildContext context, {Transacao? transacao}) {
    showModalBottomSheet(//abre o form
        context: context,//passa o contexto para o modal ser aberto sobre a tela
        builder: (ctx) {//ctx é resumo do context
          return TransacaoForm(_AddTransacao, transacao: transacao, onEdit: _editTransacao);});//renderiza o widget do form para adicionar ou editar
  }

  Widget build(BuildContext context) {//gerando interface usando o build
    return Scaffold(//estrutura básica da interface
      appBar: AppBar(//inicio da barra
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,//cor de fundo
        title: Text(//titulo
          'Despesas pessoais',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,//centralizando texto
      ),
      bottomNavigationBar: Container(//container da barra de navegação
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),//definição da margem
        child: NavigationBarTheme(//personalização da barra
          data: NavigationBarThemeData(//icones da barra
            indicatorColor: Colors.transparent,
            iconTheme: WidgetStateProperty.all(
              IconThemeData(color: Colors.grey),
            ),
            labelTextStyle: WidgetStateProperty.all(
              TextStyle(color: Colors.grey),
            ),
          ),
          child: NavigationBar(//funcionalidades barra de navegação
            selectedIndex: 0,//nenhuma página selecionada
            onDestinationSelected: (int index) {
              if (index == 0) {//selecionando pagina principal
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                  (route) => false,
                );
              } else if (index == 1) {//selecionando pagina extrato
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
            Container(//container do saldo
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
            Container(//container entradas e saidas
              color: const Color.fromARGB(255, 24, 172, 115),
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(//coluna das entradas
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
                  Column(//coluna das saidas
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
            Chart(_recentTransacoes),//chamando o chart
            TransacaoLista(
              _Transacoes,
              _deleteTransacao,
              _editTransacao,
              _openTransacaoFormModal,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(//botão de adicionar nova transação
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: CircleBorder(),
          onPressed: () => _openTransacaoFormModal(context)),//chamando função de adicionar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,//centralizando o botão
    );
  }
}
