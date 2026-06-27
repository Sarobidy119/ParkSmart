import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum ReservationStatus {
  pending,   // En attente
  confirmed, // Confirmée
  cancelled, // Annulée
  completed, // Terminée
}

extension ReservationStatusExt on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.confirmed:
        return 'Confirmée';
      case ReservationStatus.cancelled:
        return 'Annulée';
      case ReservationStatus.completed:
        return 'Terminée';
    }
  }

  Color get bgColor {
    switch (this) {
      case ReservationStatus.pending:
        return AppColors.warning.withOpacity(0.1);
      case ReservationStatus.confirmed:
        return AppColors.success.withOpacity(0.1);
      case ReservationStatus.cancelled:
        return AppColors.red.withOpacity(0.1);
      case ReservationStatus.completed:
        return AppColors.primary.withOpacity(0.1);
    }
  }

  Color get textColor {
    switch (this) {
      case ReservationStatus.pending:
        return AppColors.warning;
      case ReservationStatus.confirmed:
        return AppColors.success;
      case ReservationStatus.cancelled:
        return AppColors.red;
      case ReservationStatus.completed:
        return AppColors.primary;
    }
  }

  IconData get icon {
    switch (this) {
      case ReservationStatus.pending:
        return Icons.schedule;
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      case ReservationStatus.completed:
        return Icons.done_all;
    }
  }
}

class ReservationStatusBadge extends StatelessWidget {
  final ReservationStatus status;
  final bool showIcon;

  const ReservationStatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.textColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon)
            Icon(
              status.icon,
              color: status.textColor,
              size: 14,
            ),
          if (showIcon) const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ReservationStatusNotification extends StatelessWidget {
  final ReservationStatus status;
  final String message;
  final VoidCallback? onDismiss;

  const ReservationStatusNotification({
    super.key,
    required this.status,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status.textColor,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status.icon,
            color: status.textColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    color: status.textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: status.textColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: status.textColor, size: 20),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
