import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseManager {
  static DatabaseManager? _instance;
  static Database? _database;

  // 싱글톤 패턴
  static DatabaseManager get instance {
    _instance ??= DatabaseManager._internal();
    return _instance!;
  }

  DatabaseManager._internal();

  // 데이터베이스 초기화
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'uiux7.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE schedule_data (
        id INTEGER PRIMARY KEY,
        json_data TEXT NOT NULL,
        last_updated TEXT NOT NULL
      )
    ''');
  }

  // 학사일정 데이터 저장
  Future<void> saveScheduleData(Map<String, dynamic> data) async {
    try {
      final db = await database;
      final jsonData = jsonEncode(data);
      final now = DateTime.now().toIso8601String();

      // 기존 데이터 삭제 후 새 데이터 삽입
      await db.delete('schedule_data');
      await db.insert('schedule_data', {'json_data': jsonData, 'last_updated': now});
    } catch (e) {
      throw Exception('데이터 저장 실패: $e');
    }
  }

  // 학사일정 데이터 가져오기
  Future<Map<String, dynamic>?> getScheduleData() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('schedule_data');

      if (maps.isNotEmpty) {
        final jsonData = maps.first['json_data'] as String;
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('데이터 조회 실패: $e');
    }
  }

  // 로컬 데이터 존재 여부 확인
  Future<bool> hasLocalData() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('schedule_data');
      return maps.isNotEmpty;
    } catch (e) {
      throw Exception('데이터 확인 실패: $e');
    }
  }

  // 마지막 업데이트 시간 가져오기
  Future<DateTime?> getLastUpdated() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('schedule_data');

      if (maps.isNotEmpty) {
        final lastUpdated = maps.first['last_updated'] as String;
        return DateTime.parse(lastUpdated);
      }
      return null;
    } catch (e) {
      throw Exception('업데이트 시간 조회 실패: $e');
    }
  }

  // 데이터 삭제
  Future<void> clearData() async {
    try {
      final db = await database;
      await db.delete('schedule_data');
    } catch (e) {
      throw Exception('데이터 삭제 실패: $e');
    }
  }

  // 데이터베이스 닫기
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
