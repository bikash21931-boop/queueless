import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home/presentation/home_screen.dart';
import '../domain/product.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  bool isScanning = true;
  bool isLoading = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!isScanning || isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;

      setState(() {
        isScanning = false;
        isLoading = true;
      });

      // Try fetching from backend
      Product? product = await ApiClient.fetchProductByQR(barcode.rawValue!);

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (product == null) {
        // Show error if product not found in database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Product not found in database!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Wait briefly before allowing next scan
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() {
            isScanning = true;
          });
        }
        break;
      }

      _showProductBottomSheet(product);
      break;
    }
  }

  void _showProductBottomSheet(Product product) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Add to Riverpod Cart Provider
                    ref.read(cartProvider.notifier).addProduct(product);

                    Navigator.pop(context); // Close sheet
                    // Navigate to Cart safely avoiding stack duplication
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialIndex: 2),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    setState(() {
                      isScanning = true; // Resume scanning
                    });
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        isScanning = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),

          // Custom Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppColors.primary,
                borderRadius: 24,
                borderLength: 40,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
          ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const Text(
                    'Scan Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.white),
                    onPressed: () {
                      // Toggle Flash
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Custom Path for Overlay
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 10,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path();
    path.addRect(rect);
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
        Radius.circular(borderRadius),
      ),
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final num effectiveBorderRadius = borderRadius > cutOutSize / 2
        ? cutOutSize / 2
        : borderRadius;
    final double effectiveBorderLength = borderLength > cutOutSize / 2
        ? cutOutSize / 2
        : borderLength;

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: cutOutSize,
              height: cutOutSize,
            ),
            Radius.circular(effectiveBorderRadius.toDouble()),
          ),
        ),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final pathStyle = Path();

    // Top left
    pathStyle.moveTo(
      rect.center.dx - cutOutSize / 2,
      rect.center.dy - cutOutSize / 2 + effectiveBorderLength,
    );
    pathStyle.lineTo(
      rect.center.dx - cutOutSize / 2,
      rect.center.dy - cutOutSize / 2 + borderRadius,
    );
    pathStyle.arcToPoint(
      Offset(
        rect.center.dx - cutOutSize / 2 + borderRadius,
        rect.center.dy - cutOutSize / 2,
      ),
      radius: Radius.circular(borderRadius.toDouble()),
    );
    pathStyle.lineTo(
      rect.center.dx - cutOutSize / 2 + effectiveBorderLength,
      rect.center.dy - cutOutSize / 2,
    );

    // Top right
    pathStyle.moveTo(
      rect.center.dx + cutOutSize / 2 - effectiveBorderLength,
      rect.center.dy - cutOutSize / 2,
    );
    pathStyle.lineTo(
      rect.center.dx + cutOutSize / 2 - borderRadius,
      rect.center.dy - cutOutSize / 2,
    );
    pathStyle.arcToPoint(
      Offset(
        rect.center.dx + cutOutSize / 2,
        rect.center.dy - cutOutSize / 2 + borderRadius,
      ),
      radius: Radius.circular(borderRadius.toDouble()),
    );
    pathStyle.lineTo(
      rect.center.dx + cutOutSize / 2,
      rect.center.dy - cutOutSize / 2 + effectiveBorderLength,
    );

    // Bottom right
    pathStyle.moveTo(
      rect.center.dx + cutOutSize / 2,
      rect.center.dy + cutOutSize / 2 - effectiveBorderLength,
    );
    pathStyle.lineTo(
      rect.center.dx + cutOutSize / 2,
      rect.center.dy + cutOutSize / 2 - borderRadius,
    );
    pathStyle.arcToPoint(
      Offset(
        rect.center.dx + cutOutSize / 2 - borderRadius,
        rect.center.dy + cutOutSize / 2,
      ),
      radius: Radius.circular(borderRadius.toDouble()),
    );
    pathStyle.lineTo(
      rect.center.dx + cutOutSize / 2 - effectiveBorderLength,
      rect.center.dy + cutOutSize / 2,
    );

    // Bottom left
    pathStyle.moveTo(
      rect.center.dx - cutOutSize / 2 + effectiveBorderLength,
      rect.center.dy + cutOutSize / 2,
    );
    pathStyle.lineTo(
      rect.center.dx - cutOutSize / 2 + borderRadius,
      rect.center.dy + cutOutSize / 2,
    );
    pathStyle.arcToPoint(
      Offset(
        rect.center.dx - cutOutSize / 2,
        rect.center.dy + cutOutSize / 2 - borderRadius,
      ),
      radius: Radius.circular(borderRadius.toDouble()),
    );
    pathStyle.lineTo(
      rect.center.dx - cutOutSize / 2,
      rect.center.dy + cutOutSize / 2 - effectiveBorderLength,
    );

    canvas.drawPath(pathStyle, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
