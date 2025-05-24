import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    Key? key,
    required this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 60.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Hata Oluştu',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
