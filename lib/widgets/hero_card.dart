import 'package:flutter/material.dart';

import '../app_theme.dart';

// Tarjeta de un héroe en Elegir héroe: avatar redondo con la inicial, nombre
// y descripción corta (2 líneas). Marcada, el borde se pone dorado y grueso.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.name,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.3),
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.lapis,
                child: Text(
                  name.isEmpty ? '?' : name.characters.first.toUpperCase(),
                  style: AppText.title.copyWith(fontSize: 26),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: AppText.title.copyWith(fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: AppText.bodySecondary.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
