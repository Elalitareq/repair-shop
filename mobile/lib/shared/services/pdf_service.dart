import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/repair.dart';
import '../models/sale.dart';

class PdfService {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  final dateFormat = DateFormat('MMM dd, yyyy');

  /// Print Repair Invoice
  Future<void> printRepairInvoice(Repair repair) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) => _buildRepairInvoice(repair),
        footer: (pw.Context context) => _buildFooter(),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Repair_${repair.repairNumber}',
    );
  }

  /// Print Sale Invoice
  Future<void> printSaleInvoice(Sale sale) async {
    final doc = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: boldFont,
        ),
        build: (pw.Context context) => _buildSaleInvoice(sale),
        footer: (pw.Context context) => _buildFooter(),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Sale_${sale.saleNumber ?? "Draft"}',
    );
  }

  List<pw.Widget> _buildRepairInvoice(Repair repair) {
    final totalPaid = repair.payments.fold(0.0, (sum, p) => sum + p.amount);
    final remaining = repair.totalCost - totalPaid;

    return [
      _buildHeader('REPAIR INVOICE', repair.repairNumber),
      pw.SizedBox(height: 20),
      _buildCustomerInfo(
        name: repair.customer.name,
        phone: repair.customer.phone,
        email: repair.customer.email,
        address: repair.customer.address,
      ),
      pw.SizedBox(height: 20),
      _buildDeviceInfo(
        brand: repair.deviceBrand,
        model: repair.deviceModel,
        imei: repair.deviceImei,
        problem: repair.problemDescription,
      ),
      pw.SizedBox(height: 20),
      pw.Text('Items & Services',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      _buildRepairItemsTable(repair),
      pw.SizedBox(height: 20),
      _buildTotals(
        subtotal: repair.totalCost, // Using totalCost as subtotal for simplicity
        total: repair.totalCost,
        paid: totalPaid,
        remaining: remaining > 0 ? remaining : 0.0,
      ),
    ];
  }

  List<pw.Widget> _buildSaleInvoice(Sale sale) {
    return [
      _buildHeader('SALE INVOICE', sale.saleNumber ?? 'DRAFT'),
      pw.SizedBox(height: 20),
      if (sale.customer != null)
        _buildCustomerInfo(
          name: sale.customer!.name,
          phone: sale.customer!.phone,
          email: sale.customer!.email,
          address: sale.customer!.address,
        ),
      pw.SizedBox(height: 20),
      pw.Text('Items',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      _buildSaleItemsTable(sale),
      pw.SizedBox(height: 20),
      _buildTotals(
        subtotal: sale.subtotal,
        discount: sale.discountAmount,
        tax: sale.taxAmount,
        total: sale.totalAmount,
        paid: sale.totalPaid,
        remaining: sale.remainingBalance,
      ),
    ];
  }

  pw.Widget _buildHeader(String title, String number) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('REPAIR SHOP',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('123 Repair St, Tech City'), // TODO: Get from settings
            pw.Text('Phone: (555) 123-4567'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('Number: $number'),
            pw.Text('Date: ${dateFormat.format(DateTime.now())}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerInfo({
    required String name,
    required String phone,
    String? email,
    String? address,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Bill To:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text(name),
          pw.Text(phone),
          if (email != null) pw.Text(email),
          if (address != null) pw.Text(address),
        ],
      ),
    );
  }

  pw.Widget _buildDeviceInfo({
    required String brand,
    required String model,
    String? imei,
    required String problem,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Device Details:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text('$brand $model'),
          if (imei != null) pw.Text('IMEI/Serial: $imei'),
          pw.SizedBox(height: 5),
          pw.Text('Problem: $problem'),
        ],
      ),
    );
  }

  pw.Widget _buildRepairItemsTable(Repair repair) {
    final headers = ['Description', 'Qty', 'Unit Price', 'Total'];
    final data = <List<String>>[];

    if (repair.serviceCharge != null && repair.serviceCharge! > 0) {
      data.add([
        'Service Charge',
        '1',
        currencyFormat.format(repair.serviceCharge),
        currencyFormat.format(repair.serviceCharge),
      ]);
    }

    for (final item in repair.items) {
      data.add([
        item.itemName ?? 'Item',
        item.quantity?.toStringAsFixed(0) ?? '0',
        currencyFormat.format(item.unitPrice ?? 0),
        currencyFormat.format(item.totalPrice ?? 0),
      ]);
    }

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildSaleItemsTable(Sale sale) {
    final headers = ['Item', 'Qty', 'Price', 'Total'];
    final data = (sale.saleItems ?? []).map((item) {
      return [
        item.item?.name ?? 'Unknown Item',
        item.quantity.toString(),
        currencyFormat.format(item.unitPrice),
        currencyFormat.format(item.total),
      ];
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotals({
    required double subtotal,
    double discount = 0,
    double tax = 0,
    required double total,
    required double paid,
    required double remaining,
  }) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal', subtotal),
          if (discount > 0) _buildTotalRow('Discount', -discount),
          _buildTotalRow('Tax', tax),
          pw.Divider(),
          _buildTotalRow('Total After Tax', total, isBold: true),
          _buildTotalRow('Amount Paid', paid),
          pw.SizedBox(height: 5),
          _buildTotalRow('Balance Due', remaining,
              isBold: true, color: remaining > 0 ? PdfColors.red : PdfColors.black),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double value,
      {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : null, color: color)),
        pw.SizedBox(width: 20),
        pw.Container(
          width: 80,
          alignment: pw.Alignment.centerRight,
          child: pw.Text(currencyFormat.format(value),
              style: pw.TextStyle(
                  fontWeight: isBold ? pw.FontWeight.bold : null,
                  color: color)),
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.Text('Thank you for your business!',
            style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      ],
    );
  }
}
