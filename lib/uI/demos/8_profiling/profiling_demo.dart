import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilingDemo extends StatefulWidget {
  const ProfilingDemo({super.key});

  @override
  State<ProfilingDemo> createState() => _ProfilingDemoState();
}

class _ProfilingDemoState extends State<ProfilingDemo> {
  final List<String> _heavyList = [];
  String _networkResponse = 'No request made yet.';

  void _causeJank() {
    developer.log('Starting heavy computation...', name: 'DemoApp');

    developer.Timeline.timeSync('FibonacciComputation', () {
      int fibonacci(int n) {
        if (n <= 1) return n;
        return fibonacci(n - 1) + fibonacci(n - 2);
      }

      final result = fibonacci(42);
      debugPrint('Result: $result');
    });

    developer.log('Heavy computation finished.', name: 'DemoApp');
  }

  void _allocateMemory() {
    setState(() {
      for (int i = 0; i < 500000; i++) {
        _heavyList.add(
          'This is a relatively long string designed to take up heap memory. ID: $i',
        );
      }
    });
    developer.log('Allocated 500,000 strings.', name: 'DemoApp');
  }

  void _clearMemory() {
    setState(_heavyList.clear);
    developer.log('Memory cleared.', name: 'DemoApp');
  }

  Future<void> _makeNetworkRequest() async {
    setState(() => _networkResponse = 'Fetching...');

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _networkResponse = 'Success! Loaded post: ${body['title']}';
      });
    } catch (e) {
      setState(() => _networkResponse = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter DevTools Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            _buildSectionHeader('1. Flutter Inspector'),
            const Text(
              'Use the Select Widget tool to inspect the row below. Change its color directly from DevTools.',
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.grey,
              padding: const EdgeInsets.all(8),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This row is intentionally wide, but fixed with Expanded so it no longer crashes the layout.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            _buildSectionHeader('2. Performance / CPU Profiler'),
            const Text(
              'Click this button to run a heavy synchronous task. The UI will freeze briefly and show up in DevTools.',
            ),
            ElevatedButton(
              onPressed: _causeJank,
              child: const Text('Cause UI Jank (Calculate Fib(42))'),
            ),
            const Divider(height: 40),
            _buildSectionHeader('3. Memory'),
            const Text(
              'Watch the memory graph spike. You can take a snapshot, clear memory, and force GC in DevTools.',
            ),
            Text(
              'Current List Size: ${_heavyList.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _allocateMemory,
                    child: const Text('Allocate Memory'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearMemory,
                    child: const Text('Clear Memory'),
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            _buildSectionHeader('4. Network & Logging'),
            const Text(
              'Click to make an HTTP request. Inspect the response in the Network tab.',
            ),
            ElevatedButton(
              onPressed: _makeNetworkRequest,
              child: const Text('Make HTTP Request'),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: $_networkResponse',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
