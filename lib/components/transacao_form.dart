import 'package:app_despesas/transacao.dart';
import 'package:intl/intl.dart';
import 'package:app_despesas/database/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TransacaoForm extends StatefulWidget {
  final void Function(String, double, DateTime, bool) onSubmit;
  final Transacao? transacao;
  final void Function(String, String, double, DateTime, bool)? onEdit;

  TransacaoForm(this.onSubmit, {this.transacao, required this.onEdit});

  @override
  _TransacaoFormState createState() => _TransacaoFormState();
}

class _TransacaoFormState extends State<TransacaoForm> {
  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  bool _entrada = true;
  DateTime _selectedData = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {
      _tituloController.text = widget.transacao!.title;
      _valorController.text = widget.transacao!.value.toString();
      _selectedData = widget.transacao!.data;
      _entrada = widget.transacao!.entrada;
    }
  }

  void _submitForm() {
    final titulo = _tituloController.text;
    final valor = double.tryParse(_valorController.text) ?? 0.0;

    if (titulo.isEmpty || valor <= 0) {
      return;
    }
    if (widget.transacao == null) {
      widget.onSubmit(titulo, valor, _selectedData, _entrada);
    } else {
      widget.onEdit
          ?.call(widget.transacao!.id, titulo, valor, _selectedData, _entrada);
      Navigator.of(context).pop();
    }
  }

  _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    ).then((PickedDate) {
      if (PickedDate == null) {
        return;
      }
      setState(() {
        _selectedData = PickedDate;
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
                onSubmitted: (_) => _submitForm(),
                decoration: InputDecoration(
                  labelText: 'Título',
                ),
              ),
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _submitForm(),
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
                        Text('Entrada?'),
                        Checkbox(
                          value: _entrada,
                          onChanged: (bool? value) {
                            setState(() {
                              _entrada = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 10, 69, 46)),
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
                        foregroundColor: const Color.fromARGB(255, 253, 243, 255),
                        backgroundColor:const Color.fromARGB(255, 10, 69, 46)),
                    child: Text(widget.transacao == null ? 'Nova Transação' : 'Editar Transação'),
                    onPressed: _submitForm,
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
