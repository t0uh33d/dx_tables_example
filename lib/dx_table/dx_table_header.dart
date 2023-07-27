// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_field, unused_element
part of dx_table;

class DxTableHeader {
  final Color backgroundColor;
  final List<DxHeaderElement> titles;
  final EdgeInsets titlePadding;
  final Alignment titleAlignment;
  final BorderRadius borderRadius;
  final double headerHeight;

  DxTableHeader({
    required this.backgroundColor,
    required this.titles,
    this.titleAlignment = Alignment.centerLeft,
    this.titlePadding = const EdgeInsets.only(left: 16),
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(12)),
    this.headerHeight = 50,
  });

  TableRow get _build => TableRow(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
        ),
        children: [
          ...List.generate(titles.length,
              (index) => titles[index]._build(headerHeight, index)),
        ],
      );
}

typedef DxHeaderElementBuilder = Widget Function(
    BuildContext context, DxTableSortState sortState, int index);

typedef DxTableComparator<T> = bool Function(T a, T b);

class DxHeaderElement<T> {
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Alignment? align;
  final DxHeaderElementBuilder builder;
  final double? width;
  final DxTableSortMechanism<T>? sortingMechanism;

  DxHeaderElement({
    this.padding = const EdgeInsets.only(left: 16),
    this.backgroundColor,
    this.align = Alignment.center,
    required this.builder,
    this.width,
    this.sortingMechanism,
  });

  late DxTableController _tc;
  late BuildContext _context;

  void _init(BuildContext context, DxTableController tc) {
    _tc = tc;
    _context = context;
  }

  Widget _build(double h, int index) => Container(
        color: backgroundColor,
        height: h,
        padding: padding,
        alignment: align,
        width: width,
        child: builder.call(_context, _tc._getSortStateForIndex(index), index),
      );

  static DxHeaderElement empty({double width = 200}) =>
      DxHeaderElement(builder: (_, ___, __) => SizedBox(width: width));
}

enum DxTableSortState {
  unsorted,
  sorted,
  reversed,
}

class DxTableSortMechanism<T> {
  /// if this returns true then the elements are sorted in ascending order
  final DxTableComparator<T>? comparator;
  final List<T>? groupOrderSort;
  DxTableSortMechanism({
    this.comparator,
    this.groupOrderSort,
  });

  void sort(int index, DxTableController tc) {
    tc.createSortIdxMap<T>(index);
  }
}
