import 'package:flutter/material.dart';
import '../api_access.dart';
import '../general_function.dart';

const String _null = "NULL";

// ═══════════════════════════════════════════════════════════
//  SpStore
// ═══════════════════════════════════════════════════════════
class SpStore {

  // ── GET ─────────────────────────────────────────────────
  static Future<List<StoreModel>?> get({
    BuildContext? context,
    int?         id,
    String?      name,
    int?         storeTypeId,
    StoreStatus? status,
    int?         userRequestId,
    bool         viewLoadingProcess = true,
  }) async {
    const String baseSelect =
        "SELECT Store.*, [User].FullName, [User].PhoneNumber "
        "FROM Store "
        "INNER JOIN [User] ON Store.UserRequestId = [User].ID";

    final List<String> conditions = [];

    if (id          != null) conditions.add("Store.ID = $id");
    if (name        != null) conditions.add("Store.Name LIKE '%$name%'");
    if (storeTypeId != null) conditions.add("Store.StoreTypeId = $storeTypeId");
    if (userRequestId != null) conditions.add("Store.UserRequestId = $userRequestId");


    if (status != null) {
      switch (status) {
        case StoreStatus.underReview:
          conditions.add("Store.ExpiredDate IS NULL");
          conditions.add("Store.DeletionDate IS NULL");
          break;
        case StoreStatus.active:
          conditions.add("Store.ExpiredDate IS NOT NULL");
          conditions.add("Store.DeletionDate IS NULL");
          break;
        case StoreStatus.deleted:
          conditions.add("Store.DeletionDate IS NOT NULL");
          break;
      }
    }

    final String where = conditions.isEmpty ? "" : "WHERE ${conditions.join(' AND ')}";
    final String cmd   = "$baseSelect $where";

    final dynamic raw = await ApiAccess.execCmd(
      RequestCmd(cmd),
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );

    if (raw == null) return null;
    final List list = id != null ? [raw[0]] : raw as List;
    return list.map((e) => StoreModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  // ── GET BY ID ────────────────────────────────────────────
  static Future<StoreModel?> getById({
    required int id,
    BuildContext? context,
    bool viewLoadingProcess = false,
  }) async {
    final result = await get(id: id, context: context, viewLoadingProcess: viewLoadingProcess);
    return result?.isNotEmpty == true ? result!.first : null;
  }

  // ── GET UNDER REVIEW ─────────────────────────────────────
  static Future<List<StoreModel>?> getUnderReview({
    BuildContext? context,
    bool viewLoadingProcess = true,
  }) =>
      get(context: context, status: StoreStatus.underReview, viewLoadingProcess: viewLoadingProcess);

  // ── GET ACTIVE ───────────────────────────────────────────
  static Future<List<StoreModel>?> getActive({
    BuildContext? context,
    int?  storeTypeId,
    bool  viewLoadingProcess = true,
  }) =>
      get(context: context, status: StoreStatus.active, storeTypeId: storeTypeId, viewLoadingProcess: viewLoadingProcess);

  // ── INSERT ───────────────────────────────────────────────
  static Future<dynamic> insert({
    required BuildContext context,
    required String name,
    required String descrip,
    required String location,
    required int    storeTypeId,
    required int    userRequestId,
    bool viewLoadingProcess = true,
  }) async {
    final String cmd =
        "INSERT INTO Store (Name, Descrip, Location, UserRequestId, StoreTypeId, CreationDate) "
        "VALUES ("
        "N'${name.trim()}', "
        "N'${descrip.trim()}', "
        "N'${location.trim()}', "
        "$userRequestId, "
        "$storeTypeId, "
        "'${GeneralFunctions.toSqlDate(DateTime.now())}'"
        ")";

    return ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // ── UPDATE ───────────────────────────────────────────────
  static Future<dynamic> update({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
    String?       name,
    String?       descrip,
    String?       location,
    int?          storeTypeId,
    DateTime?     expiredDate,
    DateTime?     deletionDate,
    bool?         removeExpiredDate,
    bool?         removeDeletionDate,
  }) async {
    final List<String> setParts = [];

    if (name        != null) setParts.add("Name         = N'${name.trim()}'");
    if (descrip     != null) setParts.add("Descrip      = N'${descrip.trim()}'");
    if (location    != null) setParts.add("Location     = N'${location.trim()}'");
    if (storeTypeId != null) setParts.add("StoreTypeId  = $storeTypeId");

    if (expiredDate       != null) setParts.add("ExpiredDate  = '${GeneralFunctions.toSqlDate(expiredDate)}'");
    if (removeExpiredDate == true) setParts.add("ExpiredDate  = $_null");

    if (deletionDate       != null) setParts.add("DeletionDate = '${GeneralFunctions.toSqlDate(deletionDate)}'");
    if (removeDeletionDate == true) setParts.add("DeletionDate = $_null");

    if (setParts.isEmpty) return null;

    final String cmd = "UPDATE Store SET ${setParts.join(', ')} WHERE ID = $id";
    return ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // ── APPROVE ──────────────────────────────────────────────
  /// Sets ExpiredDate = now → store becomes active
  static Future<dynamic> approve({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, expiredDate: DateTime.now());

  // ── REVOKE APPROVAL ──────────────────────────────────────
  /// Sets ExpiredDate = NULL → store goes back to under review
  static Future<dynamic> revokeApproval({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, removeExpiredDate: true);

  // ── SOFT DELETE ──────────────────────────────────────────
  static Future<dynamic> softDelete({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, deletionDate: DateTime.now());

  // ── RESTORE ──────────────────────────────────────────────
  static Future<dynamic> restore({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, removeDeletionDate: true);
}

// ═══════════════════════════════════════════════════════════
//  SpStoreType
// ═══════════════════════════════════════════════════════════
class SpStoreType {

  // ── GET ─────────────────────────────────────────────────
  static Future<List<StoreTypeModel>?> get({
    BuildContext? context,
    int?  id,
    bool  viewLoadingProcess  = false,
  }) async {
    String cmd = "SELECT * FROM StoreType WHERE Active = 1";

    final List<String> conditions = [];
    if (id         != null) conditions.add("ID = $id");
    if (conditions.isNotEmpty) cmd += "  ${conditions.join(' AND ')}";

    final dynamic raw = await ApiAccess.execCmd(
      RequestCmd(cmd),
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );

    if (raw == null) return null;
    final List list = id != null ? [raw[0]] : raw as List;
    return list.map((e) => StoreTypeModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  // ── GET BY ID ────────────────────────────────────────────
  static Future<StoreTypeModel?> getById({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = false,
  }) async {
    final result = await get(id: id, context: context, viewLoadingProcess: viewLoadingProcess);
    return result?.isNotEmpty == true ? result!.first : null;
  }

  // ── INSERT ───────────────────────────────────────────────
  static Future<dynamic> insert({
    required BuildContext context,
    required String       descrip,
    bool                  viewLoadingProcess = true,
  }) async {
    final String cmd = "INSERT INTO StoreType (Descrip) VALUES (N'${descrip.trim()}')";
    return ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // ── UPDATE ───────────────────────────────────────────────
  static Future<dynamic> update({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
    String?       descrip,
    DateTime?     deletionDate,
    bool?         removeDeletionDate,
  }) async {
    final List<String> setParts = [];

    if (descrip            != null) setParts.add("Descrip      = N'${descrip.trim()}'");

    if (setParts.isEmpty) return null;

    final String cmd = "UPDATE StoreType SET ${setParts.join(', ')} WHERE ID = $id";
    return ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }
}
// ═══════════════════════════════════════════════════════════
//  SpStoreUser
// ═══════════════════════════════════════════════════════════

class SpStoreUser {

  // ── GET ─────────────────────────────────────────────────
  static Future<List<StoreUserModel>?> get({
    BuildContext? context,
    int?          id,
    int?          storeId,
    int?          userId,
    bool          withDeleted          = false,   // false → only active records
    bool          viewLoadingProcess   = false,
  }) async {
    const String baseSelect =
        "SELECT StoreUser.*, "
        "[User].FullName, [User].PhoneNumber, "
        "Store.Name AS StoreName "
        "FROM StoreUser "
        "INNER JOIN [User] ON StoreUser.UserId  = [User].ID "
        "INNER JOIN Store  ON StoreUser.StoreId = Store.ID";

    final List<String> conditions = [];

    if (id      != null) conditions.add("StoreUser.ID      = $id");
    if (storeId != null) conditions.add("StoreUser.StoreId = $storeId");
    if (userId  != null) conditions.add("StoreUser.UserId  = $userId");

    // by default only show non-deleted rows
    if (!withDeleted) conditions.add("StoreUser.DeletionDate IS NULL");

    final String where =
    conditions.isEmpty ? "" : "WHERE ${conditions.join(' AND ')}";
    final String cmd = "$baseSelect $where";

    final dynamic raw = await ApiAccess.execCmd(
      RequestCmd(cmd),
      context: context,
      viewLoadingProcess: viewLoadingProcess,
    );

    if (raw == null) return null;
    // when querying by id we still get a list, keep consistent with SpStore
    final List list = (id != null) ? [raw[0]] : raw as List;
    return list
        .map((e) => StoreUserModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── GET BY ID ────────────────────────────────────────────
  static Future<StoreUserModel?> getById({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = false,
  }) async {
    final result = await get(
      id:                 id,
      context:            context,
      viewLoadingProcess: viewLoadingProcess,
    );
    return result?.isNotEmpty == true ? result!.first : null;
  }

  // ── GET BY STORE ─────────────────────────────────────────
  static Future<List<StoreUserModel>?> getByStore({
    required int  storeId,
    BuildContext? context,
    bool          withDeleted        = false,
    bool          viewLoadingProcess = false,
  }) =>
      get(
        storeId:            storeId,
        context:            context,
        withDeleted:        withDeleted,
        viewLoadingProcess: viewLoadingProcess,
      );

  // ── GET BY USER ──────────────────────────────────────────
  static Future<List<StoreUserModel>?> getByUser({
    required int  userId,
    BuildContext? context,
    bool          withDeleted        = false,
    bool          viewLoadingProcess = false,
  }) =>
      get(
        userId:             userId,
        context:            context,
        withDeleted:        withDeleted,
        viewLoadingProcess: viewLoadingProcess,
      );

  // ── INSERT ───────────────────────────────────────────────
  static Future<dynamic> insert({
    required int  storeId,
    required int  userId,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) async {
    final String cmd =
        "INSERT INTO StoreUser (StoreId, UserId, CreationDate) "
        "VALUES ("
        "$storeId, "
        "$userId, "
        "'${GeneralFunctions.toSqlDate(DateTime.now())}'"
        ")";

    return ApiAccess.execCmd(
      RequestCmd(cmd),
      context:            context,
      viewLoadingProcess: viewLoadingProcess,
    );
  }

  // ── UPDATE ───────────────────────────────────────────────
  static Future<dynamic> update({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess  = true,
    DateTime?     deletionDate,
    bool?         removeDeletionDate,
  }) async {
    final List<String> setParts = [];

    if (deletionDate       != null) setParts.add("DeletionDate = '${GeneralFunctions.toSqlDate(deletionDate)}'");
    if (removeDeletionDate == true) setParts.add("DeletionDate = $_null");

    if (setParts.isEmpty) return null;

    final String cmd =
        "UPDATE StoreUser SET ${setParts.join(', ')} WHERE ID = $id";

    return ApiAccess.execCmd(
      RequestCmd(cmd),
      context:            context,
      viewLoadingProcess: viewLoadingProcess,
    );
  }

  // ── SOFT DELETE ──────────────────────────────────────────
  static Future<dynamic> softDelete({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(
        id:                 id,
        context:            context,
        viewLoadingProcess: viewLoadingProcess,
        deletionDate:       DateTime.now(),
      );

  // ── RESTORE ──────────────────────────────────────────────
  static Future<dynamic> restore({
    required int  id,
    BuildContext? context,
    bool          viewLoadingProcess = true,
  }) =>
      update(
        id:                 id,
        context:            context,
        viewLoadingProcess: viewLoadingProcess,
        removeDeletionDate: true,
      );
}
// ═══════════════════════════════════════════════════════════
//  StoreStatus Enum
// ═══════════════════════════════════════════════════════════
enum StoreStatus {
  underReview, // ExpiredDate IS NULL  + DeletionDate IS NULL → waiting for approval
  active,      // ExpiredDate IS NOT NULL + DeletionDate IS NULL → visible
  deleted,     // DeletionDate IS NOT NULL → soft deleted
}

// ═══════════════════════════════════════════════════════════
//  StoreModel
// ═══════════════════════════════════════════════════════════
class StoreModel {
  final int       id;
  final String    name;
  final String    descrip;
  final String    location;
  final int       storeTypeId;
  final int       userRequestId;
  final DateTime  creationDate;
  final DateTime? expiredDate;
  final DateTime? deletionDate;
  final String    fullName;      // ← NEW
  final String    phoneNumber;

  const StoreModel({
    required this.id,
    required this.name,
    required this.descrip,
    required this.location,
    required this.storeTypeId,
    required this.userRequestId,
    required this.creationDate,
    this.expiredDate,
    this.deletionDate,
    required this.fullName,      // ← NEW
    required this.phoneNumber,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map) => StoreModel(
    id:            map['ID']                                              as int,
    name:          GeneralFunctions.ifMapOrNull(map['Name'])             as String,
    descrip:       GeneralFunctions.ifMapOrNull(map['Descrip'])          as String,
    location:      GeneralFunctions.ifMapOrNull(map['Location'])         as String,
    storeTypeId:   map['StoreTypeId']                                    as int,
    userRequestId: GeneralFunctions.ifMapOrNull(map['UserRequestId'], whenEmpty: 0) as int,
    creationDate:  DateTime.parse(GeneralFunctions.ifMapOrNull(map['CreationDate']) as String),
    expiredDate:   _parseDate(map['ExpiredDate']),
    deletionDate:  _parseDate(map['DeletionDate']),
    fullName:      GeneralFunctions.ifMapOrNull(map['FullName'])    as String,   // ← NEW
    phoneNumber:   GeneralFunctions.ifMapOrNull(map['PhoneNumber']) as String,
  );

  static DateTime? _parseDate(dynamic value) {
    final cleaned = GeneralFunctions.ifMapOrNull(value);
    if (cleaned is! String || cleaned.trim().isEmpty) return null;
    return DateTime.tryParse(cleaned);
  }


  // ── Status ───────────────────────────────────
  StoreStatus get status {
    if (deletionDate != null) return StoreStatus.deleted;
    if (expiredDate  == null) return StoreStatus.underReview;
    return StoreStatus.active;
  }

  bool get isUnderReview => status == StoreStatus.underReview;
  bool get isActive       => status == StoreStatus.active;
  bool get isDeleted      => status == StoreStatus.deleted;

  String get statusLabel {
    switch (status) {
      case StoreStatus.underReview: return 'قيد المراجعة';
      case StoreStatus.active:      return 'نشط';
      case StoreStatus.deleted:     return 'محذوف';
    }
  }

  Color get statusColor {
    switch (status) {
      case StoreStatus.underReview: return Colors.orange;
      case StoreStatus.active:      return Colors.green;
      case StoreStatus.deleted:     return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case StoreStatus.underReview: return Icons.hourglass_empty_rounded;
      case StoreStatus.active:      return Icons.check_circle_outline_rounded;
      case StoreStatus.deleted:     return Icons.delete_outline_rounded;
    }
  }

  @override
  String toString() => 'StoreModel(id: $id, name: $name, status: $statusLabel)';
}

// ═══════════════════════════════════════════════════════════
//  StoreTypeModel
// ═══════════════════════════════════════════════════════════
class StoreTypeModel {
  final int       id;
  final String    descrip;

  const StoreTypeModel({
    required this.id,
    required this.descrip,
  });

  factory StoreTypeModel.fromMap(Map<String, dynamic> map) => StoreTypeModel(
    id:           map['ID']                                         as int,
    descrip:      GeneralFunctions.ifMapOrNull(map['Descrip'])      as String,
  );


  @override
  String toString() => 'StoreTypeModel(id: $id, descrip: $descrip)';
}
// ═══════════════════════════════════════════════════════════
//  StoreUserModel
// ═══════════════════════════════════════════════════════════
class StoreUserModel {
  final int       id;
  final int       storeId;
  final int       userId;
  final DateTime  creationDate;
  final DateTime? deletionDate;
  final String    fullName;
  final String    phoneNumber;
  final String    storeName;

  const StoreUserModel({
    required this.id,
    required this.storeId,
    required this.userId,
    required this.creationDate,
    this.deletionDate,
    required this.fullName,
    required this.phoneNumber,
    required this.storeName,
  });

  factory StoreUserModel.fromMap(Map<String, dynamic> map) => StoreUserModel(
    id:           map['ID']                                              as int,
    storeId:      map['StoreId']                                         as int,
    userId:       map['UserId']                                          as int,
    creationDate: DateTime.parse(
        GeneralFunctions.ifMapOrNull(map['CreationDate']) as String),
    deletionDate: _parseDate(map['DeletionDate']),
    fullName:     GeneralFunctions.ifMapOrNull(map['FullName'])          as String,
    phoneNumber:  GeneralFunctions.ifMapOrNull(map['PhoneNumber'])       as String,
    storeName:    GeneralFunctions.ifMapOrNull(map['StoreName'])         as String,
  );

  static DateTime? _parseDate(dynamic value) {
    final cleaned = GeneralFunctions.ifMapOrNull(value);
    if (cleaned is! String || cleaned.trim().isEmpty) return null;
    return DateTime.tryParse(cleaned);
  }
}