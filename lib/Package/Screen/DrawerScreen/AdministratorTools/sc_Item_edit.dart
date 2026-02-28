import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';
import '../../../Core/StoredProcedures/item.dart';
import '../../../Core/general_function.dart';
import '../../../Core/shared_preference.dart';
import '../../../Widget/my_drawer.dart';
import 'admin_tools_shared.dart';

// ─── View-model ───────────────────────────────────────────────────────────────
class _ItemViewModel implements AdminViewModel {
  @override
  final dynamic raw;
  final String  name;
  final String  catNo;
  final String  catLabel;

  const _ItemViewModel({
    required this.raw,
    required this.name,
    required this.catNo,
    required this.catLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class ItemEditScreen extends StatefulWidget {
  const ItemEditScreen({super.key});

  @override
  State<ItemEditScreen> createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double>   _fadeAnimation;

  List<dynamic>         _items           = [];
  List<dynamic>         _categories      = [];
  Map<int, dynamic>     _categoryMap     = {};
  List<_ItemViewModel>  _filteredItems   = [];
  bool                  _isLoading       = true;

  final TextEditingController _searchController = TextEditingController();
  int?  _selectedCategoryId;
  bool? _frozenFilter;

  // ─── helpers ────────────────────────────────────────────────────────────────
  bool _isFrozen(dynamic item) => item["Freeze"] == true;
  bool _isDeleted(dynamic item) =>
      GeneralFunctions.ifMapOrNull(item["DeletionDate"]) != "";

  int _computeNextItemNo() {
    if (_items.isEmpty) return 100;
    int maxNo = 0;
    for (final item in _items) {
      final raw = int.tryParse(
          GeneralFunctions.ifMapOrNull(item["ItemNo"]).toString()) ??
          0;
      if (raw > maxNo) maxNo = raw;
    }
    final next = maxNo + 1;
    return next < 100 ? 100 : next;
  }

  // ─── lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
    _initData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── data ────────────────────────────────────────────────────────────────────
  Future<void> _initData() async {
    await _loadCategories();
    await _loadItems();
  }

  Future<void> _loadCategories() async {
    final cached = await SharedPreference.sharedPreferencesGetListDynamic(
        SharedPreference.categories);
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _categories  = cached;
        _categoryMap = {for (final c in cached) c["ID"] as int: c};
      });
    }
    final result = await SpCategory.get(
        context: context, catTypeId: 1, viewLoadingProcess: false);
    if (result == null) return;
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.categories, list);
    if (mounted) {
      setState(() {
        _categories  = list;
        _categoryMap = {for (final c in list) c["ID"] as int: c};
      });
    }
  }

  Future<void> _loadItems() async {
    if (mounted) setState(() => _isLoading = true);
    final cached = await SharedPreference.sharedPreferencesGetListDynamic(
        SharedPreference.items);
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _items     = cached;
        _isLoading = false;
      });
      _applySmartFilter();
    }
    final result =
    await SpItem.get(context: context, viewLoadingProcess: false);
    if (result == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.items, list);
    if (mounted) {
      setState(() {
        _items     = list;
        _isLoading = false;
      });
      _applySmartFilter();
    }
  }

  Future<void> _refreshAfterMutation() async {
    final result =
    await SpItem.get(context: context, viewLoadingProcess: false);
    if (result == null) return;
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.items, list);
    if (mounted) {
      _items = list;
      _applySmartFilter();
    }
  }

  // ─── filter ──────────────────────────────────────────────────────────────────
  void _applySmartFilter() {
    final query = _searchController.text.toLowerCase();
    final List<_ItemViewModel> staging = [];

    for (final item in _items) {
      // 1. Never show deleted items
      if (_isDeleted(item)) continue;

      // 2. Never show items whose parent category is frozen
      //    (regardless of the frozen checkbox state)
      final int? catId = item["CategoryId"] as int?;
      final parentCat  = catId != null ? _categoryMap[catId] : null;
      if (parentCat != null && parentCat["Freeze"] == true) continue;

      // 3. Item-level frozen filter
      final bool itemFrozen = _isFrozen(item);
      if (_frozenFilter == true  && !itemFrozen) continue;
      if (_frozenFilter != true  &&  itemFrozen) continue;

      // 4. Category filter (dropdown selection)
      if (_selectedCategoryId != null) {
        final selected = _categoryMap[_selectedCategoryId];
        if (selected == null ||
            selected["Freeze"] == true ||
            GeneralFunctions.ifMapOrNull(selected["DeletionDate"]) != "") {
          _selectedCategoryId = null;
        }
      }

      // 5. Text search
      final String name  =
      GeneralFunctions.ifMapOrNull(item["Name"]).toString();
      final String eName =
      GeneralFunctions.ifMapOrNull(item["EName"]).toString();
      if (query.isNotEmpty &&
          !name.toLowerCase().contains(query) &&
          !eName.toLowerCase().contains(query)) continue;

      // 6. Resolve category label — O(1)
      final catNo   = parentCat != null
          ? GeneralFunctions.ifMapOrNull(parentCat["CatNo"]).toString()
          : "";
      final descrip = parentCat != null
          ? GeneralFunctions.ifMapOrNull(parentCat["Descrip"]).toString()
          : "";

      staging.add(_ItemViewModel(
        raw:      item,
        name:     name,
        catNo:    catNo,
        catLabel: parentCat != null ? "$catNo - $descrip" : "",
      ));
    }

    staging.sort((a, b) {
      final c = a.catNo.compareTo(b.catNo);
      return c != 0 ? c : a.name.compareTo(b.name);
    });

    setState(() => _filteredItems = staging);
  }

  // ─── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    // Build dropdown items for the filter box
    final List<DropdownMenuItem<int?>> catDropdownItems = [
      DropdownMenuItem<int?>(
        value: null,
        child: Row(children: [
          Icon(Icons.all_inclusive,
              color: Colors.white.withOpacity(0.5),
              size: size.width * 0.045),
          SizedBox(width: size.width * 0.02),
          Text("كل الفئات",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: size.width * 0.032)),
        ]),
      ),
      ..._categories
          .where((cat) =>
      cat["Freeze"] != true &&
          GeneralFunctions.ifMapOrNull(cat["DeletionDate"]) == "")
          .map((cat) {
        final id      = cat["ID"] as int? ?? 0;
        final descrip =
        GeneralFunctions.ifMapOrNull(cat["Descrip"]).toString();
        final catNo =
        GeneralFunctions.ifMapOrNull(cat["CatNo"]).toString();
        return DropdownMenuItem<int?>(
          value: id,
          child: Row(children: [
            Icon(Icons.label_outline,
                color: AppTheme.mainColor.withOpacity(0.7),
                size: size.width * 0.045),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text("$catNo - $descrip",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.032),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        );
      }),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.darkBackground,
        drawer: MyDrawer(afterTap: () => setState(() {})),
        appBar: MyStyledAppBar(
          title: "إدارة القطع",
          scaffoldKey: _scaffoldKey,
          showBackButton: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: AppTheme.mainColor,
          icon: Icon(Icons.add,
              color: Colors.white, size: size.width * 0.055),
          label: Text("إضافة",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.038)),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                AdminHeader(
                  title: "إدارة القطع",
                  subtitle: "${_filteredItems.length} قطعة مسجلة",
                  icon: Icons.build_circle_outlined,
                ),
                AdminSearchBar(
                  controller: _searchController,
                  hint: "ابحث عن قطعة...",
                  onChanged: _applySmartFilter,
                ),
                AdminFilterBox(
                  dropdownItems: catDropdownItems,
                  selectedId:    _selectedCategoryId,
                  frozenFilter:  _frozenFilter,
                  onDropdownChanged: (v) {
                    setState(() => _selectedCategoryId = v);
                    _applySmartFilter();
                  },
                  onFrozenToggle: () {
                    setState(() => _frozenFilter =
                    (_frozenFilter == true) ? null : true);
                    _applySmartFilter();
                  },
                ),
                Expanded(child: _buildItemsList(size)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── list ────────────────────────────────────────────────────────────────────
  Widget _buildItemsList(Size size) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: AppTheme.mainColor));
    }
    if (_filteredItems.isEmpty) return const AdminEmptyState();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(size.width * 0.05,
          size.height * 0.015, size.width * 0.05, size.height * 0.12),
      itemCount:   _filteredItems.length,
      cacheExtent: size.height * 5,
      itemBuilder: (context, index) =>
          _buildItemCard(_filteredItems[index], size),
    );
  }

  // ─── card ────────────────────────────────────────────────────────────────────
  Widget _buildItemCard(_ItemViewModel vm, Size size) {
    final item     = vm.raw;
    final isFrozen = _isFrozen(item);
    final itemNoLabel =
    GeneralFunctions.ifMapOrNull(item["ItemNo"]).toString();

    return GestureDetector(
      onTap: () => _showItemOptions(item),
      child: Container(
        margin:  EdgeInsets.only(bottom: size.height * 0.015),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.04),
          border: Border.all(
            color: isFrozen
                ? Colors.blue.withOpacity(0.4)
                : AppTheme.darkBorderColor,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // icon
            Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: BoxDecoration(
                color: isFrozen
                    ? Colors.blue.withOpacity(0.1)
                    : AppTheme.mainColor.withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(size.width * 0.03),
              ),
              child: Icon(
                isFrozen
                    ? Icons.lock_outline
                    : Icons.build_outlined,
                color:
                isFrozen ? Colors.blue : AppTheme.mainColor,
                size: size.width * 0.055,
              ),
            ),
            SizedBox(width: size.width * 0.035),

            // text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (itemNoLabel.isNotEmpty) ...[
                        NoBadge(value: itemNoLabel),
                        SizedBox(width: size.width * 0.02),
                      ],
                      Expanded(
                        child: Text(vm.name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.038,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (isFrozen) ...[
                        SizedBox(width: size.width * 0.02),
                        const FreezeBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    GeneralFunctions.ifMapOrNull(item["EName"])
                        .toString(),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: size.width * 0.03),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    GeneralFunctions.ifMapOrNull(item["Descrip"])
                        .toString(),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: size.width * 0.028),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (vm.catLabel.isNotEmpty) ...[
                    SizedBox(height: size.height * 0.005),
                    Row(children: [
                      Icon(Icons.category_outlined,
                          color: AppTheme.mainColor.withOpacity(0.5),
                          size: size.width * 0.028),
                      SizedBox(width: size.width * 0.01),
                      Flexible(
                        child: Text(vm.catLabel,
                            style: TextStyle(
                                color:
                                AppTheme.mainColor.withOpacity(0.6),
                                fontSize: size.width * 0.025),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            Icon(Icons.more_vert,
                color: Colors.white.withOpacity(0.3),
                size: size.width * 0.05),
          ],
        ),
      ),
    );
  }

  // ─── dialogs ─────────────────────────────────────────────────────────────────
  void _showAddDialog() {
    final nameCtrl    = TextEditingController();
    final eNameCtrl   = TextEditingController();
    final descripCtrl = TextEditingController();
    final itemNoCtrl  =
    TextEditingController(text: _computeNextItemNo().toString());
    int? selectedCatId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AdminFormDialog(
          title:     "إضافة قطعة جديدة",
          icon:      Icons.add_circle_outline,
          iconColor: Colors.green,
          fields: [
            AdminDialogDropdown(
              selectedId: selectedCatId,
              items:      _categories,
              hint:       "اختر الفئة",
              hintIcon:   Icons.category_outlined,
              itemId:    (c) => c["ID"] as int? ?? 0,
              itemLabel: (c) =>
              "${GeneralFunctions.ifMapOrNull(c["CatNo"])} - "
                  "${GeneralFunctions.ifMapOrNull(c["Descrip"])}",
              onChanged: (id) =>
                  setDialogState(() => selectedCatId = id),
            ),
            AdminDialogField(
                controller: itemNoCtrl,
                label:      "رقم القطعة",
                icon:       Icons.tag,
                isNumber:   true),
            AdminDialogField(
                controller: nameCtrl,
                label:      "الاسم عربي",
                icon:       Icons.text_fields),
            AdminDialogField(
                controller: eNameCtrl,
                label:      "الاسم انجليزي",
                icon:       Icons.text_fields),
            AdminDialogField(
                controller: descripCtrl,
                label:      "الوصف",
                icon:       Icons.description),
          ],
          onConfirm: () async {
            if (nameCtrl.text.isEmpty ||
                eNameCtrl.text.isEmpty ||
                descripCtrl.text.isEmpty ||
                selectedCatId == null ||
                itemNoCtrl.text.isEmpty) {
              showAdminSnack(
                  context, "يرجى تعبئة جميع الحقول", Colors.red);
              return;
            }
            Navigator.pop(ctx);
            await SpItem.insert(
              context:    context,
              itemNo:     int.parse(itemNoCtrl.text.trim()),
              name:       nameCtrl.text.trim(),
              eName:      eNameCtrl.text.trim(),
              descrip:    descripCtrl.text.trim(),
              categoryId: selectedCatId!,
            );
            await _refreshAfterMutation();
            showAdminSnack(context, "تمت الإضافة بنجاح", Colors.green);
          },
        ),
      ),
    );
  }

  void _showEditDialog(dynamic item) {
    final itemNoCtrl  = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["ItemNo"]).toString());
    final nameCtrl    = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["Name"]).toString());
    final eNameCtrl   = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["EName"]).toString());
    final descripCtrl = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["Descrip"]).toString());
    int? selectedCatId = item["CategoryId"] as int?;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AdminFormDialog(
          title:     "تعديل القطعة",
          icon:      Icons.edit_outlined,
          iconColor: Colors.orange,
          fields: [
            AdminDialogField(
                controller: itemNoCtrl,
                label:      "رقم القطعة",
                icon:       Icons.tag,
                isNumber:   true),
            AdminDialogField(
                controller: nameCtrl,
                label:      "الاسم عربي",
                icon:       Icons.text_fields),
            AdminDialogField(
                controller: eNameCtrl,
                label:      "الاسم انجليزي",
                icon:       Icons.text_fields),
            AdminDialogField(
                controller: descripCtrl,
                label:      "الوصف",
                icon:       Icons.description),
            AdminDialogDropdown(
              selectedId: selectedCatId,
              items:      _categories,
              hint:       "اختر الفئة",
              hintIcon:   Icons.category_outlined,
              itemId:    (c) => c["ID"] as int? ?? 0,
              itemLabel: (c) =>
              "${GeneralFunctions.ifMapOrNull(c["CatNo"])} - "
                  "${GeneralFunctions.ifMapOrNull(c["Descrip"])}",
              onChanged: (id) =>
                  setDialogState(() => selectedCatId = id),
            ),
          ],
          onConfirm: () async {
            Navigator.pop(ctx);
            await SpItem.update(
              context:    context,
              id:         item["ID"],
              itemNo:     int.tryParse(itemNoCtrl.text.trim()),
              name:       nameCtrl.text.trim(),
              eName:      eNameCtrl.text.trim(),
              descrip:    descripCtrl.text.trim(),
              categoryId: selectedCatId,
            );
            await _refreshAfterMutation();
            showAdminSnack(context, "تم التعديل بنجاح", Colors.orange);
          },
        ),
      ),
    );
  }

  void _showItemOptions(dynamic item) {
    final bool isFrozen = _isFrozen(item);
    showAdminOptionsSheet(
      context:  context,
      title:    GeneralFunctions.ifMapOrNull(item["Name"]).toString(),
      subtitle: GeneralFunctions.ifMapOrNull(item["EName"]).toString(),
      options: [
        AdminBottomSheetOption(
          icon:  Icons.edit_outlined,
          label: "تعديل",
          color: Colors.orange,
          onTap: () {
            Navigator.pop(context);
            _showEditDialog(item);
          },
        ),
        AdminBottomSheetOption(
          icon:  isFrozen
              ? Icons.lock_open_outlined
              : Icons.lock_outline,
          label: isFrozen ? "إلغاء التجميد" : "تجميد",
          color: isFrozen ? Colors.green : Colors.blue,
          onTap: () async {
            Navigator.pop(context);
            if (isFrozen) {
              await SpItem.unfreeze(
                  context: context, id: item["ID"]);
              showAdminSnack(
                  context, "تم إلغاء التجميد", Colors.green);
            } else {
              await SpItem.freeze(
                  context: context, id: item["ID"]);
              showAdminSnack(context, "تم التجميد", Colors.blue);
            }
            await _refreshAfterMutation();
          },
        ),
        AdminBottomSheetOption(
          icon:  Icons.delete_outline,
          label: "حذف",
          color: Colors.red,
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (_) => AdminDeleteDialog(
                itemName: GeneralFunctions.ifMapOrNull(item["Name"])
                    .toString(),
                onConfirm: () async {
                  await SpItem.update(
                    context:      context,
                    deletionDate: DateTime.now(),
                    id:           item["ID"],
                  );
                  await _refreshAfterMutation();
                  showAdminSnack(
                      context, "تم الحذف بنجاح", Colors.red);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}