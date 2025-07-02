import 'package:flutter/material.dart';
import 'package:safecom_final/Core/services/auth_service.dart';
import 'package:safecom_final/Core/services/firebase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PersonalInfoContent extends StatefulWidget {
  const PersonalInfoContent({super.key});

  @override
  State<PersonalInfoContent> createState() => _PersonalInfoContentState();
}

class _PersonalInfoContentState extends State<PersonalInfoContent> {
  String? selectedGender;
  File? selectedImage;
  String? existingPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nicController = TextEditingController();
  final _locationController = TextEditingController();
  bool isLoading = true;

  final List<Map<String, dynamic>> genderOptions = [
    {'value': 'male', 'label': 'Male', 'icon': Icons.male},
    {'value': 'female', 'label': 'Female', 'icon': Icons.female},
    {'value': 'other', 'label': 'Other', 'icon': Icons.transgender},
    {
      'value': 'prefer_not_to_say',
      'label': 'Prefer not to say',
      'icon': Icons.help_outline,
    },
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 [PersonalEdit] Widget initialized');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print('🔍 [PersonalEdit] Loading user data...');
    try {
      final userData = await AuthService.getUserData();
      final prefs = await SharedPreferences.getInstance();
      print('🔍 [PersonalEdit] User data loaded: ${userData.keys}');

      setState(() {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        existingPhotoUrl = userData['photoUrl'];
        // Load saved gender from SharedPreferences
        selectedGender = prefs.getString('user_gender');
        isLoading = false;
      });
      print('🔍 [PersonalEdit] UI state updated, isLoading: $isLoading');
    } catch (e) {
      print('🔴 [PersonalEdit] Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nicController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔍 [PersonalEdit] Building widget, isLoading: $isLoading');
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.arrow_back, color: Colors.red.shade600, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      GestureDetector(
                        onTap: _showImagePickerOptions,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Profile Picture
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red.shade100,
                                        width: 3,
                                      ),
                                    ),
                                    child: _buildProfileAvatar(),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red.shade600,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                selectedImage != null
                                    ? 'New Picture Selected'
                                    : (existingPhotoUrl?.isNotEmpty == true
                                        ? 'Tap to Change Picture'
                                        : 'Tap to Add Picture'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      selectedImage != null
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Form Section
                      Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildModernTextField(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'NIC Number',
                        icon: Icons.credit_card,
                        controller: _nicController,
                      ),
                      const SizedBox(height: 16),
                      _buildModernLocationField(),
                      const SizedBox(height: 16),
                      _buildGenderSelection(),

                      const SizedBox(height: 32),

                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildModernTextField(
                        label: 'Mobile Number',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              );

                              try {
                                // Handle profile photo changes
                                if (selectedImage != null) {
                                  // Upload new profile photo
                                  final photoUrl =
                                      await FirebaseService.uploadProfileImage(
                                        selectedImage!,
                                      );
                                  if (photoUrl != null) {
                                    await AuthService.updateUserPhotoUrl(
                                      photoUrl,
                                    );
                                    // Update the local state immediately
                                    setState(() {
                                      existingPhotoUrl = photoUrl;
                                      selectedImage =
                                          null; // Clear selected image since it's now saved
                                    });
                                  }
                                } else if (existingPhotoUrl == null &&
                                    (await AuthService.getUserData())['photoUrl']
                                            ?.isNotEmpty ==
                                        true) {
                                  // Remove profile photo if user removed it
                                  await FirebaseService.removeProfileImage();
                                  await AuthService.updateUserPhotoUrl('');
                                  // Update the local state immediately
                                  setState(() {
                                    existingPhotoUrl = null;
                                  });
                                }

                                // Update profile using AuthService
                                final success = await AuthService.updateProfile(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                );

                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close loading dialog

                                  if (success) {
                                    // Reload user data to ensure everything is in sync
                                    await _loadUserData();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Profile updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                    Navigator.of(
                                      context,
                                    ).pop(); // Go back to profile
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Failed to update profile',
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Close loading dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.red.shade400, size: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildModernLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _locationController,
        decoration: InputDecoration(
          labelText: 'Location',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: Colors.red.shade400,
            size: 20,
          ),
          suffixIcon: Icon(
            Icons.my_location,
            color: Colors.red.shade400,
            size: 20,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedGender,
        decoration: InputDecoration(
          labelText: 'Gender',
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(Icons.wc, color: Colors.red.shade400, size: 20),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        hint: Text(
          'Select your gender',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.red.shade400),
        dropdownColor: Colors.white,
        items:
            genderOptions.map((gender) {
              return DropdownMenuItem<String>(
                value: gender['value'] as String,
                child: Row(
                  children: [
                    Icon(
                      gender['icon'] as IconData,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      gender['label'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedGender = newValue;
          });
          // Save gender selection to SharedPreferences
          if (newValue != null) {
            _saveGender(newValue);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your gender';
          }
          return null;
        },
      ),
    );
  }

  // Save gender selection to SharedPreferences
  Future<void> _saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_gender', gender);
  }

  // Build profile avatar widget
  Widget _buildProfileAvatar() {
    print(
      '🔍 [PersonalEdit] Building avatar - selectedImage: ${selectedImage != null}, existingPhotoUrl: $existingPhotoUrl',
    );

    ImageProvider? imageProvider;
    Widget? child;

    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
      print('🔍 [PersonalEdit] Using selected image');
    } else if (existingPhotoUrl?.isNotEmpty == true) {
      imageProvider = NetworkImage(existingPhotoUrl!);
      print('🔍 [PersonalEdit] Using existing photo URL: $existingPhotoUrl');
    } else {
      print('🔍 [PersonalEdit] Using default person icon');
      child = Icon(Icons.person, size: 50, color: Colors.grey.shade600);
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: imageProvider,
      child: child,
    );
  }

  // Request camera permission
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  // Request photo library permission
  Future<bool> _requestPhotosPermission() async {
    // Try different permissions based on platform
    PermissionStatus status;

    // For newer Android versions, try photos permission first
    status = await Permission.photos.request();
    if (status == PermissionStatus.granted) {
      return true;
    }

    // Fallback to storage permission for older Android versions
    status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      return true;
    }

    // For some devices, try media library permission
    status = await Permission.mediaLibrary.request();
    return status == PermissionStatus.granted;
  }

  // Show image picker options
  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    'Camera',
                    Icons.camera_alt,
                    () => _pickImage(ImageSource.camera),
                  ),
                  _buildImageOption(
                    'Gallery',
                    Icons.photo_library,
                    () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              // Add remove option if user has existing photo
              if (selectedImage != null ||
                  existingPhotoUrl?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _buildImageOption(
                  'Remove',
                  Icons.delete,
                  () => _removePhoto(),
                  isDestructive: true,
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? Colors.red.shade400 : Colors.red.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isDestructive ? Colors.red.shade700 : Colors.red.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isDestructive ? Colors.red.shade700 : Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close bottom sheet

    // Try to pick image first, handle permissions if needed
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });

        _showSuccessMessage('Profile picture selected successfully!');
      }
    } catch (e) {
      // If picking fails, it might be due to permissions
      print('Image picker error: $e');

      bool hasPermission = false;

      if (source == ImageSource.camera) {
        hasPermission = await _requestCameraPermission();
        if (!hasPermission) {
          _showPermissionDialog('Camera', 'camera access');
          return;
        }
      } else {
        hasPermission = await _requestPhotosPermission();
        if (!hasPermission) {
          _showPermissionDialog('Photos', 'photo library access');
          return;
        }
      }

      // Try again after getting permission
      if (hasPermission) {
        try {
          final XFile? image = await _picker.pickImage(
            source: source,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );

          if (image != null) {
            setState(() {
              selectedImage = File(image.path);
            });

            _showSuccessMessage('Profile picture selected successfully!');
          }
        } catch (e2) {
          _showErrorMessage('Error selecting image: ${e2.toString()}');
        }
      }
    }
  }

  // Remove photo
  void _removePhoto() {
    Navigator.pop(context); // Close bottom sheet
    setState(() {
      selectedImage = null;
      existingPhotoUrl = null;
    });
    _showSuccessMessage(
      'Profile picture removed. Don\'t forget to save changes.',
    );
  }

  // Show permission dialog
  void _showPermissionDialog(String permissionType, String usage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionType Permission Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SafeCom needs $usage to update your profile picture.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please grant permission in your device settings:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Go to Settings\n2. Find SafeCom app\n3. Enable $permissionType permission',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings(); // Opens device settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
