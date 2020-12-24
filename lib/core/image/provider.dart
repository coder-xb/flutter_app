/*
import 'dart:convert' as convert;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NetImage extends ImageProvider<NetImage> {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const NetImage(this.url, {this.scale = 1.0, this.headers, this.sdCache})
      : assert(url != null),
        assert(scale != null);

  /// The URL from which the image will be fetched.
  final String url;

  final bool sdCache;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [HttpClient.get] to fetch image from network.
  final Map<String, String> headers;

  @override
  Future<NetImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetImage>(this);
  }

  @override
  ImageStreamCompleter load(NetImage key, DecoderCallback decoder) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decoder),
      scale: key.scale,
      informationCollector: () sync* {
        yield ErrorDescription('Image provider: $this');
        yield ErrorDescription('Image key: $key');
      },
    );
  }

  Future<Codec> _loadAsync(NetImage key, DecoderCallback decoder) async {
    assert(key == this);
    if (sdCache != null) {
      final Uint8List bytes = await _getFromSdcard(key.url);
      if (bytes != null &&
          bytes.lengthInBytes != null &&
          bytes.lengthInBytes != 0) {
        return await decoder(bytes);
      }
    }
    final Uri resolved = Uri.base.resolve(key.url);
    Response response =
        await Dio(BaseOptions(responseType: ResponseType.bytes)).get(key.url);

    if (response.statusCode != HttpStatus.ok)
      throw Exception(
          'HTTP request failed, statusCode: ${response?.statusCode}, $resolved');

    final Uint8List bytes = response.data;
    if (sdCache != null && bytes.lengthInBytes != 0) {
      _saveToImage(bytes, key.url);
    }
    if (bytes.lengthInBytes == 0)
      throw Exception('NetImage is an empty file: $resolved');

    return await decoder(bytes);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';

  void _saveToImage(Uint8List mUint8List, String name) async {
    name = md5.convert(convert.utf8.encode(name)).toString();
    Directory dir = await getTemporaryDirectory();
    String path = dir.path + "/" + name;
    var file = File(path);
    bool exist = await file.exists();
    if (!exist) File(path).writeAsBytesSync(mUint8List);
  }

  _getFromSdcard(String name) async {
    name = md5.convert(convert.utf8.encode(name)).toString();
    Directory dir = await getTemporaryDirectory();
    String path = dir.path + "/" + name;
    var file = File(path);
    bool exist = await file.exists();
    if (exist) {
      final Uint8List bytes = await file.readAsBytes();
      return bytes;
    }
    return null;
  }
}
*/
