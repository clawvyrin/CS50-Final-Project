import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AddResourceDialog extends StatelessWidget {
  const AddResourceDialog({super.key});

  TextField textField(
    TextEditingController controller,
    String labelText,
    bool isNumber,
    Function(void Function()) setDialogState,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      textCapitalization: isNumber
          ? TextCapitalization.none
          : TextCapitalization.sentences,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
          : [],

      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.name,

      onChanged: (value) {
        controller.text = value.trim();
        setDialogState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedType = 'Equipment';
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final unitController = TextEditingController();

    return StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text("Add a resource"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedType,
                isExpanded: true,
                items: ['Materials', 'Workforce', 'Equipment', 'Tools', 'Other']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name (i.e: Cement)",
                ),
                textCapitalization: TextCapitalization.sentences,
                onChanged: (v) =>
                    setDialogState(() => nameController.text = v.trim()),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Allocated quantity",
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) =>
                    setDialogState(() => amountController.text = v.trim()),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: "Resource unity"),
                keyboardType: TextInputType.name,
                onChanged: (v) =>
                    setDialogState(() => unitController.text = v.trim()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(null),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed:
                nameController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    unitController.text.isEmpty
                ? null
                : () {
                    final qty =
                        double.tryParse(amountController.text.trim()) ?? 0.0;
                    context.pop({
                      "name": nameController.text.trim(),
                      "type": selectedType,
                      "allocated_amount": qty,
                      "unit": unitController.text.trim(),
                    });
                  },
            child: const Text("Add resource"),
          ),
        ],
      ),
    );
  }
}
