import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:trackerapp/app/theme/app_colors.dart';
import 'package:trackerapp/app/theme/app_styles.dart';
import 'package:trackerapp/data/models/device_expense_model.dart';
import 'package:trackerapp/data/repositories/device_expense_repository.dart';
import 'package:trackerapp/providers/device_expense_provider.dart';
import 'package:trackerapp/utils/app_snackbar.dart';
import 'package:trackerapp/widgets/custom_button.dart';
import 'package:trackerapp/widgets/get_horizontal_space.dart';
import 'package:trackerapp/widgets/get_vertical_space.dart';
import 'package:trackerapp/widgets/maintenance_widgets/maintenance_field.dart';

Future<ExpenseFormData?> showExpenseFormDialog(
  BuildContext context, {
  required int deviceId,
  DeviceExpense? initialExpense,
}) async {
  final repository = DeviceExpenseRepository();
  List<DeviceExpenseType> types = <DeviceExpenseType>[];
  try {
    types = await repository.getExpenseTypes();
  } catch (e) {
    if (context.mounted) {
      AppSnackBar.error(message: e.toString());
    }
    return null;
  }

  if (types.isEmpty) {
    if (context.mounted) {
      AppSnackBar.error(message: "Expense types are not available");
    }
    return null;
  }

  if (!context.mounted) return null;
  return showDialog<ExpenseFormData>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.white,
      child: _AddExpenseSheet(
        types: types,
        initialExpense: initialExpense,
      ),
    ),
  );
}

class SingleVehicleExpenseScreen extends StatelessWidget {
  final int deviceId;
  final String vehicleName;

  const SingleVehicleExpenseScreen({
    super.key,
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeviceExpenseProvider()..initialize(deviceId: deviceId),
      child: _SingleVehicleExpenseBody(
        deviceId: deviceId,
        vehicleName: vehicleName,
      ),
    );
  }
}

class _SingleVehicleExpenseBody extends StatelessWidget {
  final int deviceId;
  final String vehicleName;

