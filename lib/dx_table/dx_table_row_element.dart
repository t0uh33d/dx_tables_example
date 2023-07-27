part of dx_table;

typedef DxTableRowElementBuilder = Widget Function(
  BuildContext context,
  bool isSelected,
  bool isHovered,
  double hoverValue,
  int rowIndex,
);

class DxTableRowElement<T> {
  final T? sortElement;
  final EdgeInsets padding;
  final double height;
  final Alignment alignment;
  final BoxDecoration? decoration;
  final DxTableRowElementBuilder builder;
  final double? width;

  late DxTableController _tc;
  late int _index;
  late BuildContext _context;

  void _init(BuildContext context, DxTableController tc, int idx) {
    _tc = tc;
    _index = idx;
    _context = context;
  }

  DxTableRowElement({
    required this.builder,
    this.padding = const EdgeInsets.only(left: 16),
    this.alignment = Alignment.centerLeft,
    this.height = 50,
    this.decoration,
    this.width,
    this.sortElement,
  });

  Widget get _build {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => _tc._startedRowHover(_index),
      onExit: (event) => _tc._stoppedRowHover(),
      child: InkWell(
        onTap: () => _tc._dxRowClickCallback?.call(_index),
        child: Container(
          height: height,
          // color: CommonMethods.randomColor(),
          width: width,
          decoration: decoration,
          alignment: alignment,
          padding: padding,
          child: builder.call(
            _context,
            _index == _tc._selectedIndex,
            _index == _tc._activeHoverIndex,
            _tc._getValue(_index),
            _index,
          ),
        ),
      ),
    );
  }
}
