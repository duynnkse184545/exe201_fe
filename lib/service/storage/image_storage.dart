import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageStorage {
  static const String _imagePathPrefix = 'user_image_';
  
  /// Save image to app's documents directory and return the persistent path
  static Future<String?> saveImagePermanently(File imageFile, String userId) async {
    try {
      // Get the app's documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      
      // Create a unique filename with user ID
      final String fileName = '${_imagePathPrefix}${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String permanentPath = path.join(appDocPath, fileName);
      
      // Copy the file to the permanent location
      final File permanentFile = await imageFile.copy(permanentPath);
      
      // Save the path in SharedPreferences for easy retrieval
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_image_$userId', permanentFile.path);
      
      return permanentFile.path;
    } catch (e) {
      print('Error saving image permanently: $e');
      return null;
    }
  }
  
  /// Get the saved image path for a user
  static Future<String?> getSavedImagePath(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString('user_image_$userId');
      
      // Verify the file still exists
      if (imagePath != null) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          return imagePath;
        } else {
          // Clean up the preference if file doesn't exist
          await prefs.remove('user_image_$userId');
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting saved image path: $e');
      return null;
    }
  }
  
  /// Delete the saved image for a user
  static Future<bool> deleteSavedImage(String userId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString('user_image_$userId');
      
      if (imagePath != null) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
        await prefs.remove('user_image_$userId');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error deleting saved image: $e');
      return false;
    }
  }
  
  /// Clean up old image files (call this periodically)
  static Future<void> cleanupOldImages() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = appDocDir.listSync();
      
      for (FileSystemEntity file in files) {
        if (file is File && path.basename(file.path).startsWith(_imagePathPrefix)) {
          // Check if file is older than 30 days
          final DateTime fileDate = await file.lastModified();
          final DateTime now = DateTime.now();
          final Duration difference = now.difference(fileDate);
          
          if (difference.inDays > 30) {
            await file.delete();
            print('Deleted old image file: ${file.path}');
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old images: $e');
    }
  }
}