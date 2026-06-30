String timeAgoFa(DateTime utcTime) {
  final local = utcTime.toLocal();
  final diff = DateTime.now().difference(local);

  if (diff.inSeconds < 60) return "هم‌اکنون";
  if (diff.inMinutes < 60) return "${diff.inMinutes} دقیقه پیش";
  if (diff.inHours < 24) return "${diff.inHours} ساعت پیش";
  if (diff.inDays < 7) return "${diff.inDays} روز پیش";

  return "${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}";
}
