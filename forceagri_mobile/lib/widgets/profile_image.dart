import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/worker_model.dart';

class ProfileImage extends StatefulWidget {
  final WorkerModel worker;
  final double radius;
  const ProfileImage({super.key, required this.worker, this.radius = 64});

  @override
  _ProfileImageState createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  late Future<File?> _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = _loadImage();
  }

  Future<File?> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheManager = DefaultCacheManager();
    final keyTs = 'cachedImageUpdatedAt_${widget.worker.id}';
    final localMillis = prefs.getInt(keyTs);
    final localTs = localMillis != null
      ? DateTime.fromMillisecondsSinceEpoch(localMillis)
      : null;
    final remoteTs = widget.worker.photoUpdatedAt;
    final url = widget.worker.profileImageUrl;

    // Invalidate if remote is newer
    if (localTs == null || remoteTs.isAfter(localTs)) {
      await cacheManager.removeFile(url);
      if (url.isNotEmpty) {
        try {
          final file = await cacheManager.getSingleFile(url);
          await prefs.setInt(keyTs, remoteTs.millisecondsSinceEpoch);
          return file;
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    // Use cached
    final info = await cacheManager.getFileFromCache(url);
    if (info != null) return info.file;

    // Fallback download
    if (url.isNotEmpty) {
      try {
        return await cacheManager.getSingleFile(url);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _imageFile,
      builder: (context, snap) {
        if (snap.hasData && snap.data != null) {
          return CircleAvatar(
            radius: widget.radius,
            backgroundImage: FileImage(snap.data!),
            backgroundColor: Colors.grey.shade200,
          );
        }
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.grey.shade200,
          child: Icon(Icons.person, size: widget.radius),
        );
      },
    );
  }
}