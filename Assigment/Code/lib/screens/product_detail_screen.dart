import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import '../providers/app_settings_provider.dart';
import '../providers/origami_provider.dart';
import '../models/origami_model.dart';
import 'practice_viewer_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final OrigamiModel model;

  const ProductDetailScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoadingSpecs = true;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _simulateLoadingSpecs();
  }

  Future<void> _simulateLoadingSpecs() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() {
        _isLoadingSpecs = false;
      });
    }
  }

  Future<void> _handleContinue(OrigamiProvider provider) async {
    final isDownloaded = provider.isModelDownloaded(widget.model.id);
    final targetDir = provider.getModelDirectoryPath(widget.model.id);

    if (isDownloaded) {
      _navigateToViewer(provider.getActualBaseDir(widget.model.id));
    } else {
      setState(() {
        _isDownloading = true;
        _downloadProgress = 0.0;
        _statusText = 'Connecting to server...';
      });

      try {
        final zipPath = "$targetDir/package.zip";
        final tempFile = File(zipPath);
        if (!tempFile.parent.existsSync()) {
          tempFile.parent.createSync(recursive: true);
        }

        final dio = Dio();
        await dio.download(
          widget.model.downloadUrl,
          zipPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              setState(() {
                _downloadProgress = received / total;
                _statusText = 'Downloading package: ${(_downloadProgress * 100).toStringAsFixed(0)}%';
              });
            }
          },
        );

        setState(() {
          _statusText = 'Extracting resources...';
        });

        // Unpack ZIP
        final bytes = tempFile.readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(bytes);
        for (final file in archive) {
          if (file.isFile) {
            final data = file.content as List<int>;
            final outFile = File(Uri.decodeFull("$targetDir/${file.name}"));
            outFile.createSync(recursive: true);
            outFile.writeAsBytesSync(data);
          }
        }

        // Delete temporary ZIP file
        tempFile.deleteSync();

        provider.refreshDownloadStatus();

        if (mounted) {
          setState(() {
            _isDownloading = false;
          });
          _navigateToViewer(provider.getActualBaseDir(widget.model.id));
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _statusText = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        }
      }
    }
  }

  void _navigateToViewer(String targetDir) {
    Navigator.of(context).pop(); // dismiss detail modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticeViewerScreen(
          modelId: widget.model.id,
          modelName: widget.model.title,
          modelDir: targetDir,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    final origamiData = Provider.of<OrigamiProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dismiss on tapping outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Central modal content
          Center(
            child: Container(
              width: 580,
              height: 330,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: settings.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: settings.textColor.withOpacity(0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Row(
                    children: [
                      // Left Column: Visual summary
                      _buildLeftColumn(settings),
                      // Divider line
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: settings.textColor.withOpacity(0.08),
                      ),
                      // Right Column: Info specs
                      Expanded(
                        child: _buildRightColumn(settings, origamiData),
                      ),
                    ],
                  ),

                  // Close button [X] inside the card
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftColumn(AppSettingsProvider settings) {
    return Container(
      width: 210,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      color: settings.textColor.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: settings.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: settings.primaryColor.withOpacity(0.3)),
              ),
              child: Image.asset(
                widget.model.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.token, size: 38, color: settings.primaryColor);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.model.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: settings.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.model.difficulty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: settings.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(AppSettingsProvider settings, OrigamiProvider provider) {
    if (_isLoadingSpecs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Reading blueprint specs...',
              style: TextStyle(color: settings.textColor.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      );
    }

    final materials = widget.model.materials;
    final List<dynamic> tools = materials['tools'] ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SPECIFICATIONS',
            style: TextStyle(
              fontSize: 10,
              color: settings.textColor.withOpacity(0.4),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAttributeItem(settings, 'Dimensions', materials['paper_size'] ?? '15x15 cm', Icons.zoom_out_map),
              _buildAttributeItem(settings, 'Paper Type', materials['paper_type'] ?? 'Standard Paper', Icons.description),
            ],
          ),
          const SizedBox(height: 12),
          _buildAttributeItem(
            settings,
            'Required Tools',
            tools.isEmpty ? 'None' : tools.join(', '),
            Icons.construction,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: settings.textColor.withOpacity(0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: settings.textColor.withOpacity(0.08)),
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    widget.model.description,
                    style: TextStyle(fontSize: 10, color: settings.textColor.withOpacity(0.6), height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Download progress or Continue button
          _isDownloading
              ? Column(
                  children: [
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: settings.textColor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _statusText,
                      style: TextStyle(fontSize: 10, color: settings.textColor.withOpacity(0.6)),
                    ),
                  ],
                )
              : SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _handleContinue(provider),
                    child: Text(
                      provider.isModelDownloaded(widget.model.id) ? 'Continue to Fold' : 'Download and Fold',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(AppSettingsProvider settings, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: settings.textColor.withOpacity(0.4)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: settings.textColor.withOpacity(0.4)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 11, color: settings.textColor.withOpacity(0.8), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
