import 'pinecone_grok_service.dart';
import 'dart:async';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'dart:io';

/// Utility to upsert a batch of text chunks into Pinecone
class PineconeBatchUpserter {
  final PineconeGrokService _service = PineconeGrokService();

  /// Upsert a list of text chunks with optional metadata
  /// [chunks] - List of text strings to embed and upsert
  /// [embedder] - Function to embed text (returns List<double>)
  /// [metadataBuilder] - Optional function to build metadata for each chunk
  Future<void> upsertChunks({
    required List<String> chunks,
    required Future<List<double>> Function(String) embedder,
    Map<String, dynamic> Function(int, String)? metadataBuilder,
  }) async {
    for (int i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      final id = 'chunk_$i';
      final embedding = await embedder(chunk);
      final metadata =
          metadataBuilder != null ? metadataBuilder(i, chunk) : {'text': chunk};
      final success = await _service.upsertToPinecone(
        id: id,
        embedding: embedding,
        metadata: metadata,
      );
      if (success) {
        print('✅ Upserted chunk $i');
      } else {
        print('❌ Failed to upsert chunk $i');
      }
    }
  }
}

/// Extract text from a PDF file using read_pdf_text
Future<String> extractPdfText(String path) async {
  try {
    return await ReadPdfText.getPDFtext(path);
  } catch (e) {
    print('Failed to extract PDF text: $e');
    return '';
  }
}

/// Split text into chunks with optional overlap
List<String> splitTextIntoChunks(
  String text, {
  int chunkSize = 500,
  int overlap = 50,
}) {
  List<String> chunks = [];
  int start = 0;
  while (start < text.length) {
    int end =
        (start + chunkSize < text.length) ? start + chunkSize : text.length;
    chunks.add(text.substring(start, end));
    start += chunkSize - overlap;
  }
  return chunks;
}

/// Example usage: extract, split, and upsert a PDF
Future<void> upsertPdfToPinecone() async {
  final upserter = PineconeBatchUpserter();
  final pdfPath = 'assets/data.pdf';

  // 1. Extract text from PDF
  final pdfText = await extractPdfText(pdfPath);
  if (pdfText.isEmpty) {
    print('No text extracted from PDF.');
    return;
  }

  // 2. Split text into chunks
  final chunks = splitTextIntoChunks(pdfText, chunkSize: 500, overlap: 50);

  // 3. Dummy embedder (replace with your real embedding function)
  Future<List<double>> embedText(String text) async {
    // TODO: Replace with actual embedding API call
    return List.generate(1536, (index) => (index % 100) / 100.0);
  }

  // 4. Optional: build metadata for each chunk
  Map<String, dynamic> buildMetadata(int i, String chunk) => {
    'source': pdfPath,
    'chunk': i,
    'text': chunk,
  };

  // 5. Upsert chunks to Pinecone
  await upserter.upsertChunks(
    chunks: chunks,
    embedder: embedText,
    metadataBuilder: buildMetadata,
  );
}
