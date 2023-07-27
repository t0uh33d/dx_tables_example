part of dx_table;

extension FilteringLogic on DxTableController {
  /// recreates the filter map whenever group id for a row is changed
  ///
  void recreateFilterMap(
    String prevKey,
    String currKey,
    String id,
  ) {
    int index = _idToIdxMap[id]!;
    if (_rows.isEmpty || _rows.length < index) return;
    _rows[index].groupID = currKey;
    _filterMap[prevKey]?.remove(id);
    if (_filterMap.containsKey(currKey)) {
      if (_filterMap[currKey] != null) {
        _filterMap[currKey]?.add(id);
      }
    } else {
      _filterMap[currKey] = {id};
    }
  }

  /// assings the id linked to the row into the group for filtering
  ///
  void _createFilterAtIdx(int idx) {
    if (_rows[idx].groupID == null) throw ('No tag found');
    if (_rows[idx].id == null) throw ('unique id needed for filtering');
    _idToIdxMap[_rows[idx].id!] = idx;
    String id = _rows[idx].groupID!;
    if (_filterMap.containsKey(id) && _filterMap[id] != null) {
      _filterMap[id]?.add(_rows[idx].id!);
      return;
    }

    _filterMap[id] = {_rows[idx].id!};
  }
}
