import 'package:flutter/material.dart';

class ListServiceOrder extends StatefulWidget {
  const ListServiceOrder({super.key});

  @override
  State<ListServiceOrder> createState() => _ListServiceOrderState();
}

class _ListServiceOrderState extends State<ListServiceOrder> {
  bool inSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: inSearch
            ? const TextField(
                decoration: InputDecoration(
                  hintText: "Pesquisar",
                  fillColor: Colors.white,
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            : const Text("Ordem de Serviço"),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                inSearch = !inSearch;
              });
            },
            icon: Icon(inSearch ? Icons.close : Icons.search),
          )
        ],
      ),
    );
  }
}
