import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/sale_provider.dart';

class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          // Overlay with scan area
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Position barcode here',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    // Process the barcode
    _processBarcode(barcode.rawValue!);
  }

  Future<void> _processBarcode(String barcodeValue) async {
    try {
      // Call the barcode scan API
      final response = await ref
          .read(saleServiceProvider)
          .scanBarcode(barcodeValue);

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final type = data['type'];
        final itemData = data['data'];

        if (type == 'item' || type == 'serial') {
          final item = itemData['item'];
          if (mounted) {
            // Show item details and option to add to cart
            _showItemFoundDialog(item, barcodeValue);
          }
        } else {
          // Unknown barcode
          if (mounted) {
            _showUnknownBarcodeDialog(barcodeValue);
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog('Failed to process barcode');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showItemFoundDialog(Map<String, dynamic> item, String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Item Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'] ?? 'Unknown Item',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Barcode: $barcode'),
            Text('Stock: ${item['stock_quantity'] ?? 0}'),
            Text(
              'Price: \$${item['selling_price']?.toStringAsFixed(2) ?? '0.00'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(
                context,
              ).pop(barcode); // Return to previous screen with barcode
            },
            child: const Text('Add to Sale'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showUnknownBarcodeDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Not Found'),
        content: Text('No item found for barcode: $barcode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
