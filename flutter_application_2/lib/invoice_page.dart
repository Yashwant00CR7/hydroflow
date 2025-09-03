import 'package:flutter/material.dart';
import 'services/cart_service.dart';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return formatter.format(value);
  }

  double _parsePriceToDouble(String price) {
    final digits = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }

  Future<void> _generatePdf(BuildContext context, CartService cart) async {
    final pdf = pw.Document();

    final date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final items = cart.items;
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) => sum + _parsePriceToDouble(item.price) * item.quantity,
    );
    const taxRate = 0.18; // 18% GST example
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sabari Hydro Pneumatics - Invoice',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(date, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'From:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Sabari Hydro Pneumatics'),
                        pw.Text('No. 16, Gandhi Nagar, 2nd Cross'),
                        pw.Text('Coimbatore, Tamil Nadu 641012'),
                        pw.Text('Phone: +91-99999-99999'),
                        pw.Text('Email: info@sabarihydro.com'),
                        pw.Text('GSTIN: 33AAAAA0000A1Z5'),
                      ],
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Billed To:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Customer Name'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Table.fromTextArray(
                headers: const ['Item', 'Qty', 'Price', 'Amount'],
                data:
                    items.map((e) {
                      final unit = _parsePriceToDouble(e.price);
                      final amount = unit * e.quantity;
                      return [
                        e.name,
                        e.quantity.toString(),
                        _formatCurrency(unit),
                        _formatCurrency(amount),
                      ];
                    }).toList(),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
              ),

              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        _lineRow('Subtotal', _formatCurrency(subtotal)),
                        _lineRow('Tax (18%)', _formatCurrency(tax)),
                        pw.Divider(),
                        _lineRow('Total', _formatCurrency(total), isBold: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 24),
              pw.Text('Thank you for your purchase!'),
              pw.SizedBox(height: 4),
              pw.Text(
                'Sabari Hydro Pneumatics • www.sabarihydro.com',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _lineRow(String label, String value, {bool isBold = false}) {
    final style = pw.TextStyle(
      fontSize: 12,
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label, style: style), pw.Text(value, style: style)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();
    final items = cart.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body:
          items.isEmpty
              ? const Center(child: Text('Your cart is empty'))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Sabari Hydro Pneumatics',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text('Invoice Preview'),
                        ],
                      ),
                      Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text('Sabari Hydro Pneumatics'),
                                Text('No. 16, Gandhi Nagar, 2nd Cross'),
                                Text('Coimbatore, Tamil Nadu 641012'),
                                Text('Phone: +91-99999-99999'),
                                Text('Email: info@sabarihydro.com'),
                                Text('GSTIN: 33AAAAA0000A1Z5'),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Billed To:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text('Customer Name'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          for (final item in items) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('x${item.quantity}'),
                                const SizedBox(width: 12),
                                Text(item.price),
                              ],
                            ),
                            const Divider(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _summaryText('Subtotal', cart.totalAmount),
                          _summaryText('Tax (18%)', cart.totalAmount * 0.18),
                          const SizedBox(height: 6),
                          Text(
                            _formatCurrency(cart.totalAmount * 1.18),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
      bottomNavigationBar:
          items.isEmpty
              ? null
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _generatePdf(context, cart),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate & Share PDF Invoice'),
                ),
              ),
    );
  }

  Widget _summaryText(String label, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 8),
        Text(_formatCurrency(value)),
      ],
    );
  }
}
