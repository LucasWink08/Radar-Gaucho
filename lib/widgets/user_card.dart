
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/app_theme.dart';

class UserCard extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.vermelho,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.marrom),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrentUser)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.verified, color: AppTheme.dourado, size: 18),
              ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.verdeEscuro),
              onPressed: onEdit,
              tooltip: 'Editar',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Excluir',
            ),
          ],
        ),
      ),
    );
  }
}
