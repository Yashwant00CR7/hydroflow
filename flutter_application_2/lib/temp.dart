import 'package:flutter/material.dart';
import 'pinecone_upsert.dart';

class UpsertPdfPage extends StatelessWidget {
  const UpsertPdfPage({Key? key}) : super(key: key);

  Future<void> _runUpsert(BuildContext context) async {
    await upsertPdfToPinecone(); // Call your upsert function
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('PDF upsert process completed!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upsert PDF to Pinecone')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _runUpsert(context),
          child: Text('Upsert PDF'),
        ),
      ),
    );
  }
}
