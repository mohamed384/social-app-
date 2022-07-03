
import 'package:get/get.dart';

extension TimeAgoExtention on String {
  static String displayTimeAgoFromTimestamp(String timestamp, bool shorted) {
    final year = int.parse(timestamp.substring(0, 4));
    final month = int.parse(timestamp.substring(5, 7));
    final day = int.parse(timestamp.substring(8, 10));
    final hour = int.parse(timestamp.substring(11, 13));
    final minute = int.parse(timestamp.substring(14, 16));

    final DateTime videoDate = DateTime(year, month, day, hour, minute);
    final int diffInHours = DateTime.now().difference(videoDate).inHours;

    String timeAgo = '';
    String timeUnit = '';
    int timeValue = 0;

    if (diffInHours < 1) {
      final diffInMinutes = DateTime.now().difference(videoDate).inMinutes;
      timeValue = diffInMinutes;
      if(shorted){
        timeUnit = 'm'.tr;
      }else{
        timeUnit = 'minute'.tr;
      }
    } else if (diffInHours < 24) {
      timeValue = diffInHours;
      if(shorted){
        timeUnit = 'h'.tr;
      }else{
        timeUnit = 'hour'.tr;
      }
    } else if (diffInHours >= 24 && diffInHours < 24 * 7) {
      timeValue = (diffInHours / 24).floor();
      if(shorted){
        timeUnit = 'd'.tr;
      }else{
        timeUnit = 'day'.tr;
      }
    } else if (diffInHours >= 24 * 7 && diffInHours < 24 * 30) {
      if(shorted){
        timeValue = (diffInHours / (24 * 7)).floor();
        timeUnit = 'w'.tr;
      }else{
        timeValue = videoDate.day;
        timeUnit = '/' + videoDate.month.toString();
      }
    } else if (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) {
      if(shorted){
        timeValue = (diffInHours / (24 * 7)).floor();
        timeUnit = 'w'.tr;
      }else{
        timeValue = videoDate.day;
        timeUnit = '/' + videoDate.month.toString();
      }
    } else {
      if(shorted){
        timeValue = (diffInHours / (24 * 365)).floor();
        timeUnit = 'y'.tr;
      }else{
        timeValue = videoDate.day;
        timeUnit =
            '/' + videoDate.month.toString() + '/' + videoDate.year.toString();
      }
    }

    if ((diffInHours >= 24 * 7 && diffInHours < 24 * 30) ||
        (diffInHours >= 24 * 30 && diffInHours < 24 * 12 * 30) ||
        (diffInHours > 24 * 12 * 30)) {
      timeAgo = timeValue.toString() + '' + timeUnit;
    } else {
      if (Get.locale.toString() == 'en_US') {
        if(shorted){
          timeAgo = timeValue.toString() + '' + timeUnit;
        }else{
          timeAgo = timeValue.toString() + ' ' + timeUnit;
          timeAgo += timeValue > 1 ? 's' : '';
          timeAgo += 'ago'.tr;
        }
      } else {
        if(shorted){
          timeAgo = timeValue.toString() + '' + timeUnit;
        }else{
          timeAgo = timeValue.toString() + ' ' + timeUnit;
          timeAgo = 'ago'.tr + timeAgo;
          timeAgo = timeValue == 1
              ? timeAgo.replaceAll('$timeValue ساعه', 'ساعه').replaceAll('$timeValue دقيقه', 'دقيقه').replaceAll('$timeValue يوم', 'يوم')
              : timeValue == 2
              ? timeAgo.replaceAll('$timeValue ساعه', 'ساعتان').replaceAll('$timeValue دقيقه', 'دقيقتان').replaceAll('$timeValue يوم', 'يومان')
              : timeValue > 2 && timeValue <11
              ? timeAgo.replaceAll('دقيقه', 'دقائق').replaceAll('ساعه', 'ساعات').replaceAll('يوم', 'ايام')
              : timeAgo;
        }

      }
    }

    if (timeAgo == '0 minute ago' || timeAgo == 'منذ 0 دقيقه' || timeAgo == '0m' || timeAgo == '0د') {
      if(shorted){
        return 'now'.tr;
      }else{
        return 'just_now'.tr;
      }
    } else {
      return timeAgo;
    }
  }
}
