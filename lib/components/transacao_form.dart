import 'package:app_despesas/transacao.dart';
import 'package:intl/intl.dart';
import 'package:app_despesas/database/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class TransacaoForm extends StatefulWidget {
  final void Function(String, double, DateTime, bool) onSubmit;//define o componente transacaoform como um widget com estado
  final Transacao? transacao;//recebe função como parâmetro
  final void Function(String, String, double, DateTime, bool)? onEdit;//representa uma transação existente para edição

  TransacaoForm(this.onSubmit, {this.transacao, required this.onEdit});//iniciando os parâmetros e deixando o onEdite obrigatório na edição

  @override
  _TransacaoFormState createState() => _TransacaoFormState();
}

class _TransacaoFormState extends State<TransacaoForm> {
  final _tituloController = TextEditingController();//controlador do texto
  final _valorController = TextEditingController();//controlador do valor
  bool _entrada = true;//entrada
  DateTime _selectedData = DateTime.now();//seleciona a data atual se não for selecionada alguma

  @override
  void initState() {
    super.initState();
    if (widget.transacao != null) {//verifica se tem uma transação para edição e preenche os campos com os valores existentes
      _tituloController.text = widget.transacao!.title;
      _valorController.text = widget.transacao!.value.toString();
      _selectedData = widget.transacao!.data;
      _entrada = widget.transacao!.entrada;
    }
  }

  void _submitForm() {//metodo chamado ao enviar formulário
    final titulo = _tituloController.text;//recebe o texto dos controladores 
    final valor = double.tryParse(_valorController.text) ?? 0.0;//recebe dos controladores e converte para double

    if (titulo.isEmpty || valor <= 0) {
      return;//valida que o titulo não está vazio e que o valor é positivo
    }
    if (widget.transacao == null) {
      widget.onSubmit(titulo, valor, _selectedData, _entrada);//chama a função de criar
    } else {
      widget.onEdit ?.call(widget.transacao!.id, titulo, valor, _selectedData, _entrada);//chama a função de editar
      Navigator.of(context).pop();//fecha o formulario ao salvar a alteração
    }
  }

  _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),//seleciona a data atual
      firstDate: DateTime(2023),//pode selecionar apartir de 2023
      lastDate: DateTime.now(),//ultima data a poder selecionar é o dia atual
    ).then((PickedDate) {
      if (PickedDate == null) {
        return;//retorna nulo se nada for salvo, pois o pickedDate não recebe a data 
      }
      setState(() {
        _selectedData = PickedDate;//atualiza a interface com a data selecionada
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(//campos para texto e valor
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
              Container(//checkbox da entrada
              height: 70,
                child: Row(
                children: [
                Row( children: [ Text('Entrada?'),
                        Checkbox( value: _entrada,  onChanged: (bool? value) { setState(() { _entrada = value ?? false;});},),
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
              Row(//botão de salvar 
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
