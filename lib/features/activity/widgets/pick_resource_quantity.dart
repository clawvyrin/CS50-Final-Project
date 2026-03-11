import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:task_companion/core/log/logger.dart';

class PickResourceQuantity extends StatelessWidget {
  final Map<String, dynamic> resource;
  const PickResourceQuantity({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    double quantity = 0;
    return StatefulBuilder(
      builder: (context, setSubState) {
        return AlertDialog(
          title: Text("Amount to allocate"),
          content: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(labelText: "Amount"),
            onChanged: (val) {
              if (resource['amount'] >= double.parse(val)) {
                setSubState(() => quantity = double.parse(val));
                appLogger.i("changed val id $quantity");
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(null),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (resource['amount'] >= quantity) {
                  appLogger.i("popping with quantity $quantity");
                  context.pop(quantity);
                }
              },
              child: Text("Allocate"),
            ),
          ],
        );
      },
    );
  }
}
