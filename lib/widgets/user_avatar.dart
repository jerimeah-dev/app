import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/user_model.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double size;
  final bool viewable;

  const UserAvatar({
    super.key,
    required this.user,
    required this.size,
    this.viewable = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size;

    if (user.avatarUrl == null || user.avatarUrl!.isEmpty) {
      return _fallback(context, radius);
    }

    final avatar = CachedNetworkImage(
      imageUrl: user.avatarUrl!,
      imageBuilder: (_, imageProvider) =>
          CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
        ),
      ),
      errorWidget: (_, __, ___) => _fallback(context, radius),
    );

    if (!viewable) return avatar;

    return GestureDetector(onTap: () => _openViewer(context), child: avatar);
  }

  Widget _fallback(BuildContext context, double radius) {
    final letter = user.displayName.isNotEmpty
        ? user.displayName[0]
        : user.email[0];

    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        letter.toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: user.avatarUrl!),
        ),
      ),
    );
  }
}
