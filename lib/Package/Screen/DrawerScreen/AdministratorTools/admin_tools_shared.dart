import 'package:flutter/material.dart';
import 'package:seiiarty_package/Package/Core/app_theme.dart';
import '../../../Core/general_function.dart';

// ─── Shared view-model base ───────────────────────────────────────────────────
abstract class AdminViewModel {
  dynamic get raw;
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class AdminHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AdminHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.fromLTRB(
        size.width * 0.05, size.height * 0.025, size.width * 0.05, 0,
      ),
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size.width * 0.05),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mainColor.withOpacity(0.3),
            blurRadius: size.width * 0.05,
            offset: Offset(0, size.height * 0.012),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(size.width * 0.035),
            ),
            child: Icon(icon, color: Colors.white, size: size.width * 0.07),
          ),
          SizedBox(width: size.width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: size.width * 0.032,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────
class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.05, size.height * 0.02, size.width * 0.05, 0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.035),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          style:
          TextStyle(color: Colors.white, fontSize: size.width * 0.038),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: size.width * 0.038,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.4),
              size: size.width * 0.055,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close,
                  color: Colors.white.withOpacity(0.4),
                  size: size.width * 0.05),
              onPressed: () {
                controller.clear();
                onChanged();
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.018,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMART FILTER BOX  (dropdown + frozen toggle)
// ─────────────────────────────────────────────────────────────────────────────
class AdminFilterBox extends StatelessWidget {
  /// Items shown in the dropdown.
  final List<DropdownMenuItem<int?>> dropdownItems;
  final int?    selectedId;
  final bool?   frozenFilter;
  final void Function(int?) onDropdownChanged;
  final VoidCallback         onFrozenToggle;

  const AdminFilterBox({
    super.key,
    required this.dropdownItems,
    required this.selectedId,
    required this.frozenFilter,
    required this.onDropdownChanged,
    required this.onFrozenToggle,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.05, size.height * 0.012, size.width * 0.05, 0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.035,
          vertical:   size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.035),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: Row(
          children: [
            // ── Dropdown ───────────────────────────────────────────────────
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: selectedId,
                  dropdownColor: AppTheme.darkCardColor,
                  iconEnabledColor: Colors.white.withOpacity(0.5),
                  isExpanded: true,
                  items: dropdownItems,
                  onChanged: onDropdownChanged,
                ),
              ),
            ),

            // ── Divider ────────────────────────────────────────────────────
            Container(
              height: size.height * 0.038,
              width:  1,
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.025),
              color:  AppTheme.darkBorderColor,
            ),

            // ── Frozen toggle ──────────────────────────────────────────────
            GestureDetector(
              onTap: onFrozenToggle,
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width:  size.width * 0.05,
                    height: size.width * 0.05,
                    decoration: BoxDecoration(
                      color: frozenFilter == true
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius:
                      BorderRadius.circular(size.width * 0.012),
                      border: Border.all(
                        color: frozenFilter == true
                            ? Colors.blue
                            : Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: frozenFilter == true
                        ? Icon(Icons.check,
                        color: Colors.white,
                        size: size.width * 0.035)
                        : null,
                  ),
                  SizedBox(width: size.width * 0.015),
                  Text(
                    "مجمدة",
                    style: TextStyle(
                      color: frozenFilter == true
                          ? Colors.blue
                          : Colors.white.withOpacity(0.5),
                      fontSize: size.width * 0.032,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off,
              color: Colors.white.withOpacity(0.2),
              size: size.width * 0.16),
          SizedBox(height: size.height * 0.02),
          Text(
            "لا توجد نتائج",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: size.width * 0.04,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM DIALOG SHELL
// ─────────────────────────────────────────────────────────────────────────────
class AdminFormDialog extends StatelessWidget {
  final String        title;
  final IconData      icon;
  final Color         iconColor;
  final List<Widget>  fields;
  final VoidCallback  onConfirm;

  const AdminFormDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.fields,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: AppTheme.darkCardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05)),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.035),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle),
              child:
              Icon(icon, color: iconColor, size: size.width * 0.08),
            ),
            SizedBox(height: size.height * 0.018),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.025),
            ...fields,
            SizedBox(height: size.height * 0.03),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.darkBorderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(size.width * 0.03)),
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.018),
                    ),
                    child: Text("إلغاء",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.038)),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.mainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(size.width * 0.03)),
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.018),
                    ),
                    child: Text("تأكيد",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.038)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE CONFIRM DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class AdminDeleteDialog extends StatelessWidget {
  final String       itemName;
  final Future<void> Function() onConfirm;

  const AdminDeleteDialog({
    super.key,
    required this.itemName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: AppTheme.darkCardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05)),
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.delete_outline,
                  color: Colors.red, size: size.width * 0.09),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              "تأكيد الحذف",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              "هل أنت متأكد من حذف \"$itemName\"؟\nلا يمكن التراجع عن هذا الإجراء.",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: size.width * 0.035),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.03),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.darkBorderColor),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(size.width * 0.03)),
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.018),
                    ),
                    child: Text("إلغاء",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.038)),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(size.width * 0.03)),
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.018),
                    ),
                    child: Text("حذف",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.038)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class AdminDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String   label;
  final IconData icon;
  final bool     isNumber;

  const AdminDialogField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.03),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(
              color: Colors.white, fontSize: size.width * 0.038),
          keyboardType:
          isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: size.width * 0.035),
            prefixIcon: Icon(icon,
                color: Colors.white.withOpacity(0.4),
                size: size.width * 0.05),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical:   size.height * 0.018,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG DROPDOWN FIELD  (category / catType selector inside dialogs)
