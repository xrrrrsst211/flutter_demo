import 'package:flutter/material.dart';

class SQLiteDemo extends StatelessWidget {
  const SQLiteDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sqlite'),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionButton(
              label: 'insert',
              onPressed: () {
                // insert action
              },
            ),
            const SizedBox(height: 16),
            _actionButton(
              label: 'query',
              onPressed: () {
                // query action
              },
            ),
            const SizedBox(height: 16),
            _actionButton(
              label: 'update',
              onPressed: () {
                // update action
              },
            ),
            const SizedBox(height: 16),
            _actionButton(
              label: 'delete',
              onPressed: () {
                // delete action
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 80,
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}