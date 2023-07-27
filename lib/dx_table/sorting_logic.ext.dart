part of dx_table;

extension SortingLogic on DxTableController {
  /// pushes the other elements and add the provided element at the given index
  void _pushAndInsertAtIdx(int idx, List<int> arr, int ele) {
    if (arr[idx] == -1) {
      arr[idx] = ele;
      return;
    }

    for (int j = arr.length - 1; j > idx; j--) {
      int tmp = arr[j];
      arr[j] = arr[j - 1];
      arr[j - 1] = tmp;
    }
    arr[idx] = ele;
  }

  /// get the sort element present at the given co-ords
  T _tableRowSortElement<T>(
      {required int rowIndex, required int elementIndex}) {
    return _filteredRows[rowIndex].children[elementIndex].sortElement;
  }

  /// creates a sorted index array referring to the actual rows and stores in in a hashmap
  /// this process happens on demand and is an optimal approach for sorting the table elements
  void createSortIdxMap<T>(int elementindex) {
    if (_sortedIdxMap[elementindex] != null &&
        _sortedIdxMap[elementindex]!.length == _filteredRows.length) return;

    DxTableSortMechanism<T> dxTableSortMechanism = _dxTableHeader
        .titles[elementindex].sortingMechanism! as DxTableSortMechanism<T>;
    if (dxTableSortMechanism.groupOrderSort != null) {
      List<T> priorityArray = dxTableSortMechanism.groupOrderSort!;
      Map<T, List<int>> mp = {};
      for (int idx = 0; idx < priorityArray.length; idx++) {
        mp[priorityArray[idx]] = [];
      }

      for (int idx = 0; idx < _filteredRows.length; idx++) {
        T element =
            _tableRowSortElement(rowIndex: idx, elementIndex: elementindex);
        mp[element]?.add(idx);
      }

      List<int> arrIdx = [];

      for (List<int> arr in mp.values) {
        arrIdx.addAll(arr);
      }

      _sortedIdxMap[elementindex] = arrIdx;
      return;
    }
    List<int> idxArr =
        List.generate(_filteredRows.length, (elementindex) => -1);

    for (int idx = 0; idx < idxArr.length; idx++) {
      T elementToInsert =
          _tableRowSortElement(rowIndex: idx, elementIndex: elementindex);

      if (idx == 0 && idxArr[idx] == -1) {
        idxArr[idx] = idx;
        continue;
      }

      int j = 0;

      while (idxArr[j] != -1 &&
          j < idxArr.length - 1 &&
          dxTableSortMechanism.comparator!.call(
            _tableRowSortElement(
                rowIndex: idxArr[j], elementIndex: elementindex),
            elementToInsert,
          )) {
        j++;
      }

      _pushAndInsertAtIdx(j, idxArr, idx);
    }

    _sortedIdxMap[elementindex] = idxArr;
  }

  /// sort the rows to render based on the map
  void _sortRows(List<int> idxArr, List<DxTableRow> tmp) {
    for (int idx = 0; idx < idxArr.length; idx++) {
      tmp.add(_rows[idxArr[idx]]);
    }
    _filteredRows = tmp;
    refresh();
  }

  /// the sort state for a given column
  DxTableSortState _getSortStateForIndex(int index) {
    if (_currentSortIndex == index) {
      return _isReversed ? DxTableSortState.reversed : DxTableSortState.sorted;
    }

    return DxTableSortState.unsorted;
  }
}
