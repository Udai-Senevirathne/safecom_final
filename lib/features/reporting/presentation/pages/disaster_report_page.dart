import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safecom_final/features/safety/presentation/widgets/realtime_incident_reporter.dart';
import 'package:safecom_final/Core/services/image_upload_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

class DisasterReport extends StatefulWidget {
  const DisasterReport({super.key});

  @override
  State<DisasterReport> createState() => _DisasterReportState();
}

class _DisasterReportState extends State<DisasterReport> {
  String selectedDisasterType = 'Tsunami';
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isLoadingLocation = false;
  bool isUploadingImage = false;
  String? uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _autoDetectLocation();
  }

  Future<void> _autoDetectLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Convert coordinates to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = _formatAddress(place);
        locationController.text = address;
      }
    } catch (e) {
      // If location detection fails, show placeholder text
      locationController.text = '';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to detect location: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }
    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send a report',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type of disaster section
            const Text(
              'Type of disaster',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildDisasterTypeSelector(),

            const SizedBox(height: 32),

            // Select location section
            const Text(
              'Select location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildLocationSelector(),

            const SizedBox(height: 32),

            // Description section
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildDescriptionField(),

            const SizedBox(height: 32),

            // Upload image section
            const Text(
              'Upload image',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildImageUploader(),

            const SizedBox(height: 40),

            // Real-time Report submission
            RealtimeIncidentReporter(
              incidentType: 'disaster',
              selectedOption: selectedDisasterType,
              description: descriptionController.text.trim(),
              location:
                  locationController.text.trim().isEmpty
                      ? null
                      : locationController.text.trim(),
              imageUrl: uploadedImageUrl, // Now uses uploaded image URL
              onReportSubmitted: () {
                // Clear form and navigate back
                setState(() {
                  descriptionController.clear();
                  locationController.clear();
                  selectedImage = null;
                  uploadedImageUrl = null;
                  selectedDisasterType = 'Tsunami';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisasterTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            _buildDisasterOption('Tsunami'),
            const SizedBox(width: 16),
            _buildDisasterOption('Flood'),
            const SizedBox(width: 16),
            _buildDisasterOption('Landslides'),
          ],
        ),
        const SizedBox(height: 12),
        Row(children: [_buildDisasterOption('Others')]),
      ],
    );
  }

  Widget _buildDisasterOption(String type) {
    bool isSelected = selectedDisasterType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDisasterType = type;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.black : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child:
                isSelected
                    ? const Icon(Icons.circle, size: 12, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 8),
          Text(
            type,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status container
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                locationController.text.isEmpty
                    ? Colors.grey.shade100
                    : Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  locationController.text.isEmpty
                      ? Colors.grey.shade300
                      : Colors.green.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      locationController.text.isEmpty
                          ? Colors.grey.shade300
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.my_location,
                  color:
                      locationController.text.isEmpty
                          ? Colors.grey.shade600
                          : Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    isLoadingLocation
                        ? Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Detecting your location...',
                              style: TextStyle(
                                color: Colors.blue.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          locationController.text.isEmpty
                              ? 'Tap to detect your location'
                              : 'Location detected automatically',
                          style: TextStyle(
                            color:
                                locationController.text.isEmpty
                                    ? Colors.grey.shade600
                                    : Colors.green.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Location address field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: 'Location Address',
              labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              hintText: 'Enter location or use auto-detection',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isLoadingLocation
                      ? Icons.refresh
                      : Icons.my_location_outlined,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
                onPressed: isLoadingLocation ? null : _autoDetectLocation,
                tooltip: 'Detect current location',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            maxLines: 2,
            minLines: 1,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: descriptionController,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Describe the incident in detail...',
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    return Column(
      children: [
        GestureDetector(
          onTap: isUploadingImage ? null : _pickImage,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    uploadedImageUrl != null
                        ? Colors.green.shade300
                        : Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child:
                selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Image.file(
                            selectedImage!,
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          if (isUploadingImage)
                            Container(
                              color: Colors.black54,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Uploading...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (uploadedImageUrl != null && !isUploadingImage)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isUploadingImage
                              ? 'Uploading...'
                              : 'Click here to upload',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                isUploadingImage ? Colors.blue : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'JPG, PNG | Max file size 12MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
        if (selectedImage != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUploadingImage ? null : _removeImage,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      (isUploadingImage || uploadedImageUrl != null)
                          ? null
                          : _uploadImage,
                  icon:
                      uploadedImageUrl != null
                          ? const Icon(Icons.check_circle)
                          : const Icon(Icons.cloud_upload),
                  label: Text(
                    uploadedImageUrl != null
                        ? 'Uploaded'
                        : (isUploadingImage ? 'Uploading...' : 'Upload'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        uploadedImageUrl != null ? Colors.green : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
          uploadedImageUrl = null; // Reset upload status
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _removeImage() {
    setState(() {
      selectedImage = null;
      uploadedImageUrl = null;
    });
  }

  Future<void> _uploadImage() async {
    if (selectedImage == null) return;

    setState(() => isUploadingImage = true);

    try {
      // Validate file size
      final double fileSizeInMB = await ImageUploadService.getFileSizeInMB(
        selectedImage!,
      );
      if (fileSizeInMB > 12) {
        throw Exception('File size exceeds 12MB limit');
      }

      // Validate file type
      if (!ImageUploadService.isValidImageFile(selectedImage!)) {
        throw Exception('Only JPG and PNG files are allowed');
      }

      // Generate unique report ID
      final String reportId = ImageUploadService.generateReportId();

      // Upload image
      final String downloadUrl = await ImageUploadService.uploadReportImage(
        imageFile: selectedImage!,
        reportType: 'disaster',
        reportId: reportId,
      );

      setState(() {
        uploadedImageUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
