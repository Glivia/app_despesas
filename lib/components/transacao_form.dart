import 'package:flutter/material.dart';

class TransacaoForm extends StatelessWidget {
  final tituloController = TextEditingController();
  final valorController = TextEditingController();

  final void Function(String, double) onSubmit;

  TransacaoForm(this.onSubmit);

  _subimitForm() {
    final titulo = tituloController.text;
    final valor = double.tryParse(valorController.text) ?? 0.0;

    if (titulo.isEmpty || valor <= 0) {
      return;
    }

    onSubmit(titulo, valor);
  }

  _showDatePicker() {
    showDatePicker(
        context: context,//erro
        initialDate: DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime.now(),
        // locale: const Locale('pt', 'BR'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          child: Column(
            children: <Widget>[
              TextField(
                controller: tituloController,
                onSubmitted: (_) => _subimitForm(),
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _subimitForm(),
                decoration: InputDecoration(
                  labelText: 'Valor (R\$)',
                ),
              ),
              Container(
                height: 70,
                child: Row(
                  children: [
                    Text('Nenhuma data selecionada.'),
                    TextButton(
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.purple.shade400),
                      child: Text('Selecionar Data'),
                      onPressed:  _showDatePicker,
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 253, 243, 255),
                        backgroundColor: Colors.purple.shade400),
                    child: Text('Nova Transação'),
                    onPressed: _subimitForm,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