  const _SingleVehicleExpenseBody({
    required this.deviceId,
    required this.vehicleName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<DeviceExpenseProvider>();
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "$vehicleName Expenses",
          style: AppStyles.semiboldTextStyle(context),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isSubmitting
            ? null
            : () => _showAddExpenseSheet(context, provider),
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(deviceId: deviceId),
        child: ListView(
          padding: EdgeInsets.fromLTRB(4.w, 1.5.h, 4.w, 12.h),
          children: [
            _TotalCard(total: provider.total),
            verticalSpace(height: 1.2.h),
            _DateFilterCard(
              fromDate: provider.fromDate,
              toDate: provider.toDate,
              onSelectFrom: () async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final toBound = provider.toDate == null
                    ? today
                    : DateTime(provider.toDate!.year, provider.toDate!.month,
                        provider.toDate!.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: provider.fromDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: toBound.isBefore(today) ? toBound : today,
                );
                if (picked == null) return;
                await provider.setDateRange(
                  deviceId: deviceId,
                  from: picked,
                  to: provider.toDate,
                );
              },
              onSelectTo: () async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final fromBound = provider.fromDate == null
                    ? DateTime(2020)
                    : DateTime(provider.fromDate!.year, provider.fromDate!.month,
                        provider.fromDate!.day);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: provider.toDate ?? DateTime.now(),
                  firstDate: fromBound,
                  lastDate: today,
                );
                if (picked == null) return;
                await provider.setDateRange(
                  deviceId: deviceId,
                  from: provider.fromDate,
                  to: picked,
                );
              },
              onClear: () => provider.setDateRange(
                deviceId: deviceId,
                from: null,
                to: null,
              ),
            ),
            verticalSpace(height: 1.2.h),
            if (provider.isLoading)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (provider.expenses.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Center(
                  child: Text(
                    "No expenses recorded",
                    style: AppStyles.regularTextStyle(context).copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              )
            else
              ...provider.expenses.map(
                (expense) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: _ExpenseTile(
                    expense: expense,
                    fallbackTitle: provider.typeName(expense.typeId),
                    onEdit: provider.isSubmitting
                        ? null
                        : () => _showEditExpenseSheet(
                              context,
                              provider,
                              expense,
                            ),
                    onDelete: provider.isSubmitting
                        ? null
                        : () => _confirmDelete(
                              context: context,
                              onConfirm: () => provider.deleteExpense(
                                deviceId: deviceId,
                                expenseId: expense.id,
                              ),
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExpenseSheet(
    BuildContext context,
    DeviceExpenseProvider provider,
  ) async {
    final result = await showExpenseFormDialog(
      context,
      deviceId: deviceId,
    );

    if (result == null) return;
    await provider.addExpense(
      deviceId: deviceId,
      typeId: result.typeId,
      date: result.date,
      quantity: result.quantity,
      unitCost: result.unitCost,
      name: result.name,
      supplier: result.supplier,
      comment: result.comment,
    );
  }

  Future<void> _confirmDelete({
    required BuildContext context,
    required Future<void> Function() onConfirm,
  }) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure you want to delete this expense?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (proceed == true) {
      await onConfirm();
    }
  }

  Future<void> _showEditExpenseSheet(
    BuildContext context,
    DeviceExpenseProvider provider,
    DeviceExpense expense,
  ) async {
    final result = await showExpenseFormDialog(
      context,
      deviceId: deviceId,
      initialExpense: expense,
    );

    if (result == null) return;
    await provider.editExpense(
      deviceId: deviceId,
      expenseId: expense.id,
      typeId: result.typeId,
      date: result.date,
      quantity: result.quantity,
      unitCost: result.unitCost,
      name: result.name,
      supplier: result.supplier,
      comment: result.comment,
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Expense",
            style: AppStyles.semiboldTextStyle(context).copyWith(
              fontSize: 14.sp,
            ),
          ),
          Text(
            "Rs ${total.toStringAsFixed(2)}",
            style: AppStyles.boldTextStyle(context).copyWith(
              fontSize: 15.sp,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterCard extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onSelectFrom;
  final VoidCallback onSelectTo;
  final VoidCallback onClear;

  const _DateFilterCard({
    required this.fromDate,
    required this.toDate,
    required this.onSelectFrom,
    required this.onSelectTo,
    required this.onClear,
  });

  String _label(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("dd MMM yyyy").format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSelectFrom,
              child: Text(
                "From: ${_label(fromDate)}",
                style: AppStyles.regularTextStyle(context),
              ),
            ),
          ),
          horizontalSpace(width: 3.w),
          Expanded(
            child: InkWell(
              onTap: onSelectTo,
              child: Text(
                "To: ${_label(toDate)}",
                style: AppStyles.regularTextStyle(context),
              ),
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            tooltip: "Clear filter",
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final DeviceExpense expense;
  final String fallbackTitle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.fallbackTitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final dateLabel = expense.date == null
        ? "-"
        : DateFormat("dd MMM yyyy").format(expense.date!);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: .06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.typeName.isNotEmpty
                      ? expense.typeName
                      : fallbackTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.semiboldTextStyle(context).copyWith(
                    fontSize: 13.8.sp,
                    color: onSurface,
                  ),
                ),
                if (expense.name.isNotEmpty) ...[
                  verticalSpace(height: .25.h),
                  Text(
                    "Name: ${expense.name}",
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.8.sp,
                      color: onSurface.withValues(alpha: .75),
                    ),
                  ),
                ],
                verticalSpace(height: .3.h),
                Text(
                  "$dateLabel  |  Qty: ${expense.quantity}  |  Unit: Rs ${expense.unitCost.toStringAsFixed(2)}",
                  style: AppStyles.regularTextStyle(context).copyWith(
                    fontSize: 11.5.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (expense.supplier.isNotEmpty) ...[
                  verticalSpace(height: .3.h),
                  Text(
                    "Supplier: ${expense.supplier}",
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
                if (expense.comment.isNotEmpty) ...[
                  verticalSpace(height: .3.h),
                  Text(
                    expense.comment,
                    style: AppStyles.regularTextStyle(context).copyWith(
                      fontSize: 11.5.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          horizontalSpace(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Rs ${expense.totalCost.toStringAsFixed(2)}",
                style: AppStyles.semiboldTextStyle(context).copyWith(
                  color: AppColors.green,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(1.2.w),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 16.5.sp,
                        color: AppColors.blueCyan,
                      ),
                    ),
                  ),
                  horizontalSpace(width: .8.w),
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(1.2.w),
                      child: Icon(
                        Icons.delete_rounded,
                        size: 16.8.sp,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ExpenseFormData {
  final int typeId;
  final DateTime date;
  final double quantity;
  final double unitCost;
  final String? name;
  final String? supplier;
  final String? comment;

  const ExpenseFormData({
    required this.typeId,
    required this.date,
    required this.quantity,
    required this.unitCost,
    this.name,
    this.supplier,
    this.comment,
  });
}

class _AddExpenseSheet extends StatefulWidget {
  final List<DeviceExpenseType> types;
  final DeviceExpense? initialExpense;

  const _AddExpenseSheet({
    required this.types,
    this.initialExpense,
  });

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController(text: "1");
  final _unitCostCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();

  int? _typeId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialExpense;
    if (initial != null) {
      _typeId = initial.typeId;
      _date = initial.date ?? DateTime.now();
      _quantityCtrl.text = initial.quantity.toString();
      _unitCostCtrl.text = initial.unitCost.toString();
      _nameCtrl.text = initial.name;
      _supplierCtrl.text = initial.supplier;
      _commentCtrl.text = initial.comment;
    }
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _unitCostCtrl.dispose();
    _nameCtrl.dispose();
    _supplierCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final compactFieldHeight = 4.4.h;
    final compactTitleSize = 13.6.sp;
    final compactInputSize = 13.2.sp;

    return Padding(
      padding: EdgeInsets.only(
        left: 4.2.w,
        right: 4.2.w,
        top: 1.8.h,
        bottom: viewInsets.bottom + 2.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 4.8.h,
                child: Stack(
                  children: [
                    Positioned(
                      top: -.6.h,
                      right: -1.w,
                      child: Icon(
                        Icons.attach_money_rounded,
                        color: AppColors.green
                            .withValues(alpha: isDark ? 0.22 : 0.16),
                        size: 6.2.h,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        widget.initialExpense == null
                            ? "Add Expense"
                            : "Edit Expense",
                        style: AppStyles.boldTextStyle(context).copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpace(height: .4.h),
              Text(
                "Type",
                style: TextStyle(
                  fontSize: compactTitleSize,
                  fontWeight: FontWeight.w500,
                  color: onSurface,
                ),
              ),
              verticalSpace(height: .65.h),
              SizedBox(
                height: compactFieldHeight,
                child: DropdownButtonFormField<int>(
                  isDense: true,
                  initialValue: _typeId,
                  style: TextStyle(
                    fontSize: compactInputSize,
                    color: onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  hint: Text(
                    "Select expense type",
                    style: TextStyle(
                      fontSize: compactInputSize,
                      color: onSurface.withValues(alpha: .58),
                    ),
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: .7.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: widget.types
                      .map(
                        (type) => DropdownMenuItem<int>(
                          value: type.id,
                          child: Text(
                            type.name.trim().isEmpty
                                ? "Type #${type.id}"
                                : type.name,
                            style: TextStyle(
                              fontSize: compactInputSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _typeId = value),
                  validator: (value) =>
                      value == null ? "Select expense type" : null,
                ),
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _nameCtrl,
                title: "Name",
                hint: "Expense name",
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              TextFormField(
                controller: _quantityCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Quantity"),
                validator: (value) {
                  final n = double.tryParse(value ?? "");
                  if (n == null || n <= 0) return "Enter valid quantity";
                  return null;
                },
              ),
              verticalSpace(height: 1.0.h),
              TextFormField(
                controller: _unitCostCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Unit cost"),
                validator: (value) {
                  final n = double.tryParse(value ?? "");
                  if (n == null || n <= 0) return "Enter valid unit cost";
                  return null;
                },
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                title: "Date",
                hint: DateFormat("dd MMM yyyy").format(_date),
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _supplierCtrl,
                title: "Supplier",
                hint: "Optional supplier",
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.0.h),
              MaintenanceField(
                controller: _commentCtrl,
                title: "Description",
                hint: "Optional notes",
                height: compactFieldHeight,
                titleFontSize: compactTitleSize,
                fieldFontSize: compactInputSize,
                hintFontSize: compactInputSize,
                titleBottomSpacing: .65.h,
                inputVerticalPadding: 1.0.h,
              ),
              verticalSpace(height: 1.5.h),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Cancel",
                      backgroundColor: Colors.transparent,
                      textColor: onSurface.withValues(alpha: .82),
                      height: 4.4.h,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  horizontalSpace(width: 3.w),
                  Expanded(
                    child: CustomButton(
                      text: widget.initialExpense == null ? "Save" : "Update",
                      height: 4.4.h,
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.pop(
                          context,
                          ExpenseFormData(
                            typeId: _typeId!,
                            date: _date,
                            quantity: double.parse(_quantityCtrl.text.trim()),
                            unitCost: double.parse(_unitCostCtrl.text.trim()),
                            name: _nameCtrl.text.trim().isEmpty
                                ? null
                                : _nameCtrl.text.trim(),
                            supplier: _supplierCtrl.text.trim().isEmpty
                                ? null
                                : _supplierCtrl.text.trim(),
                            comment: _commentCtrl.text.trim().isEmpty
                                ? null
                                : _commentCtrl.text.trim(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
