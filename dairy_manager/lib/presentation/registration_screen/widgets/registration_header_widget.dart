import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common_widgets.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Container(
          width: double.infinity,
          height: 220,
          color: AppTheme.primaryColor,
        ),
        // Milk drip effect
        const MilkDripWidget(
          height: 140,
        ),
        // Logo and Register text
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/joined_hands.svg',
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Register,',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.whiteColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
