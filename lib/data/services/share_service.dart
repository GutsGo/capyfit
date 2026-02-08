import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:capyfit/data/utils/logger.dart';

class ShareService {
  /// 将 [GlobalKey] 关联的 [RepaintBoundary] 转换为图片并分享
  static Future<void> captureAndShare(GlobalKey key, {String? text}) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // 生成图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final uint8List = byteData.buffer.asUint8List();

      // 保存到临时文件
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/capyfit_share_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(uint8List);

      // 唤起分享
      await Share.shareXFiles([XFile(file.path)], text: text);
    } catch (e) {
      Log.e('ShareService Error', e);
      rethrow;
    }
  }
}
