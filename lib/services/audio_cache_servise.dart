import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

/// Audio baytlarini Hive'da saqlaydi — url kalit, bayt massivi qiymat.
/// LazyBox ishlatiladi, shunda faqat kerakli audio o'qilganda xotiraga tushadi.
class  AudioHiveCache {
  static const boxName = 'audio_cache';

  static Future<LazyBox<Uint8List>> _box() async {
    if (Hive.isBoxOpen(boxName)) return Hive.lazyBox<Uint8List>(boxName);
    return Hive.openLazyBox<Uint8List>(boxName);
  }

  static Future<Uint8List?> get(String url) async => (await _box()).get(url);

  static Future<void> put(String url, Uint8List bytes) async =>
      (await _box()).put(url, bytes);
}

