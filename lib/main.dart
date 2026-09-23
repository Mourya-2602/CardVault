import 'package:flutter/material.dart';

void main() {
  runApp(const CardVaultApp());
}

class CardVaultApp extends StatelessWidget {
  const CardVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CardVaultHomePage(),
    );
  }
}

class CardVaultHomePage extends StatelessWidget {
  const CardVaultHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CardVault')),
      body: Center(
        child: Text(
          'Project setup complete',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
