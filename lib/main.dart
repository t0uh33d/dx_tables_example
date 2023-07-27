import 'dart:math';

import 'package:dx_tables/data/player_data_model.dart';
import 'package:dx_tables/data/table_data.dart';
import 'package:dx_tables/dx_table/dx_table.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final DxTableController dxTableController = DxTableController();
  late List<PlayerDataModel> players;

  @override
  void initState() {
    players = TableData.players;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: DxTable(
            tableWidth: size.width,
            height: size.height,
            animationDuration: const Duration(microseconds: 0),
            header: DxTableHeader(
              titleAlignment: Alignment.centerLeft,
              backgroundColor: Colors.red,
              titles:
                  TableData.headerTitles.map((e) => _headerElement(e)).toList(),
            ),
            rows: TableData.players.map((e) => dxTableRow(e)).toList(),
            dxTableController: dxTableController,
          ),
        ),
      ),
    );
  }

  DxHeaderElement _headerElement(String title) {
    return DxHeaderElement(
      align: Alignment.centerLeft,
      backgroundColor:
          Colors.primaries[Random().nextInt(Colors.primaries.length - 1)],
      builder: (context, sortState, index) {
        return Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        );
      },
    );
  }

  DxTableRow dxTableRow(PlayerDataModel playerDataModel) {
    return DxTableRow(
      backgroundColor: Colors.white,
      hoverColor: Colors.grey,
      children: [
        _rowElement(playerDataModel.id.toString()),
        _rowElement(playerDataModel.name),
        _rowElement(playerDataModel.age.toString()),
        _rowElement(playerDataModel.nationality.toString()),
        _rowElement(playerDataModel.club.toString()),
        _rowElement(playerDataModel.position.toString()),
        _rowElement(playerDataModel.goalsScored.toString()),
        _rowElement(playerDataModel.assists.toString()),
      ],
    );
  }

  DxTableRowElement<dynamic> _rowElement(String value) {
    return DxTableRowElement(
      builder: (context, isSelected, isHovered, hoverValue, rowIndex) {
        return Text(
          value,
          style: TextStyle(
            color: isHovered ? Colors.white : Colors.black,
          ),
        );
      },
    );
  }
}
