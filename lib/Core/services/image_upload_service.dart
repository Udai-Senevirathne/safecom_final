import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image to Firebase Storage and return the download URL
  static Future<String> uploadReportImage({
    required File imageFile,
    required String reportType, // 'disaster' or 'harassment'
    required String reportId, // Unique identifier for the report
  }) async {
    try {
      // Validate file size (12MB limit)
      final int fileSizeInBytes = await imageFile.length();
      const int maxSizeInBytes = 12 * 1024 * 1024; // 12MB

      if (fileSizeInBytes > maxSizeInBytes) {
        throw Exception('File size exceeds 12MB limit');
      }

      // Get file extension
      final String fileExtension = path.extension(imageFile.path).toLowerCase();

      // Validate file type
      const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];
      if (!allowedExtensions.contains(fileExtension)) {
        throw Exception('Only JPG and PNG files are allowed');
      }

      // Create unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName =
          '${reportType}_${reportId}_$timestamp$fileExtension';

      // Define storage path
      final String storagePath = 'reports/$reportType/$fileName';

      // Create storage reference
      final Reference storageRef = _storage.ref().child(storagePath);

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
        customMetadata: {
          'reportType': reportType,
          'reportId': reportId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });

      // Wait for upload completion
      final TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      print('Image uploaded successfully: $downloadURL');
      return downloadURL;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      throw Exception('Upload failed: ${e.message}');
    } catch (e) {
      print('General Upload Error: $e');
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteReportImage(String downloadURL) async {
    try {
      // Get reference from download URL
      final Reference storageRef = _storage.refFromURL(downloadURL);

      // Delete the file
      await storageRef.delete();
      print('Image deleted successfully: $downloadURL');
    } on FirebaseException catch (e) {
      print('Firebase Storage Delete Error: ${e.code} - ${e.message}');
      throw Exception('Delete failed: ${e.message}');
    } catch (e) {
      print('General Delete Error: $e');
      throw Exception('Delete failed: $e');
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  /// Generate unique report ID
  static String generateReportId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    final String extension = path.extension(file.path).toLowerCase();
    const List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];
    return allowedExtensions.contains(extension);
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final int bytes = await file.length();
    return bytes / (1024 * 1024);
  }
}
