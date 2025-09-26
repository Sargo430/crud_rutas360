import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class TablaRutas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rutas")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("rutas").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [1, 2, 3]; //snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // para que la tabla no se corte
            child: DataTable(
              dataRowMinHeight: 40, // Set minimum height for data rows
              dataRowMaxHeight: 70,
              columns: const [
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("Categorías")),
                DataColumn(label: Text("Descripción")),
              ],
              rows: docs.map((doc) {
                final List categorias = ["Naturaleza", "Trekking"];
                final String descripcion =
                    "Una ruta maravillosa que te llevará a través de paisajes impresionantes y";

                return DataRow(
                  cells: [
                    DataCell(Text("ruta")),
                    DataCell(
                      SizedBox(
                        width: 200, // 🔥 Controlar el ancho
                        child: Wrap(
                          // 🔥 Muestra lista de longitud variable
                          spacing: 6,
                          children: categorias
                              .map((c) => Text(c.toString()))
                              .toList(),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 300, // 🔥 Controlar el ancho
                        child: Text(
                          descripcion,
                          maxLines: 3, // 🔥 Evita que ocupe toda la pantalla
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}