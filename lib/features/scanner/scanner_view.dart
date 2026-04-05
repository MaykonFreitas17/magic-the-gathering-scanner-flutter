import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/utils/legality_helper.dart';
import '../../services/database_service.dart';
import '../../services/scryfall_service.dart';
import '../details/card_detail_view.dart';

class ScannerView extends StatefulWidget {
  final int? targetDeckId;
  final String? deckFormat;
  final String? targetBoard;

  const ScannerView({
    super.key,
    this.targetDeckId,
    this.deckFormat,
    this.targetBoard,
  });

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasPermission = false;
  bool _isProcessing = false;

  // Controle de Auto-Scan
  bool _isAutoScanEnabled = false;
  Timer? _autoScanTimer;

  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final ScryfallService _apiService = ScryfallService();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInitCamera();
  }

  Future<void> _requestPermissionAndInitCamera() async {
    final status = await Permission.camera.request();

    if (!mounted) return;

    if (status.isGranted) {
      setState(() => _hasPermission = true);
      _initCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'A taverna precisa de permissão para usar o Olho do Oráculo.',
          ),
        ),
      );
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Erro ao iniciar câmera: $e');
    }
  }

  void _toggleAutoScan(bool value) {
    setState(() {
      _isAutoScanEnabled = value;
    });

    if (_isAutoScanEnabled) {
      _autoScanTimer = Timer.periodic(const Duration(milliseconds: 2500), (
        timer,
      ) {
        if (!_isProcessing) {
          _scanCard(isAuto: true);
        }
      });
    } else {
      _autoScanTimer?.cancel();
    }
  }

  Future<void> _scanCard({bool isAuto = false}) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      if (recognizedText.blocks.isEmpty) {
        if (!isAuto) {
          _showError('Não consegui ler. Tente melhorar a iluminação!');
        }
        return;
      }

      String possibleCardName = recognizedText.blocks.first.text
          .replaceAll('\n', ' ')
          .trim();

      debugPrint('🔍 Tentando: $possibleCardName');

      final response = await _apiService.getCards(name: possibleCardName);

      if (response != null && response.cards.isNotEmpty) {
        final magicCard = response.cards.first;

        if (widget.targetDeckId != null) {
          if (LegalityHelper.isLegal(magicCard, widget.deckFormat!)) {
            await DatabaseService.instance.addCardToDeck(
              widget.targetDeckId!,
              magicCard,
              widget.deckFormat!,
              boardType: widget.targetBoard ?? 'main', // PASSA A INFORMAÇÃO!
            );
            _showSuccess(
              'Adicionada ao ${widget.targetBoard == "sideboard" ? "Sideboard" : "Main"}: ${magicCard.name}',
            );
          } else {
            _showError(
              'Esta carta não é válida no formato ${widget.deckFormat}',
            );
          }
          return;
        }

        if (mounted) {
          _autoScanTimer?.cancel();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailView(card: magicCard),
            ),
          );

          if (mounted && _isAutoScanEnabled) {
            _toggleAutoScan(true);
          }
        }
      } else {
        if (!isAuto) {
          _showError(
            'Não encontrei: "$possibleCardName". Tente alinhar melhor!',
          );
        }
      }
    } catch (e) {
      debugPrint('Erro no scan: $e');
      if (!isAuto) _showError('Distúrbio na mana ao ler a carta.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.greenAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _autoScanTimer?.cancel();
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return const Center(
        child: Text('Permissão negada.', style: TextStyle(color: Colors.white)),
      );
    }
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          if (!_isProcessing) _scanCard(isAuto: false);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(_cameraController!),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.7),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.0, -0.6),
                    child: Container(
                      height: 60,
                      width: screenSize.width * 0.85,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const Alignment(0.0, -0.6),
              child: Container(
                height: 60,
                width: screenSize.width * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isProcessing ? Colors.greenAccent : Colors.orange,
                    width: _isProcessing ? 3 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0.0, -0.4),
              child: Text(
                _isProcessing ? 'Lendo o Oráculo...' : 'Alinhe e TOQUE NA TELA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Auto-Scan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _isAutoScanEnabled,
                      activeThumbColor: Colors.orange,
                      onChanged: _toggleAutoScan,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
