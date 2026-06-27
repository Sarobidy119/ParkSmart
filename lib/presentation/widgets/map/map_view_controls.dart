import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/map_provider.dart';

class MapViewControls extends StatelessWidget {
  final MapViewType currentViewType;
  final Function(MapViewType) onViewChanged;

  const MapViewControls({
    super.key,
    required this.currentViewType,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          _buildViewButton(
            icon: Icons.map,
            label: 'Standard',
            isSelected: currentViewType == MapViewType.standard,
            onTap: () => onViewChanged(MapViewType.standard),
          ),
          const SizedBox(height: 8),
          _buildViewButton(
            icon: Icons.satellite,
            label: 'Satellite',
            isSelected: currentViewType == MapViewType.satellite,
            onTap: () => onViewChanged(MapViewType.satellite),
          ),
          const SizedBox(height: 8),
          _buildViewButton(
            icon: Icons.terrain,
            label: 'Relief',
            isSelected: currentViewType == MapViewType.terrain,
            onTap: () => onViewChanged(MapViewType.terrain),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.white : AppColors.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
