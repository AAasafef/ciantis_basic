import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'background_persistence.dart';
import '../vault_upload_service.dart';

class WallpaperThemeValues {
  const WallpaperThemeValues({
    required this.primaryText,
    required this.secondaryText,
    required this.iconColor,
    required this.accent,
    required this.cardTint,
    required this.cardOpacity,
    required this.blurSigma,
    required this.dividerOpacity,
    required this.brightness,
    this.overlayColor = Colors.transparent,
    this.overlayOpacity = 0,
  });

  final Color primaryText;
  final Color secondaryText;
  final Color iconColor;
  final Color accent;
  final Color cardTint;
  final double cardOpacity;
  final double blurSigma;
  final double dividerOpacity;
  final Brightness brightness;
  final Color overlayColor;
  final double overlayOpacity;

  Map<String, Object> toJson() {
    return <String, Object>{
      'primaryText': primaryText.toARGB32(),
      'secondaryText': secondaryText.toARGB32(),
      'iconColor': iconColor.toARGB32(),
      'accent': accent.toARGB32(),
      'cardTint': cardTint.toARGB32(),
      'cardOpacity': cardOpacity,
      'blurSigma': blurSigma,
      'dividerOpacity': dividerOpacity,
      'brightness': brightness.name,
      'overlayColor': overlayColor.toARGB32(),
      'overlayOpacity': overlayOpacity,
    };
  }
}

class WallpaperOption {
  const WallpaperOption({
    required this.id,
    required this.label,
    required this.collection,
    required this.decoration,
    required this.theme,
    this.encodedImage,
  });

  final String id;
  final String label;
  final String collection;
  final BoxDecoration decoration;
  final WallpaperThemeValues theme;
  final String? encodedImage;
}

class WallpaperCatalog {
  static const WallpaperThemeValues creamTheme = WallpaperThemeValues(
    primaryText: Color(0xFF211B16),
    secondaryText: Color(0xFF5F554D),
    iconColor: Color(0xFF5F554D),
    accent: Color(0xFFC8A77C),
    cardTint: Color(0xFFF8F4EF),
    cardOpacity: 0.22,
    blurSigma: 10,
    dividerOpacity: 0.17,
    brightness: Brightness.light,
  );

  static const WallpaperThemeValues darkMountainTheme = WallpaperThemeValues(
    primaryText: Color(0xFFF7F0E8),
    secondaryText: Color(0xFFC6BDB2),
    iconColor: Color(0xFFF0E8DF),
    accent: Color(0xFFC8A77C),
    cardTint: Color(0xFF101214),
    cardOpacity: 0.58,
    blurSigma: 22,
    dividerOpacity: 0.22,
    brightness: Brightness.dark,
    overlayColor: Color(0xFF050607),
    overlayOpacity: 0.20,
  );

  static const WallpaperThemeValues archTheme = WallpaperThemeValues(
    primaryText: Color(0xFF241D18),
    secondaryText: Color(0xFF6B6158),
    iconColor: Color(0xFF6B6158),
    accent: Color(0xFFB99A74),
    cardTint: Color(0xFFFFFFFF),
    cardOpacity: 0.30,
    blurSigma: 12,
    dividerOpacity: 0.15,
    brightness: Brightness.light,
    overlayColor: Color(0xFFFFFFFF),
    overlayOpacity: 0.10,
  );

  static const WallpaperThemeValues forestTheme = WallpaperThemeValues(
    primaryText: Color(0xFFF4EFE7),
    secondaryText: Color(0xFFC7C9B8),
    iconColor: Color(0xFFEDE8DC),
    accent: Color(0xFFB9B992),
    cardTint: Color(0xFF172019),
    cardOpacity: 0.52,
    blurSigma: 20,
    dividerOpacity: 0.20,
    brightness: Brightness.dark,
    overlayColor: Color(0xFF09110C),
    overlayOpacity: 0.18,
  );

  static const WallpaperThemeValues oceanTheme = WallpaperThemeValues(
    primaryText: Color(0xFFF2F0E9),
    secondaryText: Color(0xFFC0C6CA),
    iconColor: Color(0xFFECEAE2),
    accent: Color(0xFFC6A77E),
    cardTint: Color(0xFF10171C),
    cardOpacity: 0.54,
    blurSigma: 22,
    dividerOpacity: 0.20,
    brightness: Brightness.dark,
    overlayColor: Color(0xFF0A0F14),
    overlayOpacity: 0.18,
  );

