import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/platform_image.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/complaint.dart';
import '../cubits/complaint_cubit.dart';
import '../cubits/complaint_state.dart';
import '../cubits/organizations_cubit.dart';
import '../cubits/organizations_state.dart';
import '../cubits/home/home_cubit.dart';
import '../cubits/complaint_list_cubit.dart';
import '../../../../core/di/injection_container.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String? organizationId;
  final String? title;
  final String? description;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  const ComplaintFormScreen({
    super.key,
    this.organizationId,
    this.title,
    this.description,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _titleController    = TextEditingController();
  final _descCtrl           = TextEditingController();

  String?       _selectedOrganizationId;
  List<XFile>   _selectedImages = [];
  Position?     _currentPosition;
  bool          _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.organizationId != null) {
      _selectedOrganizationId = widget.organizationId;
    }
    // Pre-fill form fields from QR data
    if (widget.title != null) {
      _titleController.text = widget.title!;
    }
    if (widget.description != null) {
      _descCtrl.text = widget.description!;
    }

     WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    context.read<OrganizationsCubit>().fetchOrganizations();
    // If QR provided coordinates, use them; otherwise get device location
    if (widget.latitude != null && widget.longitude != null) {
      _currentPosition = Position(
        longitude: widget.longitude!,
        latitude: widget.latitude!,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    } else {
      _getCurrentLocation();
    }
  });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.locationServiceRequired),
            action: SnackBarAction(
                label: l10n.locationSettings,
                onPressed: Geolocator.openLocationSettings),
          ));
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final status = await Permission.location.request();
        if (status.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text(l10n.locationPermissionsPermanentlyDenied),
              action: SnackBarAction(
                  label: l10n.locationSettings,
                  onPressed: openAppSettings),
            ));
          }
          setState(() => _isGettingLocation = false);
          return;
        }
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(l10n.locationPermissionsDenied)));
            }
            setState(() => _isGettingLocation = false);
            return;
          }
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                l10n.locationPermissionsPermanentlyDeniedNoRequest),
            action: SnackBarAction(
                label: l10n.locationSettings,
                onPressed: openAppSettings),
          ));
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition    = position;
        _isGettingLocation  = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.locationErrorPrefix}${e.toString()}')));
      }
      setState(() => _isGettingLocation = false);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final l10n   = AppLocalizations.of(context)!;
    final picker = ImagePicker();
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.cameraPermissionRequired)));
          }
          return;
        }
      } else {
        final photoStatus   = await Permission.photos.request();
        final storageStatus = await Permission.storage.request();
        if (photoStatus.isDenied && storageStatus.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.galleryPermissionRequired)));
          }
          return;
        }
      }

      if (source == ImageSource.gallery) {
        final files = await picker.pickMultiImage();
        if (files.isNotEmpty) {
          final valid = <XFile>[];
          for (final f in files) {
            if (await f.length() <= 5 * 1024 * 1024) {
              valid.add(f);
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${f.name} ${l10n.imageExceeds5MbLimitSuffix}')));
            }
          }
          setState(() {
            _selectedImages = [..._selectedImages, ...valid];
            if (_selectedImages.length > 5) {
              _selectedImages = _selectedImages.sublist(0, 5);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.maximum5ImagesAllowed)));
              }
            }
          });
        }
      } else {
        final file = await picker.pickImage(source: source);
        if (file != null) {
          if (await file.length() <= 5 * 1024 * 1024) {
            setState(() {
              if (_selectedImages.length < 5) {
                _selectedImages.add(file);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.maximum5ImagesAllowed)));
              }
            });
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${file.name} ${l10n.imageExceeds5MbLimitSuffix}')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.imagePickingErrorPrefix}${e.toString()}')));
      }
    }
  }

  void _removeImage(int index) =>
      setState(() => _selectedImages.removeAt(index));

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.locationIsRequired)));
      return;
    }
    final id = const Uuid().v4();
    final complaint = Complaint(
      id: id,
      title: _titleController.text.trim(),
      description: _descCtrl.text.trim(),
      imageUrl:
          _selectedImages.isNotEmpty ? _selectedImages.first.path : null,
      images: _selectedImages.map((e) => e.path).toList(),
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      organizationId: _selectedOrganizationId!,
      status: 'Submitted',
      category: 'Auto',
      priority: 'Low',
      department: _selectedOrganizationId!,
      createdAt: DateTime.now(),
    );
    context.read<ComplaintCubit>().submitComplaint(complaint, _selectedImages);
  }

  // ── Handle Successful Submission ──────────────────────────────────────────
  
  Future<void> _handleSuccessfulSubmission(BuildContext context, AppLocalizations l10n) async {
    try {
      // Show loading while refreshing data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.complaintSubmittedSuccessfully)),
      );

      // Refresh home statistics
      await _refreshHomeData();

      // Navigate to success screen only after data refresh completes
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(
          RouteNames.complaintSuccess,
          arguments: const Uuid().v4().substring(0, 8).toUpperCase(),
        );
      }
    } catch (e) {
      print('Error during submission handling: $e');
      // Even if refresh fails, show success screen
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(
          RouteNames.complaintSuccess,
          arguments: const Uuid().v4().substring(0, 8).toUpperCase(),
        );
      }
    }
  }

  // ── Refresh Home Data ─────────────────────────────────────────────────────
  
  Future<void> _refreshHomeData() async {
    try {
      if (mounted) {
        await context.read<HomeCubit>().loadHomeData(forceRefresh: true);
        print('✅ Home data refreshed successfully');
      }
    } catch (e) {
      print('❌ Error refreshing home data: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: l10n.submitComplaint,
        showBackButton: true,
        showThemeToggle: false,
        showNotification: false,
      ),
      body: BlocConsumer<ComplaintCubit, ComplaintState>(
        listener: (context, state) {
          if (state is ComplaintSuccess) {
            // Refresh home statistics and complaint list after successful submission
            _handleSuccessfulSubmission(context, l10n);
          } else if (state is ComplaintFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ));
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ComplaintSubmitting;
          return SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ────────────────────────────────────────────
                  _FormLabel(
                      label: l10n.complaintTitle, isDark: isDark),
                  const SizedBox(height: 8),
                  _ModernField(
                    controller: _titleController,
                    hint: l10n.complaintTitle,
                    isDark: isDark,
                    icon: Icons.title_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return l10n.titleIsRequired;
                      if (v.trim().length < 5)
                        return l10n.titleMustBeAtLeast5Characters;
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Description ──────────────────────────────────────
                  _FormLabel(
                      label: l10n.description, isDark: isDark),
                  const SizedBox(height: 8),
                  _ModernField(
                    controller: _descCtrl,
                    hint: l10n.description,
                    isDark: isDark,
                    icon: Icons.description_rounded,
                    maxLines: 5,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return l10n.descriptionIsRequired;
                      if (v.trim().length < 20)
                        return l10n
                            .descriptionMustBeAtLeast20Characters;
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Organization picker ──────────────────────────────
                  if (widget.organizationId == null) ...[
                    _FormLabel(
                        label: l10n.selectOrganization,
                        isDark: isDark),
                    const SizedBox(height: 8),
                    BlocBuilder<OrganizationsCubit, OrganizationsState>(
                      builder: (context, orgState) {
                        if (orgState is OrganizationsLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF005C45)));
                        }
                        if (orgState is OrganizationsError) {
                          return Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.failedToLoadOrganizationsPrefix}${orgState.message}',
                                style: const TextStyle(
                                    color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => context
                                    .read<OrganizationsCubit>()
                                    .fetchOrganizations(),
                                child: Text(l10n.retry),
                              ),
                            ],
                          );
                        }
                        if (orgState is OrganizationsLoaded) {
                          return _StyledDropdown(
                            value: _selectedOrganizationId,
                            hint: l10n.selectOrganization,
                            isDark: isDark,
                            items: orgState.organizations
                                .map<DropdownMenuItem<String>>(
                                    (org) => DropdownMenuItem(
                                          value:
                                              org['id'] as String,
                                          child: Text(
                                            org['name'] as String,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ))
                                .toList(),
                            onChanged: (v) => setState(
                                () => _selectedOrganizationId = v),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                    ? l10n.pleaseSelectOrganization
                                    : null,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── Images ───────────────────────────────────────────
                  _FormLabel(
                      label: l10n.attachImagesOptional,
                      isDark: isDark),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ImagePickerButton(
                          icon: Icons.camera_alt_rounded,
                          label: l10n.camera,
                          isDark: isDark,
                          onTap: () => _pickImage(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ImagePickerButton(
                          icon: Icons.photo_library_rounded,
                          label: l10n.gallery,
                          isDark: isDark,
                          onTap: () => _pickImage(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_selectedImages.isNotEmpty) ...[
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(12),
                              child: PlatformImage(
                                path: _selectedImages[i].path,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(i),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 14,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else
                    Center(
                      child: Text(
                        l10n.noImagesSelected,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : Colors.black38,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),

                  // ── Location card ─────────────────────────────────────
                  _FormLabel(label: l10n.location, isDark: isDark),
                  const SizedBox(height: 8),
                  _LocationCard(
                    isDark: isDark,
                    isGettingLocation: _isGettingLocation,
                    currentPosition: _currentPosition,
                    l10n: l10n,
                    onRefresh: _getCurrentLocation,
                  ),
                  const SizedBox(height: 18),

                  // ── Call-centre hint ──────────────────────────────────
                  if (_selectedOrganizationId != null)
                    BlocBuilder<OrganizationsCubit, OrganizationsState>(
                      builder: (context, orgState) {
                        if (orgState is OrganizationsLoaded) {
                          final orgs = orgState.organizations
                              .cast<Map<String, dynamic>>();
                          final selected = orgs.firstWhere(
                            (o) =>
                                o['id'] == _selectedOrganizationId,
                            orElse: () =>
                                <String, dynamic>{'name': ''},
                          );
                          final name =
                              (selected['name'] as String? ?? '')
                                  .toLowerCase();
                          String? hint;
                          if (name.contains('electric'))
                            hint = l10n
                                .reportThroughCallCenterElectric;
                          else if (name.contains('water') ||
                              name.contains('sewerage'))
                            hint = l10n
                                .reportThroughCallCenterWater;
                          if (hint != null) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withOpacity(0.08),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF3B82F6)
                                        .withOpacity(0.20),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_rounded,
                                        size: 16,
                                        color: Color(0xFF3B82F6)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(hint,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF3B82F6),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                  // ── Submit ────────────────────────────────────────────
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005C45),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF005C45).withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5))
                          : Text(
                              l10n.submit,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ════════════════════════════════════════════════════════════════════════════

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label, required this.isDark});
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
        ),
      );
}

class _ModernField extends StatelessWidget {
  const _ModernField({
    required this.controller,
    required this.hint,
    required this.isDark,
    required this.icon,
    required this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final IconData icon;
  final String? Function(String?) validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon,
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black.withOpacity(  0.30),
          fontSize: 14,
        ),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF1C1F2E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFF005C45), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFFEF4444), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.isDark,
    required this.items,
    required this.onChanged,
    required this.validator,
  });

  final String? value;
  final String hint;
  final bool isDark;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      validator: validator,
      onChanged: onChanged,
      dropdownColor:
          isDark ? const Color(0xFF1C1F2E) : Colors.white,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.business_rounded,
            size: 18,
            color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF1C1F2E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
              color: Color(0xFF005C45), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: items,
    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF005C45)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF005C45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.isDark,
    required this.isGettingLocation,
    required this.currentPosition,
    required this.l10n,
    required this.onRefresh,
  });

  final bool isDark;
  final bool isGettingLocation;
  final Position? currentPosition;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: currentPosition == null && !isGettingLocation
              ? const Color(0xFFEF4444).withOpacity(0.4)
              : isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (currentPosition != null
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444))
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 18,
              color: currentPosition != null
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isGettingLocation
                ? Row(
                    children: [
                      const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF005C45))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.locationServiceRequired,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black45),
                        ),
                      ),
                    ],
                  )
                : currentPosition != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.latitude}: ${currentPosition!.latitude.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '${l10n.longitude}: ${currentPosition!.longitude.toStringAsFixed(5)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        l10n.locationNotAvailable,
                        style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 13),
                      ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF005C45),
            tooltip: l10n.refreshLocation,
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}