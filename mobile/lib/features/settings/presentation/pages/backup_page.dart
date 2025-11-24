import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../shared/services/backup_service.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backupService = ref.read(backupServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download Backup'),
              onPressed: () async {
                final resp = await backupService.downloadBackup();
                if (!resp.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Download failed: ${resp.message}')),
                  );
                  return;
                }

                final bytes = resp.dataOrNull;
                if (bytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No data in response')),
                  );
                  return;
                }

                try {
                  final dir = await getApplicationDocumentsDirectory();
                  final fileName =
                      'repair_shop_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.db';
                  final file = File('${dir.path}/$fileName');
                  await file.writeAsBytes(bytes, flush: true);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup saved: ${file.path}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save backup: $e')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Restore Backup from File'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                );
                if (result == null || result.files.isEmpty) return;
                final filePath = result.files.single.path;
                if (filePath == null) return;
                final file = File(filePath);

                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Restore'),
                    content: const Text(
                      'Restoring a database will overwrite current data. Proceed?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Proceed'),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                final resp = await backupService.restoreBackup(file);
                if (!resp.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restore failed: ${resp.message}')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Database restored successfully.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
