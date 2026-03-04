
import 'package:flutter/material.dart';

import '../api_access.dart';
import '../general_function.dart';

class SpItem {
  static Future<dynamic> get({
    BuildContext? context,
    int? id,
    int? categoryId,
    String? name,
    bool viewLoadingProcess = true,
    bool? isFrozen,
    bool? isDeleted,
    int? catTypeId,
  }) async {
    //
    String baseSelect = """
      SELECT Item.*, Category.CatNo 
      FROM Item 
      INNER JOIN Category  ON Item.CategoryId = Category.ID 
    """;

    final List<String> conditions = [];

    // ── Static filters ──
    if (id != null) conditions.add("Item.ID = $id");
    if (categoryId != null) conditions.add("Item.CategoryId = $categoryId");
    if (name != null) conditions.add("(Item.Name LIKE '%$name%' OR Item.EName LIKE '%$name%')");

    // ── Dynamic state filters ──
    if (isFrozen != null) conditions.add("Item.Freeze = ${isFrozen ? 1 : 0}");
    if (isDeleted != null) conditions.add(isDeleted ? "Item.DeletionDate IS NOT NULL" : "Item.DeletionDate IS NULL");
    if (catTypeId != null)conditions.add("Category.CatTypeId = $catTypeId");
    final String whereClause = conditions.isEmpty ? "" : "WHERE ${conditions.join(' AND ')}";

    final String cmd = "$baseSelect $whereClause";

    dynamic result = await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);

    if (result == null) return null;

