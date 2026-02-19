// import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter/foundation.dart';

// class PermissionHelper {
//   /// Check and print current permission status for debugging
//   static Future<void> debugPermissionStatus() async {
//     if (Platform.isAndroid) {
//       final storage = await Permission.storage.status;
//       final photos = await Permission.photos.status;
//       final mediaLibrary = await Permission.mediaLibrary.status;
      
//       debugPrint('=== Permission Status ===');
//       debugPrint('Storage: $storage');
//       debugPrint('Photos: $photos');
//       debugPrint('Media Library: $mediaLibrary');
//       debugPrint('========================');
//     } else if (Platform.isIOS) {
//       final photos = await Permission.photos.status;
//       debugPrint('=== Permission Status ===');
//       debugPrint('Photos: $photos');
//       debugPrint('========================');
//     }
//   }
  
//   /// Request storage permission with proper fallback
//   static Future<bool> requestStoragePermission() async {
//     await debugPermissionStatus();
    
//     if (Platform.isAndroid) {
//       // Try multiple permissions in order
      
//       // 1. Try storage permission first (works for Android 10 and below)
//       var storageStatus = await Permission.storage.status;
//       debugPrint('Initial storage status: $storageStatus');
      
//       if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
//         debugPrint('Requesting storage permission...');
//         storageStatus = await Permission.storage.request();
//         debugPrint('After request storage status: $storageStatus');
        
//         if (storageStatus.isGranted) {
//           debugPrint('Storage permission granted!');
//           return true;
//         }
//       }
      
//       // 2. Try photos permission (Android 13+)
//       var photosStatus = await Permission.photos.status;
//       debugPrint('Photos status: $photosStatus');
      
//       if (!photosStatus.isGranted && !photosStatus.isPermanentlyDenied) {
//         debugPrint('Requesting photos permission...');
//         photosStatus = await Permission.photos.request();
//         debugPrint('After request photos status: $photosStatus');
        
//         if (photosStatus.isGranted) {
//           debugPrint('Photos permission granted!');
//           return true;
//         }
//       }
      
//       // 3. Try media library permission
//       var mediaLibraryStatus = await Permission.mediaLibrary.status;
//       debugPrint('Media library status: $mediaLibraryStatus');
      
//       if (!mediaLibraryStatus.isGranted && !mediaLibraryStatus.isPermanentlyDenied) {
//         debugPrint('Requesting media library permission...');
//         mediaLibraryStatus = await Permission.mediaLibrary.request();
//         debugPrint('After request media library status: $mediaLibraryStatus');
        
//         if (mediaLibraryStatus.isGranted) {
//           debugPrint('Media library permission granted!');
//           return true;
//         }
//       }
      
//       // Check if any permission is granted
//       if (storageStatus.isGranted || photosStatus.isGranted || mediaLibraryStatus.isGranted) {
//         debugPrint('At least one permission is granted');
//         return true;
//       }
      
//       debugPrint('All permissions denied');
//       return false;
      
//     } else if (Platform.isIOS) {
//       var status = await Permission.photos.status;
//       debugPrint('Initial photos status: $status');
      
//       if (!status.isGranted && !status.isPermanentlyDenied) {
//         debugPrint('Requesting photos permission...');
//         status = await Permission.photos.request();
//         debugPrint('After request photos status: $status');
//       }
      
//       return status.isGranted;
//     }
    
//     return false;
//   }
  
//   /// Check if permission is permanently denied
//   static Future<bool> isPermissionPermanentlyDenied() async {
//     if (Platform.isAndroid) {
//       final storageStatus = await Permission.storage.status;
//       final photosStatus = await Permission.photos.status;
//       final mediaLibraryStatus = await Permission.mediaLibrary.status;
      
//       // All must be permanently denied
//       final allPermanentlyDenied = storageStatus.isPermanentlyDenied && 
//                                     photosStatus.isPermanentlyDenied && 
//                                     mediaLibraryStatus.isPermanentlyDenied;
      
//       debugPrint('Is permanently denied: $allPermanentlyDenied');
//       debugPrint('Storage: ${storageStatus.isPermanentlyDenied}');
//       debugPrint('Photos: ${photosStatus.isPermanentlyDenied}');
//       debugPrint('Media Library: ${mediaLibraryStatus.isPermanentlyDenied}');
      
//       return allPermanentlyDenied;
//     } else if (Platform.isIOS) {
//       final status = await Permission.photos.status;
//       return status.isPermanentlyDenied;
//     }
    
//     return false;
//   }
  
//   /// Check if any storage permission is granted
//   static Future<bool> hasStoragePermission() async {
//     if (Platform.isAndroid) {
//       final storage = await Permission.storage.isGranted;
//       final photos = await Permission.photos.isGranted;
//       final mediaLibrary = await Permission.mediaLibrary.isGranted;
      
//       return storage || photos || mediaLibrary;
//     } else if (Platform.isIOS) {
//       return await Permission.photos.isGranted;
//     }
    
//     return false;
//   }
// }
