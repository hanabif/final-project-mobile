import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/platform_image.dart';
import '../../domain/entities/complaint.dart';
import '../cubits/complaint_cubit.dart';
import '../cubits/complaint_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/get_organizations_usecase.dart';

class ComplaintFormScreen extends StatefulWidget {
  final String? organizationId;

  const ComplaintFormScreen({
    super.key,
    this.organizationId,
  });

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, String>> _organizations = [];
  bool _isLoadingOrganizations = true;

  String? _selectedOrganizationId;
  List<XFile> _selectedImages = [];
  Position? _currentPosition;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    _getCurrentLocation();
  }

  Future<void> _loadOrganizations() async {
    try {
      final getOrganizationsUseCase = sl<GetOrganizationsUseCase>();
      final orgsResponse = await getOrganizationsUseCase.call();
      
      final mappedOrgs = orgsResponse.map((org) {
        return {
          'id': org['_id']?.toString() ?? '',
          'name': org['name']?.toString() ?? 'Unknown',
        };
      }).toList();

      if (mounted) {
        setState(() {
          _organizations = mappedOrgs;
          _isLoadingOrganizations = false;
          
          if (widget.organizationId != null) {
            final exists = _organizations.any((org) => org['id'] == widget.organizationId);
            if (exists) {
              _selectedOrganizationId = widget.organizationId;
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingOrganizations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load organizations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled.')),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          setState(() => _isGettingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permissions are permanently denied, we cannot request permissions.')),
          );
        }
        setState(() => _isGettingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
      setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          final validFiles = <XFile>[];
          for (var file in pickedFiles) {
            final length = await file.length();
            if (length <= 5 * 1024 * 1024) {
              validFiles.add(file);
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${file.name} exceeds 5MB limit')),
                );
              }
            }
          }
          setState(() {
            // Combine existing and new, taking only first 5
            _selectedImages = [..._selectedImages, ...validFiles];
            if (_selectedImages.length > 5) {
              _selectedImages = _selectedImages.sublist(0, 5);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Maximum 5 images allowed')),
              );
            }
          });
        }
      } else {
        final pickedFile = await picker.pickImage(source: source);
        if (pickedFile != null) {
          final length = await pickedFile.length();
          if (length <= 5 * 1024 * 1024) {
            setState(() {
              if (_selectedImages.length < 5) {
                _selectedImages.add(pickedFile);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Maximum 5 images allowed')),
                );
              }
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${pickedFile.name} exceeds 5MB limit')),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one image')),
        );
        return;
      }

      if (_currentPosition == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location is required')),
        );
        return;
      }

      final complaintId = const Uuid().v4();

      final complaint = Complaint(
        id: complaintId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _selectedImages.isNotEmpty ? _selectedImages.first.path : null, // Fallback for single field
        images: _selectedImages.map((e) => e.path).toList(), // Local paths for entity (will be updated by usecase)
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
      ),
      body: BlocConsumer<ComplaintCubit, ComplaintState>(
        listener: (context, state) {
          if (state is ComplaintSuccess) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Complaint submitted successfully!')),
             );
             // In a real app we'd get the actual ID from the state/response if it's generated on backend
             // For now we'll just pass a generated one.
             Navigator.of(context).pushReplacementNamed(
               RouteNames.complaintSuccess,
               arguments: const Uuid().v4().substring(0, 8).toUpperCase(),
             );
          } else if (state is ComplaintFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Complaint Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingOrganizations)
                    const Center(child: CircularProgressIndicator())
                  else if (widget.organizationId == null)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Organization',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedOrganizationId,
                      items: _organizations.map((org) {
                        return DropdownMenuItem(
                          value: org['id'],
                          child: Text(org['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrganizationId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an organization';
                        }
                        return null;
                      },
                    )
                  else
                    // Only show the header if we're hiding the dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Reporting to: ${_organizations.firstWhere((org) => org['id'] == widget.organizationId, orElse: () => {'name': widget.organizationId ?? 'Unknown'})['name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  if (_selectedImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selected Images:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: PlatformImage(
                                      path: _selectedImages[index].path,
                                      height: 120,
                                      width: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  if (_selectedImages.isEmpty)
                    const Text(
                      'No images selected (Required)',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isGettingLocation
                                ? const Center(child: CircularProgressIndicator())
                                : _currentPosition != null
                                    ? Text(
                                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}')
                                    : const Text(
                                        'Location not available',
                                        style: TextStyle(color: Colors.red),
                                      ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _getCurrentLocation,
                            tooltip: 'Refresh Location',
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedOrganizationId != null)
                    Builder(
                      builder: (context) {
                        final selectedOrg = _organizations.firstWhere(
                          (org) => org['id'] == _selectedOrganizationId,
                          orElse: () => {'name': ''},
                        );
                        final orgName = selectedOrg['name']?.toLowerCase() ?? '';
                        
                        String? callCenterText;
                        if (orgName.contains('electric')) {
                          callCenterText = 'or report through their call center 905 for Ethiopian Electric Utility';
                        } else if (orgName.contains('water') || orgName.contains('sewerage')) {
                          callCenterText = 'or report through their call center +251116674036 for Addis Ababa Water and Sewerage Authority';
                        }

                        if (callCenterText != null) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              callCenterText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: state is ComplaintSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is ComplaintSubmitting
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Submit Complaint',
                            style: TextStyle(fontSize: 16),
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
