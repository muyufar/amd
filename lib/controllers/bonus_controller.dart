import 'package:get/get.dart';
import '../services/bonus_service.dart';

class BonusController extends GetxController {
  // Observable variables
  final RxBool isClaiming = false.obs;
  final RxString error = ''.obs;
  final RxString successMessage = ''.obs;

  // Claim bonus with code
  Future<bool> claimBonus(String code) async {
    try {
      isClaiming.value = true;
      error.value = '';
      successMessage.value = '';

      print('🟡 [BONUS CONTROLLER] Claiming bonus with code: $code');

      final result = await BonusService.claimBonus(code);

      if (result != null && result['status'] == true) {
        successMessage.value = result['message'] ?? 'Bonus berhasil diklaim!';
        print('🟢 [BONUS CONTROLLER] Bonus claimed successfully');
        return true;
      } else {
        error.value = result?['message'] ?? 'Gagal mengklaim bonus';
        print(
            '🔴 [BONUS CONTROLLER] Failed to claim bonus: ${result?['message']}');
        return false;
      }
    } catch (e) {
      error.value = 'Terjadi kesalahan: $e';
      print('🔴 [BONUS CONTROLLER] Error claiming bonus: $e');
      return false;
    } finally {
      isClaiming.value = false;
    }
  }

  // Clear error
  void clearError() {
    error.value = '';
  }

  // Clear success message
  void clearSuccessMessage() {
    successMessage.value = '';
  }
}
