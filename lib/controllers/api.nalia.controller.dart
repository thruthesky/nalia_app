import 'package:get/get.dart';
import 'package:nalia_app/models/api.credit_jewelry.mode.dart';
import 'package:nalia_app/models/api.daily_bonus.model.dart';
import 'package:firelamp/firelamp.dart';

class NaliaController extends GetxController {
  static final NaliaController to = Get.find<NaliaController>();

  Future<DailyBonus> getMyBonusJewelry() async {
    final data = await api.request({
      'route': 'nalia.getMyBonusJewelry',
    });
    return DailyBonus.fromJson(data);
  }

  Future<CreditJewelry> getMyCreditJewelry() async {
    final data = await api.request({
      'route': 'nalia.getMyCreditJewelry',
    });
    return CreditJewelry.fromJson(data);
  }

  Future<DailyBonus> generateTodayBonus() async {
    final data = await api.request({
      'route': 'nalia.generateTodayBonus',
    });

    return DailyBonus.fromJson(data);
  }

  Future<DailyBonus> giveJewelry({String userId, String jewelry, String item, int count}) async {
    final data = await api.request({
      'route': 'nalia.giveJewelry',
      'user_ID': userId,
      'jewelry': jewelry,
      'item': item,
      'count': count,
    });

    // print('req: $data');
    return DailyBonus.fromJson(data);
  }
}