// ─────────────────────────────────────────────────────────────────────────────
class AdminDialogDropdown extends StatelessWidget {
  final int?               selectedId;
  final List<dynamic>      items;
  final String             hint;
  final IconData           hintIcon;

  /// Return the display string for one item.
  final String Function(dynamic item) itemLabel;

  /// Return the int ID for one item.
  final int Function(dynamic item) itemId;

  final void Function(int id) onChanged;

  const AdminDialogDropdown({
    super.key,
    required this.selectedId,
    required this.items,
    required this.hint,
    required this.hintIcon,
    required this.itemLabel,
    required this.itemId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.015),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size.width * 0.03),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        padding:
        EdgeInsets.symmetric(horizontal: size.width * 0.03),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: selectedId,
            dropdownColor: AppTheme.darkCardColor,
            iconEnabledColor: Colors.white.withOpacity(0.5),
            isExpanded: true,
            hint: Row(
              children: [
                Icon(hintIcon,
                    color: Colors.white.withOpacity(0.4),
                    size: size.width * 0.05),
                SizedBox(width: size.width * 0.02),
                Text(hint,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: size.width * 0.035)),
              ],
            ),
            items: items.map((item) {
              final id    = itemId(item);
              final label = itemLabel(item);
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(Icons.label_outline,
                        color: AppTheme.mainColor.withOpacity(0.7),
                        size: size.width * 0.045),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Text(label,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.032),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) onChanged(id);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM-SHEET OPTION ROW
// ─────────────────────────────────────────────────────────────────────────────
class AdminBottomSheetOption extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const AdminBottomSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(size.width * 0.035),
          border: Border.all(color: AppTheme.darkBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.02),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                BorderRadius.circular(size.width * 0.025),
              ),
              child: Icon(icon, color: color, size: size.width * 0.05),
            ),
            SizedBox(width: size.width * 0.035),
            Text(label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.038,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: size.width * 0.035),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SNACK HELPER  (free function — no widget needed)
// ─────────────────────────────────────────────────────────────────────────────
void showAdminSnack(BuildContext context, String message, Color color) {
  final Size size = MediaQuery.of(context).size;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message,
          style: TextStyle(
              color: Colors.white, fontSize: size.width * 0.035)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03)),
      margin: EdgeInsets.all(size.width * 0.04),
      duration: const Duration(seconds: 2),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FREEZE BADGE  (small inline chip shown on cards)
// ─────────────────────────────────────────────────────────────────────────────
class FreezeBadge extends StatelessWidget {
  const FreezeBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical:   size.height * 0.003,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size.width * 0.015),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        "مجمد",
        style: TextStyle(
            color: Colors.blue, fontSize: size.width * 0.025),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NO BADGE  (CatNo / ItemNo chip shown on cards)
// ─────────────────────────────────────────────────────────────────────────────
class NoBadge extends StatelessWidget {
  final String value;
  const NoBadge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.02,
        vertical:   size.height * 0.003,
      ),
      decoration: BoxDecoration(
        color: AppTheme.mainColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size.width * 0.015),
        border: Border.all(color: AppTheme.mainColor.withOpacity(0.35)),
      ),
      child: Text(
        "#$value",
        style: TextStyle(
          color: AppTheme.mainColor,
          fontSize: size.width * 0.027,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTIONS BOTTOM SHEET WRAPPER
// ─────────────────────────────────────────────────────────────────────────────
void showAdminOptionsSheet({
  required BuildContext context,
  required String       title,
  required String       subtitle,
  required List<Widget> options,
}) {
  final Size size = MediaQuery.of(context).size;
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.darkCardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(size.width * 0.06)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.symmetric(
        vertical:   size.height * 0.03,
        horizontal: size.width * 0.05,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width:  size.width * 0.1,
            height: size.height * 0.005,
            decoration: BoxDecoration(
              color: AppTheme.darkBorderColor,
              borderRadius:
              BorderRadius.circular(size.width * 0.01),
            ),
          ),
          SizedBox(height: size.height * 0.025),
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: size.width * 0.032)),
          SizedBox(height: size.height * 0.03),
          ...options.map((w) => Padding(
            padding:
            EdgeInsets.only(bottom: size.height * 0.015),
            child: w,
          )),
          SizedBox(height: size.height * 0.01),
        ],
      ),
    ),
  );
}