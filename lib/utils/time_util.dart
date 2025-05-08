import 'package:rongcloud_im_wrapper_plugin/rongcloud_im_wrapper_plugin.dart';

class TimeUtil {
  static String conversationFormatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    // 先判断年份
    if (date.year != now.year) {
      return '${date.year}年${date.month}月${date.day}日';
    }

    final differenceInDays = now.difference(date).inDays;
    if (differenceInDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (differenceInDays == 1) {
      return '昨天';
    } else if (differenceInDays > 1 && differenceInDays < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[date.weekday % 7];
    } else {
      return '${date.month}月${date.day}日';
    }
  }

  static String chatViewFormatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    // 先判断年份
    if (date.year != now.year) {
      return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    // 再判断月份
    if (date.month != now.month) {
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }

    final differenceInDays = now.difference(date).inDays;
    if (differenceInDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (differenceInDays == 1) {
      return '昨天 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (differenceInDays > 1 && differenceInDays < 7) {
      const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return '${weekdays[date.weekday % 7]} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  static bool shouldShowTime(RCIMIWMessage current, RCIMIWMessage previous) {
    // 如果两条消息间隔超过3分钟，显示时间
    return ((current.sentTime ?? 0) - (previous.sentTime ?? 0).abs()) >
        3 * 60 * 1000;
  }
}
