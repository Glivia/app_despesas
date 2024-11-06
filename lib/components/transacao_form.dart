import 'package:app_despesas/transacao.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TransacaoForm extends StatefulWidget {
  final void Function(String, double, DateTime, bool) onSubmit;
  final Transacao? transacao;
  final void Function(String, String, double, DateTime, bool)? onEdit;

  TransacaoForm(this.onSubmit, {this.transacao, this.onEdit});

  @override
  State<TransacaoForm> createState() => _TransacaoFormState();
}

class _TransacaoFormState extends State<TransacaoForm> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  bool _entrada = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      _tituloController.text = widget.transacao!.title;
      _valorController.text = widget.transacao!.value.toString();
      _selectedDate = widget.transacao!.date;
      _entrada = widget.transacao!.entrada;
    }
  }

  _subimitForm() {
    final titulo = _tituloController.text;
    final valor = double.tryParse(_valorController.text) ?? 0.0;

    if (titulo.isEmpty || valor <= 0) {
      return;
    } if (widget.transacao == null) {
 
    widget.onSubmit(titulo, valor, _selectedDate, _entrada);
  } else {
    // Se houver uma transação existente, edita-a
    widget.onEdit?.call(
      widget.transacao!.id, // ID da transação a ser editada
      titulo, 
      valor, 
      _selectedDate, 
      _entrada
    );
     Navigator.of(context).pop();
  }
 
 
  }

  _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      // locale: const Locale('pt', 'BR'),
    ).then((PickedDate) {
      if (PickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = PickedDate;
      });
    });
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
                controller: _tituloController,
                onSubmitted: (_) => _subimitForm(),
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: _valorController,
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
                    Row(
                      children: [
                        Text('Entrada?'), // Rótulo para o checkbox
                        Checkbox(
                          value: _entrada,
                          onChanged: (bool? value) {
                            setState(() {
                              _entrada = value ??
                                  false; // Atualiza o estado do checkbox
                            });
                          },
                        ),
                      ],
                    ),
                    // Expanded(
                    //   child: Text(_selectedDate == null ? 'Nenhuma data selecionada' : DateFormat('dd/MM/y').format(_selectedDate)),
                    // ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 144, 255, 23),
                      ),
                      child: Text('Selecionar Data'),
                      onPressed: () => _showDatePicker(context),
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
                        backgroundColor: Color.fromARGB(255, 144, 255, 23)),
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
