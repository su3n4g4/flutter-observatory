import 'package:flutter/material.dart';
import 'root_catalog_page.dart';

class ElementTreeLabApp extends StatelessWidget {
  const ElementTreeLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Element Tree Lab',
      theme: ThemeData(useMaterial3: true),
      home: const RootCatalogPage(),
    );
  }
}
