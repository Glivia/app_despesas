import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_despesas/main.dart';
import 'package:supabase/supabase.dart';

class TransacaoLista extends StatelessWidget {
  final List<Transacao> transacoes;
  final void Function(String) onRemove;
  final void Function(String id, String title, double value, DateTime date, bool entrada) onEdit;
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
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, 
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    leading: CircleAvatar(
                      backgroundColor: tr.entrada
                          ? Color.fromARGB(255, 10, 69, 46)
                          : Color.fromARGB(255, 186, 35, 35),
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: FittedBox(child: Text('R\$${tr.value}',
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
                        IconButton(
                          onPressed: () => onOpenForm(context, transacao: tr),
                          icon: Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 67, 206, 152),
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                            onRemove(tr.id); 
                          },
                            icon: Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 186, 35, 35),
                            )),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
