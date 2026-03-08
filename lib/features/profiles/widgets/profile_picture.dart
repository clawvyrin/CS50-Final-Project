import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String avatarUrl;
  final double radius;

  const ProfilePicture({super.key, required this.avatarUrl, this.radius = 30});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: FastCachedImage(
          url: avatarUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          fadeInDuration: const Duration(milliseconds: 300),
          errorBuilder: (context, exception, stacktrace) =>
              const Icon(Icons.person),
          loadingBuilder: (context, progress) =>
              const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
