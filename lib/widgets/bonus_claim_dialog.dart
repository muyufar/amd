import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bonus_controller.dart';
import '../utils/theme_utils.dart';

class BonusClaimDialog extends StatefulWidget {
  const BonusClaimDialog({super.key});

  @override
  State<BonusClaimDialog> createState() => _BonusClaimDialogState();
}

class _BonusClaimDialogState extends State<BonusClaimDialog>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  BonusController? _bonusController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    _bonusController = Get.put(BonusController());
  }

  @override
  void dispose() {
    _codeController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _showShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  Future<void> _claimBonus() async {
    if (_codeController.text.trim().isEmpty) {
      _showShakeAnimation();
      return;
    }

    try {
      final bonusController = Get.put(BonusController());
      final success =
          await bonusController.claimBonus(_codeController.text.trim());

      if (success) {
        // Show success dialog
        Get.dialog(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Berhasil!'),
              ],
            ),
            content: Text(bonusController.successMessage.value),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close success dialog
                  Get.back(); // Close input dialog
                  bonusController.clearSuccessMessage();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Show error with shake animation
        _showShakeAnimation();
      }
    } catch (e) {
      print('Error in _claimBonus: $e');
      _showShakeAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.card_giftcard, color: colorPrimary),
          SizedBox(width: 8),
          Text('Klaim Bonus'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Masukkan kode bonus Anda untuk mendapatkan buku gratis!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: 'Kode Bonus',
                      hintText: 'Masukkan kode bonus',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorPrimary),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                );
              },
            ),
            SizedBox(height: 8),
            GetBuilder<BonusController>(
              builder: (controller) {
                if (controller.error.value.isNotEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[200] ?? Colors.red),
                    ),
                    child: Text(
                      controller.error.value,
                      style: TextStyle(
                        color: Colors.red[700] ?? Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            try {
              Get.find<BonusController>().clearError();
            } catch (e) {
              // Controller not found, ignore
            }
            Get.back();
          },
          child: Text('Batal'),
        ),
        GetBuilder<BonusController>(
          builder: (controller) => ElevatedButton(
            onPressed: controller.isClaiming.value ? null : _claimBonus,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: controller.isClaiming.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('Klaim'),
          ),
        ),
      ],
    );
  }
}
