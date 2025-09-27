import 'package:flutter/material.dart';
import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SignupRedirectWidget extends StatelessWidget {
  const SignupRedirectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 1,
            color: AppTheme.lightTheme.dividerColor,
          ),
          SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 1),
              TextButton(
                onPressed: () => _navigateToSignup(context),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2, vertical: 4.0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Register now',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.pushNamed(context, '/registration-screen');
  }
}

