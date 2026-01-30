import 'package:flutter/material.dart';
import '../core/colors.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final String text;
  final Offset targetPosition; 
  final bool isVisible;

  const TutorialOverlay({
    Key? key,
    required this.onNext,
    required this.onSkip,
    required this.text,
    required this.targetPosition,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Dimmed Background
        Positioned.fill(
          child: GestureDetector(
            onTap: onNext, // Tap anywhere to next
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
        ),
        
        // Highlight Circle
        Positioned(
          left: targetPosition.dx - 40,
          top: targetPosition.dy - 40,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20)
              ],
            ),
          ),
        ),

        // Text Bubble
        Positioned(
          left: 20,
          right: 20,
          top: targetPosition.dy + 60,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      const Icon(Icons.school, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Guide',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onSkip,
                        child: const Text('Skip Tutorial', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Next', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
