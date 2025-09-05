import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Minus Button
              IconButton(
                icon: const Icon(Icons.remove, size: 16, color: Colors.grey),
                onPressed: () {},
              ),
              // Quantity
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "1",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              // Plus Button
              IconButton(
                icon: const Icon(Icons.add, size: 16, color: Colors.amber),
                onPressed: () {},
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Price
        const Text(
          "₹4.99",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E0E11), // Close to black
          ),
        ),
      ],
    ).toHorizontalPadding(
      horizontalPadding: 16
    );
  }
}
