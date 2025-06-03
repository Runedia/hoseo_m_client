import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

    // 메뉴 데이터 테이블 추가
    await db.execute('''
      CREATE TABLE menu_data (
        id INTEGER PRIMARY KEY,
        action TEXT NOT NULL,
        page INTEGER NOT NULL,
        json_data TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        UNIQUE(action, page)
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_detail_data (
        id INTEGER PRIMARY KEY,
        action TEXT NOT NULL,
        chidx TEXT NOT NULL,
        json_data TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        UNIQUE(action, chidx)
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

  // 메뉴 목록 데이터 저장
  Future<void> saveMenuListData(String action, int page, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final jsonData = jsonEncode(data);
      final now = DateTime.now().toIso8601String();

      await db.insert('menu_data', {
        'action': action,
        'page': page,
        'json_data': jsonData,
        'last_updated': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('메뉴 목록 데이터 저장 실패: $e');
    }
  }

  // 메뉴 목록 데이터 가져오기
  Future<Map<String, dynamic>?> getMenuListData(String action, int page) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'menu_data',
        where: 'action = ? AND page = ?',
        whereArgs: [action, page],
      );

      if (maps.isNotEmpty) {
        final jsonData = maps.first['json_data'] as String;
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('메뉴 목록 데이터 조회 실패: $e');
    }
  }

  // 메뉴 상세 데이터 저장
  Future<void> saveMenuDetailData(String action, String chidx, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final jsonData = jsonEncode(data);
      final now = DateTime.now().toIso8601String();

      await db.insert('menu_detail_data', {
        'action': action,
        'chidx': chidx,
        'json_data': jsonData,
        'last_updated': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('메뉴 상세 데이터 저장 실패: $e');
    }
  }

  // 메뉴 상세 데이터 가져오기
  Future<Map<String, dynamic>?> getMenuDetailData(String action, String chidx) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'menu_detail_data',
        where: 'action = ? AND chidx = ?',
        whereArgs: [action, chidx],
      );

      if (maps.isNotEmpty) {
        final jsonData = maps.first['json_data'] as String;
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('메뉴 상세 데이터 조회 실패: $e');
    }
  }

  // 메뉴 데이터 삭제
  Future<void> clearMenuData(String action) async {
    try {
      final db = await database;
      await db.delete('menu_data', where: 'action = ?', whereArgs: [action]);
      await db.delete('menu_detail_data', where: 'action = ?', whereArgs: [action]);
    } catch (e) {
      throw Exception('메뉴 데이터 삭제 실패: $e');
    }
  }

  // 클래스 정보 데이터 저장
  Future<void> saveClassData(String type, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final jsonData = jsonEncode(data);
      final now = DateTime.now().toIso8601String();

      // 테이블이 없으면 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS class_data (
          id INTEGER PRIMARY KEY,
          type TEXT NOT NULL UNIQUE,
          json_data TEXT NOT NULL,
          last_updated TEXT NOT NULL
        )
      ''');

      await db.insert('class_data', {
        'type': type,
        'json_data': jsonData,
        'last_updated': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('클래스 데이터 저장 실패: $e');
    }
  }

  // 클래스 정보 데이터 가져오기
  Future<Map<String, dynamic>?> getClassData(String type) async {
    try {
      final db = await database;

      // 테이블이 없으면 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS class_data (
          id INTEGER PRIMARY KEY,
          type TEXT NOT NULL UNIQUE,
          json_data TEXT NOT NULL,
          last_updated TEXT NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> maps = await db.query(
        'class_data',
        where: 'type = ?',
        whereArgs: [type],
      );

      if (maps.isNotEmpty) {
        final jsonData = maps.first['json_data'] as String;
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('클래스 데이터 조회 실패: $e');
    }
  }

  // 캠퍼스맵 데이터 저장
  Future<void> saveCampusMapData(String campusCode, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final jsonData = jsonEncode(data);
      final now = DateTime.now().toIso8601String();

      await db.execute('''
        CREATE TABLE IF NOT EXISTS campus_map_data (
          id INTEGER PRIMARY KEY,
          campus_code TEXT NOT NULL UNIQUE,
          json_data TEXT NOT NULL,
          last_updated TEXT NOT NULL
        )
      ''');

      await db.insert('campus_map_data', {
        'campus_code': campusCode,
        'json_data': jsonData,
        'last_updated': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw Exception('캠퍼스맵 데이터 저장 실패: $e');
    }
  }

  // 캠퍼스맵 데이터 가져오기
  Future<Map<String, dynamic>?> getCampusMapData(String campusCode) async {
    try {
      final db = await database;

      // 테이블이 없으면 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS campus_map_data (
          id INTEGER PRIMARY KEY,
          campus_code TEXT NOT NULL UNIQUE,
          json_data TEXT NOT NULL,
          last_updated TEXT NOT NULL
        )
      ''');

      final List<Map<String, dynamic>> maps = await db.query(
        'campus_map_data',
        where: 'campus_code = ?',
        whereArgs: [campusCode],
      );

      if (maps.isNotEmpty) {
        final jsonData = maps.first['json_data'] as String;
        return jsonDecode(jsonData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('캠퍼스맵 데이터 조회 실패: $e');
    }
  }

  // 저장된 모든 파일 삭제 (이미지, JSON 등)
  Future<void> clearAllStoredFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory(appDir.path);

      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();

        for (FileSystemEntity file in files) {
          if (file is File) {
            final fileName = file.path.split('/').last.toLowerCase();
            // 캐시된 이미지 파일들과 JSON 파일들 삭제
            if (fileName.endsWith('.jpg') ||
                fileName.endsWith('.jpeg') ||
                fileName.endsWith('.png') ||
                fileName.endsWith('.gif') ||
                fileName.endsWith('.json') ||
                fileName.endsWith('.webp')) {
              try {
                await file.delete();
                print('파일 삭제됨: ${file.path}');
              } catch (e) {
                print('파일 삭제 실패: ${file.path}, 오류: $e');
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('저장된 파일 삭제 실패: $e');
    }
  }

  // 전체 데이터베이스 초기화 (모든 테이블 데이터 삭제)
  Future<void> resetDatabase() async {
    try {
      final db = await database;

      // 모든 테이블의 데이터 삭제
      await db.delete('schedule_data');
      await db.delete('menu_data');
      await db.delete('menu_detail_data');

      print('데이터베이스가 성공적으로 초기화되었습니다.');
    } catch (e) {
      throw Exception('데이터베이스 초기화 실패: $e');
    }
  }

  // 데이터베이스 완전 재생성 (파일 삭제 후 재생성)
  Future<void> recreateDatabase() async {
    try {
      // 기존 데이터베이스 연결 종료
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // 데이터베이스 파일 삭제
      String path = join(await getDatabasesPath(), 'uiux7.db');
      await deleteDatabase(path);

      // 데이터베이스 재생성 (다음 접근 시 자동으로 _onCreate 호출됨)
      await database; // 이 호출로 새 데이터베이스가 생성됨

      print('데이터베이스가 성공적으로 재생성되었습니다.');
    } catch (e) {
      throw Exception('데이터베이스 재생성 실패: $e');
    }
  }
}
