import 'package:app_despesas/transacao.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransacaoLista extends StatelessWidget {
  final List<Transacao> transacoes;

  TransacaoLista(this.transacoes);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      child: transacoes.isEmpty
          ? Column(
              children: <Widget>[
                SizedBox(height: 70),
                Container(
                  height: 150,
                  child: Image.asset(
                    'build/assets/images/search-folder.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Text('Nenhuma Gasto Cadastrado!'),
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
                      backgroundColor: Colors.purple.shade500,
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: FittedBox(
                          child: Text('R\$${tr.value}')),
                      ),
                    ),
                    title: Text(tr.title),
                    subtitle: Text(DateFormat('d MMM y').format(tr.date)),
                  ),
                );
              }),
    );
  }
}
