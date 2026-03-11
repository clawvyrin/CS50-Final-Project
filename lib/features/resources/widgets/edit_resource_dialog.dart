import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/features/resources/models/resource_model.dart';
import 'package:task_companion/features/resources/services/resource_services.dart';

class EditResourceDialog extends ConsumerStatefulWidget {
  final Resource resource;
  const EditResourceDialog({super.key, required this.resource});

  @override
  ConsumerState<EditResourceDialog> createState() => _EditResourceDialogState();
}

class _EditResourceDialogState extends ConsumerState<EditResourceDialog> {
  double updatedQuantity = 0;
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.text = widget.resource.allocatedAmount.toString();
    updatedQuantity = widget.resource.allocatedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.resource.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: quantityController,
            decoration: InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (value) =>
                setState(() => updatedQuantity = double.tryParse(value) ?? 0),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: updatedQuantity <= widget.resource.allocatedAmount
              ? null
              : () async {
                  await ref
                      .read(resourceServiceProvider)
                      .updateResourceQuantity(
                        widget.resource.id,
                        updatedQuantity,
                      );

                  if (context.mounted) context.pop(true);
                },
          child: Text("Update quantity"),
        ),
      ],
    );
  }
}
