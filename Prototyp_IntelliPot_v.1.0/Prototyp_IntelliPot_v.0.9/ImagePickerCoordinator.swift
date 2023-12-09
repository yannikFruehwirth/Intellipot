//
//  ImagePickerCoordinator.swift
//  Prototyp_IntelliPot_v.0.9
//
//  Created by Yannik Fruehwirth on 10.10.23.
//

// Required imports for using UIKit's functionalities and handling image picking
//import UIKit

// This Coordinator class acts as the bridge between UIKit's UIImagePickerController and SwiftUI.
//class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // A reference to the parent ImagePicker SwiftUI view
    //var parent: ImagePicker
    
    // The initializer sets up the parent reference
    //init(_ parent: ImagePicker) {
        //self.parent = parent
    //}
    
    // This function gets triggered when an image has been picked.
    //func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Extract the selected image from the picker
        //if let uiImage = info[.originalImage] as? UIImage {
            // Here, you can do something with the image, like saving it or setting it to some state variable.
            // For now, we just print a message indicating an image was selected.
            //print("Image selected!")
        //}
        // Dismiss the image picker
        //parent.isPresented = false
    //}
    
    // This function gets triggered if the image picker gets cancelled.
    //func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker
        //parent.isPresented = false
    //}
//}
