import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class TransacaoLista extends StatelessWidget {
  final List<Transacao> transacoes;
  final void Function(String) onRemove;
  final void Function( String id, String title, double value, DateTime date, bool entrada) onEdit;
   final void Function(BuildContext context, {Transacao? transacao}) onOpenForm;

  TransacaoLista(this.transacoes, this.onRemove, this.onEdit, this.onOpenForm);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: transacoes.isEmpty
          ? Column(
              children: <Widget>[
                SizedBox(height: 100),
                Text('Nenhum Gasto Cadastrado!'),
              ],
            )
          : ListView.builder(
              itemCount: transacoes.length,
              itemBuilder: (ctx, index) {
                final tr = transacoes[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tr.entrada
                          ? Color.fromARGB(255, 144, 255, 23)
                          : Colors.red,
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: FittedBox(child: Text('R\$${tr.value}')),
                      ),
                    ),
                    title: Text(tr.title),
                    subtitle: Text(DateFormat('d MMM y').format(tr.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        IconButton(
                          onPressed: () => onOpenForm(context, transacao: tr),
                          icon: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                        IconButton(
                            onPressed: () => onRemove(tr.id),
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red.shade600,
                            )),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
