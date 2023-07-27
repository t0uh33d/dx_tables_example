part of dx_table;

class DxTableController {
  /// for hovering and slecetion logic
  int _activeHoverIndex = -1;
  int _prevHoverIndex = -1;
  bool _isHovering = false;
  int _selectedIndex = -1;
  bool _forceStoppedHover = false;

  // for filtering
  final Map<String, int> _idToIdxMap = {};
  final List<DxTableRow> _rows = [];
  List<DxTableRow> _filteredRows = [];
  final Map<String, Set<String>?> _filterMap = {};

  // for clicks, state updates and animations
  late AnimationController _animationController;
  late DxRowClickCallback? _dxRowClickCallback;
  late void Function()? _onSelectStateUpdator;

  // table computation data
  late List<double> _columnWidths;
  late double _rowHeight;

  void _init(
    AnimationController animationController,
    DxRowClickCallback? dxRowClickCallback,
    void Function()? onSelectStateUpdator,
  ) {
    _animationController = animationController;
    _dxRowClickCallback = dxRowClickCallback;
    _onSelectStateUpdator = onSelectStateUpdator;
  }

  void setTableComputationData({
    required List<double> columnWidths,
    required double rowHeight,
  }) {
    _columnWidths = columnWidths;
    _rowHeight = rowHeight;
  }

  bool _built = false;

  // for sorting
  late DxTableHeader _dxTableHeader;
  int _currentSortIndex = -1;
  bool _isReversed = false;
  final Map<int, List<int>?> _sortedIdxMap = {};

  void _buildHeader({
    required DxTableHeader dxTableHeader,
    required BuildContext context,
  }) {
    for (int idx = 0; idx < dxTableHeader.titles.length; idx++) {
      dxTableHeader.titles[idx]._init(context, this);
      if (dxTableHeader.titles[idx].sortingMechanism != null) {
        _sortedIdxMap[idx] = null;
      }
    }
    _dxTableHeader = dxTableHeader;
  }

  /// runs [_build] on each [DxTableRow] and assings all the rows to [_filteredRows]
  ///
  void _buildRowMap({
    required List<DxTableRow> rows,
    required BuildContext context,
    required bool shouldFilter,
  }) {
    if (_built && rows.length == _rows.length) return;
    _rows.clear();
    for (int idx = 0; idx < rows.length; idx++) {
      rows[idx]._init(context, this, idx);
      rows[idx]._build;
      _rows.add(rows[idx]);
      if (shouldFilter) _createFilterAtIdx(idx);
    }
    _filteredRows = _rows;
    _built = true;
  }

  void sort(int index) {
    _dxTableHeader.titles[index].sortingMechanism?.sort(index, this);
    List<DxTableRow> tmp = [];
    if (_currentSortIndex == index) {
      List<int> idxArr = _isReversed
          ? _sortedIdxMap[index]!
          : _sortedIdxMap[index]!.reversed.toList();
      _sortRows(idxArr, tmp);
      _isReversed = !_isReversed;
      return;
    }

    _sortRows(_sortedIdxMap[index]!, tmp);
    _isReversed = false;
    _currentSortIndex = index;
  }

  void clearSort() {
    _filteredRows = _rows;
    _currentSortIndex = -1;
    _isReversed = false;
    refresh();
  }

  /// filter the table rows data based on the given [tag]
  ///
  void filter(String tag) {
    Set<String>? ids = _filterMap[tag];

    if (ids != null && ids.isNotEmpty) {
      List<DxTableRow> tmp = [];
      for (int i = 0; i < ids.length; i++) {
        tmp.add(_rows[_idToIdxMap[ids.elementAt(i)]!]);
      }
      _filteredRows = tmp;
    } else {
      _filteredRows = [];
    }

    refresh();
  }

  /// clear the applied filter
  ///
  void clearFilter() {
    _filteredRows = _rows;
    refresh();
  }

  Border _border(
    int index,
    BorderSide activeBorderSide,
    BorderSide inActiveBorderSide,
    bool enableSideBorder,
  ) {
    if (index == _activeHoverIndex || index == _activeHoverIndex - 1) {
      return Border(
        bottom: activeBorderSide,
        top: index == 0 ? activeBorderSide : BorderSide.none,
        left: enableSideBorder ? activeBorderSide : BorderSide.none,
        right: enableSideBorder ? activeBorderSide : BorderSide.none,
      );
    }

    return Border(
      bottom: inActiveBorderSide,
      left: enableSideBorder ? inActiveBorderSide : BorderSide.none,
      right: enableSideBorder ? inActiveBorderSide : BorderSide.none,
    );
  }

  /// hover value at a particular index
  ///
  double _getValue(int index) {
    if (index == _prevHoverIndex) return 1 - _animationController.value;
    if (index == _activeHoverIndex) return _animationController.value;
    return 0;
  }

  /// computes necessary data render the hover effect on the table
  ///
  void _startedRowHover(int index) {
    if (_forceStoppedHover) return;

    if (index == _activeHoverIndex) {
      _isHovering = true;
      return;
    }
    _animationController.forward(from: 0);
    _prevHoverIndex = _activeHoverIndex;
    _activeHoverIndex = index;
    _isHovering = true;
  }

  /// stops the hover on a row
  ///
  void _stoppedRowHover() {
    _isHovering = false;
    Future.delayed(const Duration(milliseconds: 100), () {
      // if (_isHovering) return;
      if (_isHovering || _forceStoppedHover) return;
      _activeHoverIndex = -1;
      _prevHoverIndex = -1;
      _animationController.reverse();
    });
  }

  /// selects a particular row
  ///
  void select(int index, {bool refreshState = false}) {
    _selectedIndex = index;
    if (refreshState) refresh();
  }

  /// updates the state of the table to render new computations
  ///
  void refresh() {
    _onSelectStateUpdator?.call();
  }

  /// unselects a particular row
  ///
  void unSelect({bool refreshState = false}) {
    _selectedIndex = -1;
    if (refreshState) {
      _onSelectStateUpdator?.call();
    }
  }

  /// start the hover on a particular index
  ///
  void startHover(int index) => _startedRowHover(index);

  /// stop the row hover
  ///
  void stopHover() => _stoppedRowHover();

  /// disables hover effect
  ///
  void _forceStopHover() {
    _disableHover();
    _activeHoverIndex = -1;
    _prevHoverIndex = -1;
  }

  /// dispose the table
  ///
  void dispose() {
    if (_isHovering) _forceStopHover();
    _animationController.dispose();
  }

  void _enableHover() => _forceStoppedHover = false;

  void _disableHover() => _forceStoppedHover = true;

  int currentSelectedIndex() => _selectedIndex;
}
