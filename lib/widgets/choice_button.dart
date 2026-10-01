import 'package:flutter/material.dart';

import '../app_theme.dart';

// Una opción de la escena: punto de color del riesgo, texto, descripción y
// etiqueta ("Riesgo bajo / medio / alto") en el mismo color.
class ChoiceButton extends StatelessWidget {
  const ChoiceButton({
    super.key,
    required this.text,
    required this.description,
    required this.riskColor,
    required this.riskLabel,
    required this.onTap,
  });

  final String text;
  final String description;
  final Color riskColor;
  final String riskLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: AppText.body.copyWith(fontWeight: FontWeight.w600, fontSize: 15)),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(description, style: AppText.bodySecondary.copyWith(fontSize: 13)),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      riskLabel,
                      style: AppText.body.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
