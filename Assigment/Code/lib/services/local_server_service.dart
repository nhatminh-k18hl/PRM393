import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class LocalServerService {
  static final LocalServerService _instance = LocalServerService._internal();
  factory LocalServerService() => _instance;
  LocalServerService._internal();

  HttpServer? _server;
  String? _appDocDirPath;

  int? get localPort => _server?.port;
  String get baseUrl => _server != null ? 'http://127.0.0.1:${_server!.port}' : '';

  Future<void> startServer() async {
    if (_server != null) return;

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      _appDocDirPath = appDocDir.path;

      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      debugPrint('LocalServerService started on $baseUrl');

      _server!.listen((HttpRequest request) async {
        _handleRequest(request);
      });
    } catch (e) {
      debugPrint('Error starting LocalServerService: $e');
    }
  }

  void _handleRequest(HttpRequest request) async {
    final response = request.response;

    // Enable CORS for webview / model-viewer fetch
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      response.statusCode = HttpStatus.ok;
      await response.close();
      return;
    }

    if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
      await response.close();
      return;
    }

    try {
      final uriPath = Uri.decodeFull(request.uri.path);
      // Path format: /models/{id}/...
      if (uriPath.startsWith('/models/') && _appDocDirPath != null) {
        final relativePath = uriPath.substring('/models/'.length); // e.g. "rabbit_ear_fold/finish.glb"
        final segments = relativePath.split('/');
        final origamiId = segments.isNotEmpty ? segments.first : '';
        final requestedFileName = segments.isNotEmpty ? segments.last : '';

        final directFile = File('$_appDocDirPath/models/$relativePath');
        File? fileToServe;

        if (directFile.existsSync()) {
          fileToServe = directFile;
        } else if (origamiId.isNotEmpty && requestedFileName.isNotEmpty) {
          // Recursive search inside models/$origamiId
          final origamiDir = Directory('$_appDocDirPath/models/$origamiId');
          if (origamiDir.existsSync()) {
            final entities = origamiDir.listSync(recursive: true);
            for (final entity in entities) {
              if (entity is File) {
                final filename = entity.path.split(Platform.pathSeparator).last;
                if (filename.toLowerCase() == requestedFileName.toLowerCase()) {
                  fileToServe = entity;
                  break;
                }
              }
            }
          }
        }

        if (fileToServe != null && fileToServe.existsSync()) {
          response.statusCode = HttpStatus.ok;

          final ext = requestedFileName.toLowerCase();
          if (ext.endsWith('.glb')) {
            response.headers.contentType = ContentType('model', 'gltf-binary');
          } else if (ext.endsWith('.json')) {
            response.headers.contentType = ContentType('application', 'json', charset: 'utf-8');
          } else if (ext.endsWith('.png')) {
            response.headers.contentType = ContentType('image', 'png');
          } else if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
            response.headers.contentType = ContentType('image', 'jpeg');
          }

          response.headers.contentLength = fileToServe.lengthSync();
          await response.addStream(fileToServe.openRead());
          await response.close();
          return;
        }
      }

      response.statusCode = HttpStatus.notFound;
      response.write('404 Not Found');
      await response.close();
    } catch (e) {
      debugPrint('Error serving file: $e');
      response.statusCode = HttpStatus.internalServerError;
      await response.close();
    }
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
  }
}
