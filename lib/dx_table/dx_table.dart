// ignore_for_file: public_member_api_docs, sort_constructors_first
library dx_table;

// import 'package:flutter/material.dart';

import 'dart:math';

import 'package:dx_tables/flutter_table.dart';
import 'package:dx_tables/rendering_tabel.dart';
import 'package:flutter/material.dart'
    hide
        Table,
        TableRow,
        TableCellVerticalAlignment,
        TableColumnWidth,
        IntrinsicColumnWidth;

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

  // void _renderStickyHeader() {
  //   OverlayEntry overlayEntry = OverlayEntry(
  //     builder: (context) {
  //       return Positioned(
  //         top: 0,
  //         child: Row(
  //           children: widget.dxTableController._columnWidths
  //               .map((e) => Container(
  //                     height: widget.dxTableController._rowHeight,
  //                     width: e,
  //                     color: Colors.primaries[
  //                         Random().nextInt(Colors.primaries.length - 1)],
  //                   ))
  //               .toList(),
  //         ),
  //       );
  //     },
  //   );

  //   Overlay.of(context).insert(overlayEntry);
  // }

  @override
  void dispose() {
    widget.dxTableController.dispose();
    super.dispose();
  }

  final ValueNotifier<List<double>?> _columnWidths =
      ValueNotifier<List<double>?>(null);

  void _buildStickyHeader() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _columnWidths.value = widget.dxTableController._columnWidths;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildStickyHeader();
    return Container(
      margin: widget.margin,
      height: widget.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            Container(
              width: widget.tableWidth,
              margin: EdgeInsets.only(top: widget.header.headerHeight),
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
                          ...widget.dxTableController._filteredRows.map(
                            (e) => e._build,
                          ),
                        ],
                        dxTableController: widget.dxTableController,
                      ),
                    );
                  }),
            ),
            ValueListenableBuilder<List<double>?>(
              valueListenable: _columnWidths,
              builder: (context, arr, _) {
                if (arr == null) return const SizedBox();
                return widget.dxTableController._dxTableHeader._buildRow(arr);
              },
            ),
          ],
        ),
      ),
    );
  }
}
