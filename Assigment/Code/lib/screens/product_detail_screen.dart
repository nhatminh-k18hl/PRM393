import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/origami_provider.dart';
import 'practice_viewer_screen.dart';

class OrigamiMetadata {
  final String dimensions;
  final String texture;
  final String tips;
  final String estimatedTime;
  final int totalSteps;

  const OrigamiMetadata({
    required this.dimensions,
    required this.texture,
    required this.tips,
    required this.estimatedTime,
    required this.totalSteps,
  });
}

class ProductDetailScreen extends StatefulWidget {
  final OrigamiModel model;

  const ProductDetailScreen({Key? key, required this.model}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<OrigamiMetadata> _metadataFuture;

  @override
  void initState() {
    super.initState();
    _metadataFuture = _loadModelMetadata();
  }

  // Simulate loading data asynchronously
  Future<OrigamiMetadata> _loadModelMetadata() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return const OrigamiMetadata(
      dimensions: "15 x 15 cm",
      texture: "Premium Washi Matte Paper (80g/m²)",
      tips: "Ensure your paper is cut to an exact square. Keep initial valley-folds perfectly straight. Make sure corners align exactly before creasing.",
      estimatedTime: "12 mins",
      totalSteps: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent, // transparent so background overlay dim is shown
      body: Stack(
        children: [
          // Dismiss on tapping anywhere outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Central modal content container
          Center(
            child: Container(
              width: 580,
              height: 330,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
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
                  // Inner contents
                  Row(
                    children: [
                      // Left Column: Visual graphic & summary
                      _buildLeftColumn(settings),
                      // Divider line
                      Container(
                        width: 1,
                        height: double.infinity,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      // Right Column: FutureBuilder info
                      Expanded(
                        child: _buildRightColumn(settings),
                      ),
                    ],
                  ),

                  // Dedicated structural close button [X] inside the card
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
      color: Colors.black.withOpacity(0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Geometric abstract visualization shape
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: widget.model.previewColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.model.previewColor.withOpacity(0.35),
                    blurRadius: 16,
                  )
                ],
              ),
              child: const Icon(
                Icons.token,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.model.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.model.category,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightColumn(AppSettingsProvider settings) {
    return FutureBuilder<OrigamiMetadata>(
      future: _metadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(settings.primaryColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reading blueprint specs...',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading metadata',
              style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
            ),
          );
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Details Title
              const Text(
                'SPECIFICATIONS',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Attributes grid/row list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAttributeItem('Dimensions', data.dimensions, Icons.zoom_out_map),
                  _buildAttributeItem('Estimated Time', data.estimatedTime, Icons.timer),
                ],
              ),
              const SizedBox(height: 12),
              _buildAttributeItem('Texture Standard', data.texture, Icons.texture),

              const SizedBox(height: 14),
              // Tips block
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, size: 14, color: settings.primaryColor),
                          const SizedBox(width: 4),
                          const Text(
                            'Expert Tip',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.tips,
                        style: const TextStyle(fontSize: 10, color: Colors.white54, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom [Continue] Button
              SizedBox(
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
                  onPressed: () {
                    // Close the detail overlay
                    Navigator.of(context).pop();

                    // Push the practice viewer screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeViewerScreen(
                          modelName: widget.model.title,
                          paperColor: settings.paperColor,
                          totalSteps: data.totalSteps,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue to Fold',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttributeItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