  static const WallpaperThemeValues minimalTheme = WallpaperThemeValues(
    primaryText: Color(0xFF1F1915),
    secondaryText: Color(0xFF635951),
    iconColor: Color(0xFF635951),
    accent: Color(0xFFC8A77C),
    cardTint: Color(0xFFFFFFFF),
    cardOpacity: 0.18,
    blurSigma: 8,
    dividerOpacity: 0.13,
    brightness: Brightness.light,
  );

  static final WallpaperOption defaultOption = recent.first;

  static final List<WallpaperOption> recent = <WallpaperOption>[
    const WallpaperOption(
      id: 'ciantis-cream',
      label: 'CIANTIS Cream',
      collection: 'Light',
      theme: creamTheme,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.25, -0.45),
          radius: 1.18,
          colors: [Color(0xFFF8F4EF), Color(0xFFF0EAE3), Color(0xFFE9E1D8)],
          stops: [0.0, 0.58, 1.0],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'shadow-mountain',
      label: 'Shadow Mountain',
      collection: 'Nature',
      theme: darkMountainTheme,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F3438), Color(0xFF171A1D), Color(0xFF0A0B0C)],
          stops: [0, 0.56, 1],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'quiet-arches',
      label: 'Quiet Arches',
      collection: 'Architecture',
      theme: archTheme,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.35, -0.45),
          radius: 1.05,
          colors: [Color(0xFFF8F3EC), Color(0xFFE8DED3), Color(0xFFD4C4B5)],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'smoked-marble',
      label: 'Smoked Marble',
      collection: 'Luxury',
      theme: oceanTheme,
      decoration: BoxDecoration(
        gradient: SweepGradient(
          center: Alignment(-0.2, -0.1),
          colors: [
            Color(0xFF0D1014),
            Color(0xFF26313A),
            Color(0xFF8E725C),
            Color(0xFF111318),
          ],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'soft-dunes',
      label: 'Soft Dunes',
      collection: 'Minimal',
      theme: minimalTheme,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBF7F1), Color(0xFFE4D1BE), Color(0xFFF2E9DD)],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'mist-forest',
      label: 'Mist Forest',
      collection: 'Nature',
      theme: forestTheme,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB9C0B3), Color(0xFF52634F), Color(0xFF162319)],
        ),
      ),
    ),
    const WallpaperOption(
      id: 'black-stone',
      label: 'Black Stone',
      collection: 'Dark',
      theme: darkMountainTheme,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.4, -0.7),
          radius: 1.1,
          colors: [Color(0xFF2A2520), Color(0xFF10100F), Color(0xFF030303)],
        ),
      ),
    ),
  ];

  static const List<String> collections = <String>[
    'Luxury',
    'Nature',
    'Architecture',
    'Minimal',
    'Dark',
    'Light',
    'Abstract',
    'Seasonal',
  ];

  static WallpaperOption byId(String? id) {
    return recent.firstWhere(
      (option) => option.id == id,
      orElse: () => defaultOption,
    );
  }

  static WallpaperOption forCollection(String label) {
    return recent.firstWhere(
      (option) => option.collection == label,
      orElse: () {
        return switch (label) {
          'Abstract' => recent.firstWhere(
            (option) => option.id == 'smoked-marble',
          ),
          'Seasonal' => recent.firstWhere(
            (option) => option.id == 'mist-forest',
          ),
          _ => defaultOption,
        };
      },
    );
  }

  static WallpaperOption importedFromBase64(String encodedImage) {
    final bytes = base64Decode(encodedImage);

    return WallpaperOption(
      id: 'imported-photo',
      label: 'Imported Photo',
      collection: 'Imported',
      encodedImage: encodedImage,
      theme: minimalTheme,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(Uint8List.fromList(bytes)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class BackgroundController extends ChangeNotifier {
  BackgroundController({
    BackgroundPersistence? persistence,
    String storageNamespace = 'ciantis.wallpaper',
  }) : _persistence = persistence ?? BackgroundPersistence(),
       _wallpaperKey = '$storageNamespace.id',
       _themeKey = '$storageNamespace.theme',
       _importedImageKey = '$storageNamespace.importedImage';

  final BackgroundPersistence _persistence;
  final String _wallpaperKey;
  final String _themeKey;
  final String _importedImageKey;
  WallpaperOption _selected = WallpaperCatalog.defaultOption;
  WallpaperOption? _preview;

  WallpaperOption get selected => _selected;
  WallpaperOption get active => _preview ?? _selected;
  WallpaperThemeValues get activeTheme => active.theme;

  Future<void> restore() async {
    final savedId = await _persistence.read(_wallpaperKey);
    final importedImage = await _persistence.read(_importedImageKey);
    if (savedId == 'imported-photo' && importedImage != null) {
      _selected = WallpaperCatalog.importedFromBase64(importedImage);
    } else {
      _selected = WallpaperCatalog.byId(savedId);
    }
    notifyListeners();
  }

  void preview(WallpaperOption option) {
    _preview = option;
    notifyListeners();
  }

  void cancelPreview() {
    if (_preview == null) {
      return;
    }
    _preview = null;
    notifyListeners();
  }

  Future<void> apply(WallpaperOption option) async {
    _selected = option;
    _preview = null;
    notifyListeners();
    await _persistence.write(_wallpaperKey, option.id);
    await _persistence.write(_themeKey, option.theme.toJson().toString());
    if (option.encodedImage != null) {
      await _persistence.write(_importedImageKey, option.encodedImage!);
    }
  }
}

class BackgroundControllerScope
    extends InheritedNotifier<BackgroundController> {
  const BackgroundControllerScope({
    required BackgroundController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static BackgroundController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BackgroundControllerScope>();
    assert(scope?.notifier != null, 'BackgroundControllerScope missing');
    return scope!.notifier!;
  }

  static WallpaperThemeValues themeOf(BuildContext context) {
    return of(context).activeTheme;
  }
}

class UniversalBackgroundLayer extends StatelessWidget {
  const UniversalBackgroundLayer({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final option = BackgroundControllerScope.of(context).active;
    final theme = option.theme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      decoration: option.decoration,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (theme.overlayOpacity > 0)
            ColoredBox(
              color: theme.overlayColor.withValues(alpha: theme.overlayOpacity),
            ),
          child ?? const SizedBox.expand(),
        ],
      ),
    );
  }
}

class BackgroundChangerIcon extends StatefulWidget {
  const BackgroundChangerIcon({super.key});

  @override
  State<BackgroundChangerIcon> createState() => _BackgroundChangerIconState();
}

class _BackgroundChangerIconState extends State<BackgroundChangerIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);
    final opacity = _hovering ? 0.36 : 0.22;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showWallpaperPicker(context),
        child: SizedBox(
          width: 28,
          height: 40,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 17,
              color: theme.iconColor.withValues(alpha: opacity),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showWallpaperPicker(
  BuildContext context, {
  BackgroundController? controller,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) {
      if (controller == null) {
        return const WallpaperPickerSheet();
      }

      return BackgroundControllerScope(
        controller: controller,
        child: const WallpaperPickerSheet(),
      );
    },
  );
}

class WallpaperPickerSheet extends StatefulWidget {
  const WallpaperPickerSheet({super.key});

  @override
  State<WallpaperPickerSheet> createState() => _WallpaperPickerSheetState();
}

class _WallpaperPickerSheetState extends State<WallpaperPickerSheet> {
  late WallpaperOption _draft;
  double _dragOffset = 0;
  bool _isImporting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _draft = BackgroundControllerScope.of(context).active;
  }

  @override
  Widget build(BuildContext context) {
    final controller = BackgroundControllerScope.of(context);
    final height = MediaQuery.sizeOf(context).height;

    return PopScope(
      onPopInvokedWithResult: (_, _) => controller.cancelPreview(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedSlide(
          duration: _dragOffset == 0
              ? const Duration(milliseconds: 210)
              : Duration.zero,
          curve: Curves.easeOutCubic,
          offset: Offset(0, _dragOffset / height),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                constraints: BoxConstraints(maxHeight: height * 0.72),
                decoration: BoxDecoration(
                  color: const Color(0xFF111110).withValues(alpha: 0.86),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragUpdate: (details) {
                            setState(() {
                              _dragOffset = (_dragOffset + details.delta.dy)
                                  .clamp(0.0, height * 0.55);
                            });
                          },
                          onVerticalDragEnd: (details) {
                            final fastDrag =
                                details.primaryVelocity != null &&
                                details.primaryVelocity! > 520;

                            if (_dragOffset > 56 || fastDrag) {
                              controller.cancelPreview();
                              Navigator.of(context).pop();
                              return;
                            }

                            setState(() => _dragOffset = 0);
                          },
                          child: SizedBox(
                            height: 24,
                            child: Center(
                              child: Container(
                                width: 46,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Wallpaper',
                                style: TextStyle(
                                  color: Color(0xFFF7F0E8),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.cancelPreview();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.close, size: 20),
                              color: const Color(0xFFF7F0E8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SheetLabel('Recent'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 92,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: WallpaperCatalog.recent.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final option = WallpaperCatalog.recent[index];
                              return WallpaperThumbnail(
                                option: option,
                                selected: option.id == _draft.id,
                                onTap: () {
                                  setState(() => _draft = option);
                                  controller.preview(option);
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _SheetLabel('Collections'),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final label in WallpaperCatalog.collections)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: WallpaperCollectionButton(
                                    label: label,
                                    selected: _draft.collection == label,
                                    onTap: () {
                                      final option =
                                          WallpaperCatalog.forCollection(label);
                                      setState(() => _draft = option);
                                      controller.preview(option);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _ImportPhotoRow(
                          importing: _isImporting,
                          onTap: () => _importPhoto(controller),
                        ),
                        const SizedBox(height: 24),
                        const _SheetLabel('Live Preview'),
                        const SizedBox(height: 12),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          height: 96,
                          decoration: _draft.decoration.copyWith(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFC5A378),
                              foregroundColor: const Color(0xFFFDF8F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () async {
                              try {
                                await controller.apply(_draft);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              } catch (_) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Wallpaper could not be saved. Try a smaller image.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Apply',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _importPhoto(BackgroundController controller) async {
    if (_isImporting) {
      return;
    }

    setState(() => _isImporting = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      final bytes = result?.files.single.bytes;
      if (bytes == null) {
        if (mounted) {
          setState(() => _isImporting = false);
        }
        return;
      }

      final file = result!.files.single;
      final savedImage = await const VaultUploadService().saveImage(
        bytes: bytes,
        fileName: file.name,
        source: 'Wallpaper Picker',
        mimeType: file.extension == null
            ? 'image/*'
            : 'image/${file.extension}',
      );
      final option = WallpaperCatalog.importedFromBase64(
        savedImage.encodedImage,
      );
      controller.preview(option);

      if (!mounted) {
        return;
      }

      setState(() {
        _draft = option;
        _isImporting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to Vault Images. Tap Apply to use it.'),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'That image could not be imported. Try a smaller file.',
          ),
        ),
      );
    }
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.86),
        fontFamily: 'Segoe UI',
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class WallpaperThumbnail extends StatelessWidget {
  const WallpaperThumbnail({
    required this.option,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final WallpaperOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 68,
        decoration: option.decoration.copyWith(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFD9B98D)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: selected
            ? Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1B28A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 15,
                    color: Color(0xFF211B16),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class WallpaperCollectionButton extends StatelessWidget {
  const WallpaperCollectionButton({
    required this.label,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (label) {
      'Luxury' => Icons.diamond_outlined,
      'Nature' => Icons.eco_outlined,
      'Architecture' => Icons.account_balance_outlined,
      'Minimal' => Icons.circle_outlined,
      'Dark' => Icons.dark_mode_outlined,
      'Light' => Icons.wb_sunny_outlined,
      'Abstract' => Icons.change_history_outlined,
      'Seasonal' => Icons.ac_unit_outlined,
      _ => Icons.image_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: selected ? 0.11 : 0.055),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFFD9B98D)
                : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: const Color(0xFFD2B38A), size: 19),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontFamily: 'Segoe UI',
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportPhotoRow extends StatelessWidget {
  const _ImportPhotoRow({required this.onTap, this.importing = false});

  final VoidCallback onTap;
  final bool importing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: importing ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            importing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFD2B38A),
                    ),
                  )
                : const Icon(Icons.add, color: Color(0xFFD2B38A), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                importing ? 'Importing Photo' : 'Import Photo',
                style: const TextStyle(
                  color: Color(0xFFF7F0E8),
                  fontFamily: 'Segoe UI',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.54),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class AdaptiveGlassCard extends StatelessWidget {
  const AdaptiveGlassCard({
    required this.child,
    this.padding,
    this.borderRadius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundControllerScope.themeOf(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: theme.blurSigma,
          sigmaY: theme.blurSigma,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.cardTint.withValues(alpha: theme.cardOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: theme.primaryText.withValues(alpha: theme.dividerOpacity),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