    // If filtering by a single ID return a single object, otherwise return the list
    return id != null ? result[0] : result;
  }

  // Get last ItemNo in a category to calculate next one
  static Future<int?> getLastItemNo({required int categoryId, BuildContext? context}) async {
    String cmd = "SELECT MAX(ItemNo) AS LastNo FROM [Item] WHERE CategoryId = $categoryId";
    dynamic result = await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: false);
    if (result == null || result[0]["LastNo"] == null) return null;
    return int.tryParse(result[0]["LastNo"].toString());
  }

  // Calculate next ItemNo: CatNo + (last suffix + 1)
  static Future<int> getNextItemNo({required int categoryId, required int catNo, BuildContext? context}) async {
    final lastItemNo = await getLastItemNo(categoryId: categoryId, context: context);

    if (lastItemNo == null) {
      // No items yet in this category → start with CatNo + "001"
      return int.parse("${catNo}001");
    }

    // Extract the numeric suffix (remove the CatNo prefix)
    final catNoStr = catNo.toString();
    final lastStr = lastItemNo.toString();

    // The suffix is everything after the CatNo prefix
    final suffix = int.parse(lastStr.substring(catNoStr.length));
    return int.parse("$catNo${suffix + 1}");
  }

  // INSERT - Create new item
  static Future<dynamic> insert({
    required BuildContext context,
    required int itemNo,
    required String name,
    required String eName,
    required String descrip,
    required int categoryId,
    bool viewLoadingProcess = true,
  }) async {
    String cmd =
        "INSERT INTO [Item] (ItemNo, Name, EName, Descrip, CategoryId, freeze) "
        "VALUES ($itemNo, N'$name', '$eName', N'$descrip', $categoryId, 0)";

    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // UPDATE - Update existing item
  static Future<dynamic> update({
    BuildContext? context,
    bool viewLoadingProcess = true,
    required int id,
    int? itemNo,
    String? name,
    String? eName,
    String? descrip,
    int? categoryId,
    bool? freeze,
    DateTime? deletionDate,
    bool? removeDeletionDate,
  }) async {
    final List<String> setParts = [];
    const String nullWord = "NULL";

    if (itemNo != null) setParts.add("ItemNo       = $itemNo");
    if (name != null) setParts.add("Name         = N'${name.trim()}'");
    if (eName != null) setParts.add("EName        = '${eName.trim()}'");
    if (descrip != null) setParts.add("Descrip      = N'${descrip.trim()}'");
    if (categoryId != null) setParts.add("CategoryId   = $categoryId");
    if (freeze != null) setParts.add("Freeze       = ${freeze ? 1 : 0}");
    if (deletionDate != null) setParts.add("DeletionDate = '${GeneralFunctions.toSqlDate(deletionDate)}'");
    if (removeDeletionDate == true) setParts.add("DeletionDate = $nullWord");

    if (setParts.isEmpty) return null;

    final String updCmd = "UPDATE [Item] SET ${setParts.join(', ')} WHERE ID = $id";

    return await ApiAccess.execCmd(RequestCmd(updCmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // SOFT DELETE - Set DeletionDate to now
  static Future<dynamic> softDelete({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    return await update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, deletionDate: DateTime.now());
  }

  // RESTORE - Remove DeletionDate (bring item back)
  static Future<dynamic> restore({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    return await update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, removeDeletionDate: true);
  }

  // FREEZE - Soft disable item (freeze = 1)
  static Future<dynamic> freeze({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    String cmd = "UPDATE [Item] SET freeze = 1 WHERE ID = $id";
    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // UNFREEZE - Re-enable item (freeze = 0)
  static Future<dynamic> unfreeze({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    String cmd = "UPDATE [Item] SET freeze = 0 WHERE ID = $id";
    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }
}

class SpCategory {
  static Future<dynamic> get ({BuildContext? context, int? id,int? catTypeId,bool viewLoadingProcess = false}) async {
    String cmd = "Select * From [Category]";
    if (catTypeId != null) cmd += " WHERE catTypeId = $catTypeId";
    if (id != null) cmd += " WHERE ID = $id";
    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  static Future<dynamic> insert({
    required BuildContext context,
    required int catNo,
    required String descrip,
    required int catTypeId,
    bool viewLoadingProcess = true,
  }) async {
    String cmd =
        "INSERT INTO [Category] (catNo, Descrip, catTypeId, freeze) "
        "VALUES ($catNo, N'$descrip', $catTypeId, 0)";

    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  static Future<dynamic> update({
    BuildContext? context,
    bool viewLoadingProcess = true,
    required int id,
    int? catNo,
    String? descrip,
    int? catTypeId,
    bool? freeze,
    DateTime? deletionDate,
    bool? removeDeletionDate,
  }) async {
    final List<String> setParts = [];
    const String nullWord = "NULL";

    if (catNo != null) setParts.add("CatNo       = $catNo");
    if (descrip != null) setParts.add("Descrip         = N'${descrip.trim()}'");
    if (descrip != null) setParts.add("Descrip      = N'${descrip.trim()}'");
    if (catTypeId != null) setParts.add("CatTypeId   = $catTypeId");
    if (freeze != null) setParts.add("Freeze       = ${freeze ? 1 : 0}");
    if (deletionDate != null) setParts.add("DeletionDate = '${GeneralFunctions.toSqlDate(deletionDate)}'");
    if (removeDeletionDate == true) setParts.add("DeletionDate = $nullWord");

    if (setParts.isEmpty) return null;

    final String updCmd = "UPDATE [Category] SET ${setParts.join(', ')} WHERE ID = $id";

    return await ApiAccess.execCmd(RequestCmd(updCmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }
  static Future<dynamic> softDelete({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    return await update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, deletionDate: DateTime.now());
  }

  // RESTORE - Remove DeletionDate (bring item back)
  static Future<dynamic> restore({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    return await update(id: id, context: context, viewLoadingProcess: viewLoadingProcess, removeDeletionDate: true);
  }

  // FREEZE - Soft disable item (freeze = 1)
  static Future<dynamic> freeze({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    String cmd = "UPDATE [Category] SET Freeze = 1 WHERE ID = $id";
    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }

  // UNFREEZE - Re-enable item (freeze = 0)
  static Future<dynamic> unfreeze({required int id, BuildContext? context, bool viewLoadingProcess = true}) async {
    String cmd = "UPDATE [Category] SET Freeze = 0 WHERE ID = $id";
    return await ApiAccess.execCmd(RequestCmd(cmd), context: context, viewLoadingProcess: viewLoadingProcess);
  }
}
