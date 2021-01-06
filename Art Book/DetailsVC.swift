//
//  DetailsVC.swift
//  Art Book
//
//  Created by Serhat Küçük on 5.01.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
  
    var selectedImageId = UUID()
    
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        
        
        selectImage.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        selectImage.addGestureRecognizer(imageTapRecognizer)
        
        //Core Data Fetch
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        let idString = selectedImageId.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    
                    if let name = result.value(forKey: "name") as? String{
                        nameTextField.text = name
                    }
                    
                    if let artist = result.value(forKey: "artist") as? String{
                        artistTextField.text = artist
                    }
                    
                    if let year = result.value(forKey: "year") as? Int{
                        yearTextField.text = String(year)
                    }
                    
                    if let imageData = result.value(forKey: "image") as? Data{
                        let image = UIImage(data: imageData)
                        selectImage.image = image
                        
                    }
                }
                saveButton.isHidden = true
                selectImage.isUserInteractionEnabled = false
                nameTextField.isUserInteractionEnabled = false
                artistTextField.isUserInteractionEnabled = false
                yearTextField.isUserInteractionEnabled = false
            }

            
        } catch  {
            print("error")
        }
        
        
        
        
    }
    
    @objc func imageTapped(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectImage.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Please fill all textfields.", message: "", preferredStyle: UIAlertController.Style.alert)
        if (nameTextField.text == "" || artistTextField.text == "" || yearTextField.text == ""){
            present(alert, animated: true, completion: nil)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alert.addAction(okButton)
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameTextField.text, forKey: "name")
        newPainting.setValue(artistTextField.text, forKey: "artist")
        if let year = Int(yearTextField.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = selectImage.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch  {
            print("error")
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    

}
