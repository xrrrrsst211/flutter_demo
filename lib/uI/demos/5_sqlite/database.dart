class DatabaseHelper {
  static const table = 'people';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnAge = 'age';

  final List<Map<String, Object?>> _rows = [];
  int _nextId = 1;

  Future<void> init() async {
    // In-memory demo storage. It keeps the same API used by sqlite_demo.dart,
    // so the lesson screen works without generated Drift files.
  }

  Future<int> insert(Map<String, Object?> row) async {
    final id = row[columnId] is int ? row[columnId] as int : _nextId++;
    final newRow = <String, Object?>{
      columnId: id,
      columnName: row[columnName] ?? '',
      columnAge: row[columnAge] ?? 0,
    };
    _rows.removeWhere((item) => item[columnId] == id);
    _rows.add(newRow);
    return id;
  }

  Future<List<Map<String, Object?>>> queryAllRows() async {
    return List<Map<String, Object?>>.from(_rows);
  }

  Future<int> update(Map<String, Object?> row) async {
    final id = row[columnId];
    if (id == null) return 0;

    final index = _rows.indexWhere((item) => item[columnId] == id);
    if (index == -1) return 0;

    _rows[index] = <String, Object?>{
      columnId: id,
      columnName: row[columnName] ?? _rows[index][columnName],
      columnAge: row[columnAge] ?? _rows[index][columnAge],
    };
    return 1;
  }

  Future<int> delete(int id) async {
    final before = _rows.length;
    _rows.removeWhere((item) => item[columnId] == id);
    return before - _rows.length;
  }
}
