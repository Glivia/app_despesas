import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_despesas/main.dart';
import 'package:supabase/supabase.dart';

class TransacaoLista extends StatelessWidget {
  final List<Transacao> transacoes;//lista de objetos que vão ser exibidos na tela
  final void Function(String) onRemove;//função chamada ao remover uma transação
  final void Function(String id, String title, double value, DateTime date, bool entrada) onEdit;//função chamada para edição
  final void Function(BuildContext context, {Transacao? transacao}) OpenForm;//função chamada para abrir o form

  TransacaoLista(this.transacoes, this.onRemove, this.onEdit, this.OpenForm);//construtor que incia com as funções chamadas

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: transacoes.isEmpty ? Column(
              children: <Widget>[
                SizedBox(height: 100),
                Text('Nenhum Gasto Cadastrado!'),//retorna se a lista tiver vazia
              ],
            ) : ListView.builder(//renderiza os itens dinamicamente
              itemCount: transacoes.length,//define número total de itens exibidos
              itemBuilder: (ctx, index) {//retorna o item
                final tr = transacoes[index];//representa cada transação
                return Card(//personalização do card da transação
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, 
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    leading: CircleAvatar(//campo que apresenta o valor da transação
                      backgroundColor: tr.entrada ? Color.fromARGB(255, 10, 69, 46) : Color.fromARGB(255, 186, 35, 35),
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: FittedBox(child: Text('R\$${tr.value}',//mostrando o valor
                        style: TextStyle(
                          color: tr.entrada ? Colors.white : Color.fromARGB(255, 235, 190, 190),
                        ))),
                      ),
                    ),
                    title: Text(tr.title),
                    subtitle: Text(DateFormat('d MMM y').format(tr.data)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(//botão de editar
                          onPressed: () => OpenForm(context, transacao: tr),//abrindo form de edição
                          icon: Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 67, 206, 152),
                          ),
                        ),
                        IconButton(//botão de remover
                            onPressed: () { onRemove(tr.id); },//deletando o item pelo ID
                            icon: Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 186, 35, 35),
                            ),)
                            ],
                    ),
                  ),
                );
              }),
    );
  }
}
