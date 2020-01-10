//
//  ViewController.swift
//  InceptionTest
//
//  Created by Manuel Carvalho on 9/1/20.
//  Copyright © 2020 Manuel Carvalho. All rights reserved.
//

import UIKit
import CoreML
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var listML = [VNClassificationObservation]()

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3_2().model) else {
            fatalError("Loading CoreML model failed.")
        }
        
        let request = VNCoreMLRequest(model: model){ (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
        }
            self.listML = results
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "list", sender: nil)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "list"
        {
            if let destinationVC = segue.destination as? TableTableViewController {
                destinationVC.list = listML
            }
        }
    }
    
}

