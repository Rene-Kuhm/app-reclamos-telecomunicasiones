import 'package:flutter/material.dart';
import '../../data/models/archivo_model.dart';

/// Archivo item widget
class ArchivoItem extends StatelessWidget {
  final Archivo archivo;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ArchivoItem({
    super.key,
    required this.archivo,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFileColor(context),
          child: Icon(
            _getFileIcon(),
            color: Colors.white,
          ),
        ),
        title: Text(
          archivo.nombreArchivo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(archivo.formattedSize),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Theme.of(context).colorScheme.error,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  IconData _getFileIcon() {
    if (archivo.isImage) {
      return Icons.image;
    } else if (archivo.isPDF) {
      return Icons.picture_as_pdf;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(BuildContext context) {
    if (archivo.isImage) {
      return Colors.blue;
    } else if (archivo.isPDF) {
      return Colors.red;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
