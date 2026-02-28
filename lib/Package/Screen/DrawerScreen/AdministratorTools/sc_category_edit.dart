import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import 'package:seiiarty_package/Package/Widget/my_appbar.dart';
import '../../../Core/StoredProcedures/item.dart';
import '../../../Core/api_access.dart';
import '../../../Core/general_function.dart';
import '../../../Core/shared_preference.dart';
import '../../../Widget/my_drawer.dart';
import 'admin_tools_shared.dart';

// ─── View-model ───────────────────────────────────────────────────────────────
class _CategoryViewModel implements AdminViewModel {
  @override
  final dynamic raw;
  final String  descrip;
  final String  catNo;
  final String  typeNo;
  final String  typeLabel;

  const _CategoryViewModel({
    required this.raw,
    required this.descrip,
    required this.catNo,
    required this.typeNo,
    required this.typeLabel,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({super.key});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController           _animationController;
  late Animation<double>             _fadeAnimation;

  List<dynamic>              _categories         = [];
  List<dynamic>              _catTypes           = [];
  Map<int, dynamic>          _catTypeMap         = {};
  List<_CategoryViewModel>   _filteredCategories = [];
  bool                       _isLoading          = true;

  final TextEditingController _searchController = TextEditingController();
  int?  _selectedCatTypeId;
  bool? _frozenFilter;

  // ─── helpers ────────────────────────────────────────────────────────────────
  bool _isFrozen(dynamic cat)  => cat["Freeze"] == true;
  bool _isDeleted(dynamic cat) =>
      GeneralFunctions.ifMapOrNull(cat["DeletionDate"]) != "";

  int _computeNextCatNo(int catTypeId) {
    final existing = <int>[];
    for (final cat in _categories) {
      if (cat["CatTypeId"] == catTypeId) {
        final no = int.tryParse(
            GeneralFunctions.ifMapOrNull(cat["CatNo"]).toString());
        if (no != null) existing.add(no);
      }
    }
    if (existing.isEmpty) {
      final candidate = int.parse("${catTypeId}01");
      return candidate.toString().length < 3
          ? int.parse("${catTypeId}01".padLeft(3, '0'))
          : candidate;
    }
    return existing.reduce((a, b) => a > b ? a : b) + 1;
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
    await _loadCatTypes();
    await _loadCategories();
  }

  Future<void> _loadCatTypes() async {
    final cached = await SharedPreference.sharedPreferencesGetListDynamic(
        SharedPreference.catTypes);
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _catTypes   = cached;
        _catTypeMap = {for (final t in cached) t["ID"] as int: t};
      });
    }
    final result = await ApiAccess.execCmd(
        RequestCmd("SELECT * FROM [CatType]"),
        context: context,
        viewLoadingProcess: false);
    if (result == null) return;
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.catTypes, list);
    if (mounted) {
      setState(() {
        _catTypes   = list;
        _catTypeMap = {for (final t in list) t["ID"] as int: t};
      });
    }
  }

  Future<void> _loadCategories() async {
    if (mounted) setState(() => _isLoading = true);
    final cached = await SharedPreference.sharedPreferencesGetListDynamic(
        SharedPreference.categories);
    if (cached.isNotEmpty && mounted) {
      setState(() {
        _categories = cached;
        _isLoading  = false;
      });
      _applySmartFilter();
    }
    final result = await SpCategory.get(
        context: context, viewLoadingProcess: false);
    if (result == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.categories, list);
    if (mounted) {
      setState(() {
        _categories = list;
        _isLoading  = false;
      });
      _applySmartFilter();
    }
  }

  Future<void> _refreshAfterMutation() async {
    final result = await SpCategory.get(
        context: context, viewLoadingProcess: false);
    if (result == null) return;
    final list = List<dynamic>.from(result);
    await SharedPreference.sharedPreferencesSetListDynamic(
        SharedPreference.categories, list);
    if (mounted) {
      _categories = list;
      _applySmartFilter();
    }
  }

  // ─── filter ──────────────────────────────────────────────────────────────────
  void _applySmartFilter() {
    final query = _searchController.text.toLowerCase();
    final List<_CategoryViewModel> staging = [];

    for (final cat in _categories) {
      if (_isDeleted(cat)) continue;
      final bool frozen = _isFrozen(cat);
      if (_frozenFilter == true && !frozen) continue;
      if (_frozenFilter != true && frozen) continue;
      final int? typeId = cat["CatTypeId"] as int?;
      if (_selectedCatTypeId != null && typeId != _selectedCatTypeId)
        continue;
      final String descrip =
      GeneralFunctions.ifMapOrNull(cat["Descrip"]).toString();
      final String catNo =
      GeneralFunctions.ifMapOrNull(cat["CatNo"]).toString();
      if (query.isNotEmpty &&
          !descrip.toLowerCase().contains(query) &&
          !catNo.contains(query)) continue;

      final typeEntry   = typeId != null ? _catTypeMap[typeId] : null;
      final typeNo      = typeEntry != null
          ? GeneralFunctions.ifMapOrNull(typeEntry["ID"]).toString()
          : "";
      final typeDescrip = typeEntry != null
          ? GeneralFunctions.ifMapOrNull(typeEntry["Descrip"]).toString()
          : "";

      staging.add(_CategoryViewModel(
        raw:       cat,
        descrip:   descrip,
        catNo:     catNo,
        typeNo:    typeNo,
        typeLabel: typeEntry != null ? "$typeNo - $typeDescrip" : "",
      ));
    }

    staging.sort((a, b) {
      final c = a.typeNo.compareTo(b.typeNo);
      return c != 0 ? c : a.catNo.compareTo(b.catNo);
    });

    setState(() => _filteredCategories = staging);
  }

  // ─── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final List<DropdownMenuItem<int?>> typeDropdownItems = [
      DropdownMenuItem<int?>(
        value: null,
        child: Row(children: [
          Icon(Icons.all_inclusive,
              color: Colors.white.withOpacity(0.5),
              size: size.width * 0.045),
          SizedBox(width: size.width * 0.02),
          Text("كل الأنواع",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: size.width * 0.032)),
        ]),
      ),
      ..._catTypes.map((type) {
        final id      = type["ID"] as int? ?? 0;
        final descrip =
        GeneralFunctions.ifMapOrNull(type["Descrip"]).toString();
        return DropdownMenuItem<int?>(
          value: id,
          child: Row(children: [
            Icon(Icons.label_outline,
                color: AppTheme.mainColor.withOpacity(0.7),
                size: size.width * 0.045),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Text("$id - $descrip",
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
          title: "إدارة الفئات",
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
                  title:    "إدارة الفئات",
                  subtitle: "${_filteredCategories.length} فئة مسجلة",
                  icon:     Icons.category_outlined,
                ),
                AdminSearchBar(
                  controller: _searchController,
                  hint:       "ابحث عن فئة...",
                  onChanged:  _applySmartFilter,
                ),
                AdminFilterBox(
                  dropdownItems: typeDropdownItems,
                  selectedId:    _selectedCatTypeId,
                  frozenFilter:  _frozenFilter,
                  onDropdownChanged: (v) {
                    setState(() => _selectedCatTypeId = v);
                    _applySmartFilter();
                  },
                  onFrozenToggle: () {
                    setState(() => _frozenFilter =
                    (_frozenFilter == true) ? null : true);
                    _applySmartFilter();
                  },
                ),
                Expanded(child: _buildCategoryList(size)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── list ────────────────────────────────────────────────────────────────────
  Widget _buildCategoryList(Size size) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: AppTheme.mainColor));
    }
    if (_filteredCategories.isEmpty) return const AdminEmptyState();

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(size.width * 0.05,
          size.height * 0.015, size.width * 0.05, size.height * 0.12),
      itemCount:   _filteredCategories.length,
      cacheExtent: size.height * 5,
      itemBuilder: (context, index) =>
          _buildCategoryCard(_filteredCategories[index], size),
    );
  }

  // ─── card ────────────────────────────────────────────────────────────────────
  Widget _buildCategoryCard(_CategoryViewModel vm, Size size) {
    final item     = vm.raw;
    final isFrozen = _isFrozen(item);

    return GestureDetector(
      onTap: () => _showCategoryOptions(item),
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
                    : Icons.category_outlined,
                color: isFrozen ? Colors.blue : AppTheme.mainColor,
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
                      NoBadge(value: vm.catNo),
                      SizedBox(width: size.width * 0.02),
                      Expanded(
                        child: Text(vm.descrip,
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
                  if (vm.typeLabel.isNotEmpty) ...[
                    SizedBox(height: size.height * 0.006),
                    Row(children: [
                      Icon(Icons.layers_outlined,
                          color: AppTheme.mainColor.withOpacity(0.5),
                          size: size.width * 0.028),
                      SizedBox(width: size.width * 0.01),
                      Flexible(
                        child: Text(vm.typeLabel,
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
    final descripCtrl = TextEditingController();
    final catNoCtrl   = TextEditingController();
    int?  selectedTypeId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AdminFormDialog(
          title:     "إضافة فئة جديدة",
          icon:      Icons.add_circle_outline,
          iconColor: Colors.green,
          fields: [
            AdminDialogDropdown(
              selectedId: selectedTypeId,
              items:      _catTypes,
              hint:       "اختر النوع",
              hintIcon:   Icons.layers_outlined,
              itemId:    (t) => t["ID"] as int? ?? 0,
              itemLabel: (t) =>
              "${t["ID"]} - "
                  "${GeneralFunctions.ifMapOrNull(t["Descrip"])}",
              onChanged: (id) {
                final nextNo = _computeNextCatNo(id);
                setDialogState(() {
                  selectedTypeId = id;
                  catNoCtrl.text = nextNo.toString();
                });
              },
            ),
            AdminDialogField(
                controller: catNoCtrl,
                label:      "رقم الفئة",
                icon:       Icons.tag,
                isNumber:   true),
            AdminDialogField(
                controller: descripCtrl,
                label:      "الوصف",
                icon:       Icons.description),
          ],
          onConfirm: () async {
            if (descripCtrl.text.isEmpty ||
                selectedTypeId == null    ||
                catNoCtrl.text.isEmpty) {
              showAdminSnack(
                  context, "يرجى تعبئة جميع الحقول", Colors.red);
              return;
            }
            Navigator.pop(ctx);
            await SpCategory.insert(
              context:   context,
              catNo:     int.parse(catNoCtrl.text.trim()),
              descrip:   descripCtrl.text.trim(),
              catTypeId: selectedTypeId!,
            );
            await _refreshAfterMutation();
            showAdminSnack(context, "تمت الإضافة بنجاح", Colors.green);
          },
        ),
      ),
    );
  }

  void _showEditDialog(dynamic item) {
    final descripCtrl = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["Descrip"]).toString());
    final catNoCtrl   = TextEditingController(
        text: GeneralFunctions.ifMapOrNull(item["CatNo"]).toString());
    int? selectedTypeId = item["CatTypeId"] as int?;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AdminFormDialog(
          title:     "تعديل الفئة",
          icon:      Icons.edit_outlined,
          iconColor: Colors.orange,
          fields: [
            AdminDialogField(
                controller: catNoCtrl,
                label:      "رقم الفئة",
                icon:       Icons.tag,
                isNumber:   true),
            AdminDialogField(
                controller: descripCtrl,
                label:      "الوصف",
                icon:       Icons.description),
            AdminDialogDropdown(
              selectedId: selectedTypeId,
              items:      _catTypes,
              hint:       "اختر النوع",
              hintIcon:   Icons.layers_outlined,
              itemId:    (t) => t["ID"] as int? ?? 0,
              itemLabel: (t) =>
              "${t["ID"]} - "
                  "${GeneralFunctions.ifMapOrNull(t["Descrip"])}",
              onChanged: (id) =>
                  setDialogState(() => selectedTypeId = id),
            ),
          ],
          onConfirm: () async {
            Navigator.pop(ctx);
            await SpCategory.update(
              context:   context,
              id:        item["ID"],
              catNo:     int.tryParse(catNoCtrl.text.trim()),
              descrip:   descripCtrl.text.trim(),
              catTypeId: selectedTypeId,
            );
            await _refreshAfterMutation();
            showAdminSnack(
                context, "تم التعديل بنجاح", Colors.orange);
          },
        ),
      ),
    );
  }

  void _showCategoryOptions(dynamic item) {
    final bool isFrozen = _isFrozen(item);
    showAdminOptionsSheet(
      context:  context,
      title:    GeneralFunctions.ifMapOrNull(item["Descrip"]).toString(),
      subtitle: "#${GeneralFunctions.ifMapOrNull(item["CatNo"])}",
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
            await SpCategory.update(
              context: context,
              id:      item["ID"],
              freeze:  !isFrozen,
            );
            await _refreshAfterMutation();
            showAdminSnack(
              context,
              isFrozen ? "تم إلغاء التجميد" : "تم التجميد",
              isFrozen ? Colors.green : Colors.blue,
            );
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
                itemName: GeneralFunctions.ifMapOrNull(item["Descrip"])
                    .toString(),
                onConfirm: () async {
                  await SpCategory.softDelete(
                      context: context, id: item["ID"]);
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