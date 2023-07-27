// ignore_for_file: public_member_api_docs, sort_constructors_first
library dx_table;

// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

part 'dx_table_controller.dart';
part 'dx_table_header.dart';
part 'dx_table_row.dart';
part 'dx_table_row_element.dart';
part 'sorting_logic.ext.dart';
part 'filtering_logic.ext.dart';

typedef DxTableState = _DxTableState;
typedef DxRowClickCallback = void Function(int index);

class DxTable extends StatefulWidget {
  final double tableWidth;
  final Duration animationDuration;
  final EdgeInsets? margin;
  final DxTableHeader header;
  final List<DxTableRow> rows;
  final DxTableController dxTableController;
  final DxRowClickCallback? onClick;
  final bool enableFilter;
  final bool enableSort;
  final double? height;
  final TableColumnWidth tableColumnWidth;
  final Map<int, TableColumnWidth>? columnWidthMap;

  const DxTable({
    super.key,
    required this.tableWidth,
    required this.animationDuration,
    required this.header,
    required this.rows,
    required this.dxTableController,
    this.margin,
    this.onClick,
    this.enableFilter = false,
    this.enableSort = false,
    this.height,
    this.tableColumnWidth = const IntrinsicColumnWidth(flex: null),
    this.columnWidthMap,
  });

  @override
  State<DxTable> createState() => _DxTableState();
}

class _DxTableState extends State<DxTable> with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    widget.dxTableController._enableHover();

    widget.dxTableController
        ._init(animationController, widget.onClick, _refresh);

    widget.dxTableController._buildHeader(
      dxTableHeader: widget.header,
      context: context,
    );

    widget.dxTableController._buildRowMap(
      rows: widget.rows,
      context: context,
      shouldFilter: widget.enableFilter,
    );

    super.initState();
  }

  void _refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.dxTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: widget.margin,
          height: widget.height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: widget.tableWidth,
              child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, _) {
                    return SingleChildScrollView(
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        defaultColumnWidth: widget.tableColumnWidth,
                        columnWidths: widget.columnWidthMap,
                        children: [
                          widget.dxTableController._dxTableHeader._build,
                          ...widget.dxTableController._filteredRows.map(
                            (e) => e._build,
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
