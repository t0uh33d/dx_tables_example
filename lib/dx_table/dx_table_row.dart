part of dx_table;

class DxTableRow {
  String? groupID;
  final String? id;
  final Color backgroundColor;
  final Color hoverColor;
  final List<DxTableRowElement> children;
  final Color? selectedColor;
  final bool enableSelection;
  final bool enableSideBorder;
  final BorderSide activeBorderSide;
  final BorderSide inActiveBorderSide;

  late DxTableController _tc;
  late int _index;
  late BuildContext _context;

  void _init(BuildContext context, DxTableController tc, int idx) {
    _tc = tc;
    _index = idx;
    _context = context;
  }

  DxTableRow({
    required this.backgroundColor,
    required this.hoverColor,
    required this.children,
    this.id,
    this.groupID,
    this.selectedColor,
    this.activeBorderSide = const BorderSide(
      width: 1,
      color: Color(0xffECF0FE),
    ),
    this.inActiveBorderSide = const BorderSide(
      width: 1,
      color: Color(0xfff4f5f6),
    ),
    this.enableSideBorder = false,
    this.enableSelection = false,
  });

  List<Widget> elementsCache = [];

  TableRow get _build {
    _generateElementCache();
    return _renderRow();
  }

  void _generateElementCache({bool regenerate = false}) {
    if (!regenerate) elementsCache.clear();
    for (int idx = 0; idx < children.length; idx++) {
      DxTableRowElement ele = children[idx];
      if (!regenerate) ele._init(_context, _tc, _index);
      elementsCache.add(ele._build);
    }
  }

  TableRow _renderRow() {
    return TableRow(
      decoration: BoxDecoration(
        color: enableSelection && _tc._selectedIndex == _index
            ? selectedColor
            : getRowColor,
        border: _tc._border(
            _index, activeBorderSide, inActiveBorderSide, enableSideBorder),
      ),
      children: elementsCache,
    );
  }

  Color get getRowColor {
    double currValue = _tc._getValue(_index);

    if (currValue > 0) {
      return hoverColor.withOpacity(currValue);
    }

    return backgroundColor;
  }
}
