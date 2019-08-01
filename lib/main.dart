import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?key=ff9b41a0';

main() async {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar, euro, bitcoin, peso;
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final pesoController = TextEditingController();
  final bitController = TextEditingController();
  final corPrincipal = Color.fromRGBO(55, 191, 78, 100);
  final corPrincipalEscura = Color.fromRGBO(37, 128, 52, 50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("\$ Conversor de moedas \$"),
          centerTitle: true,
          backgroundColor: corPrincipal,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refresh,
            )
          ],
        ),
        body: future());
  }

  void refresh() {
    realController.text = "1";
    _realChange("1");
  }

  dynamic future() {
    return FutureBuilder<Map>(
        future: getJson(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // verificar estado da conexão
            case ConnectionState.none:
            case ConnectionState.waiting:
              return msgCarregando();
            default:
              if (snapshot.hasError) {
                return erroDados();
              } else {
                return showDados(snapshot);
              }
          }
        });
  }

  dynamic showDados(snapshot) {
    dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
    bitcoin = snapshot.data["results"]["currencies"]["BTC"]["buy"];
    peso = snapshot.data["results"]["currencies"]["ARS"]["buy"];
    refresh();
    return SingleChildScrollView(
      padding: EdgeInsets.all(10),
      child: LayoutPrincipal(),
    );
  }

  dynamic LayoutPrincipal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(Icons.monetization_on, color: corPrincipal, size: 160),
        Divider(height: 40),
        criarTexts("Reais", "R\$: ", _realChange, controller: realController),
        Divider(),
        criarTexts("Dolares", "US\$: ", _dolarChange,
            controller: dolarController),
        Divider(),
        criarTexts("Euro", "EUR: ", _euroChange, controller: euroController),
        Divider(),
        criarTexts("Peso argentino", "ARS: ", _pesoChange,
            controller: pesoController),
        Divider(),
        criarTexts("BitCoin", "BTC: ", _bitChange, controller: bitController)
      ],
    );
  } // LAYOUT PRINCIPAL

  dynamic criarTexts(label, prefix, funcao, {controller}) {
    return TextField(
      onChanged: funcao,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: corPrincipalEscura),
        border: OutlineInputBorder(),
        prefixText: prefix,
        prefixStyle: TextStyle(color: corPrincipalEscura),
      ),
      style: TextStyle(color: Colors.black),
    );
  }

  void _realChange(String text) {
    final double inputReal = double.parse(text);
    dolarController.text = (inputReal / dolar).toStringAsFixed(2);
    euroController.text = (inputReal / euro).toStringAsFixed(2);
    pesoController.text = (inputReal / peso).toStringAsFixed(2);
    bitController.text = (inputReal / bitcoin).toString();
  }

  void _euroChange(String text) {
    final double inputEuro = double.parse(text);
    realController.text = (inputEuro * euro).toStringAsFixed(2);
    dolarController.text = (inputEuro * euro / dolar).toStringAsFixed(2);
    pesoController.text = (inputEuro * euro / peso).toStringAsFixed(2);
    bitController.text = (inputEuro * euro / bitcoin).toString();
  }

  void _dolarChange(String text) {
    final double inputDolar = double.parse(text);
    realController.text = (inputDolar * dolar).toStringAsFixed(2);
    euroController.text = (inputDolar * dolar / euro).toStringAsFixed(2);
    pesoController.text = (inputDolar * dolar / peso).toStringAsFixed(2);
    bitController.text = (inputDolar * dolar / bitcoin).toString();
  }

  void _bitChange(String text) {
    final double inputBit = double.parse(text);
    realController.text = (inputBit * bitcoin).toStringAsFixed(2);
    dolarController.text = (inputBit * bitcoin / dolar).toStringAsFixed(2);
    pesoController.text = (inputBit * bitcoin / peso).toStringAsFixed(2);
    euroController.text = (inputBit * bitcoin / euro).toStringAsFixed(2);
  }

  void _pesoChange(String text) {
    final double inputPeso = double.parse(text);
    realController.text = (inputPeso * peso).toStringAsFixed(2);
    dolarController.text = (inputPeso * peso / dolar).toStringAsFixed(2);
    euroController.text = (inputPeso * peso / euro).toStringAsFixed(2);
    bitController.text = (inputPeso * peso / bitcoin).toString();
  }

  erroDados() {
    return Center(
      child: Text(
        "Erro ao carregar dados :( ",
        style: TextStyle(color: Colors.pink, fontSize: 25),
        textAlign: TextAlign.center,
      ),
    );
  }

  dynamic msgCarregando() {
    return Center(
        child: Text("Carregando dados...",
            style: TextStyle(color: Colors.pink, fontSize: 25),
            textAlign: TextAlign.center));
  }
} // HOME STATE

Future<Map> getJson() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
