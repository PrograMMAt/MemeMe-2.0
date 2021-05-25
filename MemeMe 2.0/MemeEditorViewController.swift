//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Ondrej Winter on 17/07/2020.
//  Copyright © 2020 Levit8. All rights reserved.
//
import Foundation
import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UIApplicationDelegate {

    // MARK: Properties from Storyboard
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraBarItem: UIBarButtonItem!
    @IBOutlet weak var albumBarItem: UIBarButtonItem!
    @IBOutlet weak var activityBarItem: UIBarButtonItem!
    @IBOutlet weak var topInvisibleView: UIView!
    @IBOutlet weak var memeEditorView: UIView!
    
    
    // MARK: Properties programmaticaly
    var imagePicker = UIImagePickerController()
        
    enum State {
        case launch, pickedImage, activity
    }
    
    enum TriggeredTextField {
        case top, bottom
    }
    
    
    // Meme Struct


    var resultImage: UIImage? = UIImage()
   
    //Actual state of an app
    var actualState: State = .launch
    var triggeredTextField: TriggeredTextField = .top
    
    //TextFields
    var topTextFieldOverwritten: Bool = false
    var bottomTextFieldOverwritten: Bool = false
    
    //Text - default
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.strokeWidth: -5.0,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
    ]
    
    // MARK: Custom functions

    func configureUI(UIstate: State) {
        switch UIstate {
        case .launch:
            activityBarItem.isEnabled = false
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            mainImage.image = UIImage()
            topTextFieldOverwritten = false
            bottomTextFieldOverwritten = false
            actualState = .launch
            
        case .pickedImage:
            activityBarItem.isEnabled = true
            actualState = .pickedImage
        
        case .activity:
            actualState = .activity
        }
    }
    
    func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size
    
        guard let imageSize = imgSize else {
            return CGRect.zero
        }

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)

        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
        // Center image
    
        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2

        return imageRect
    }
    
    func alignTextFields(top: UITextField, bottom: UITextField, alignment: NSTextAlignment) {
        top.textAlignment = alignment
        bottom.textAlignment = alignment
    }

    func generateMemedImage() -> UIImage {
        
        let rect = calculateRectOfImageInImageView(imageView: mainImage)
        
        // Render view to an image
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        self.view.drawHierarchy(in: CGRect(x: -rect.origin.x - memeEditorView.frame.origin.x , y: -rect.origin.y - navigationBar.frame.size.height - memeEditorView.frame.origin.y , width: view.bounds.width, height: view.bounds.height), afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return memedImage
        
        /*
         
         1) portrait mode - self.view.drawHierarchy(in: CGRect(x: -rect.origin.x ,y: -rect.origin.y - 76,width: view.bounds.size.width,height: view.bounds.size.height), afterScreenUpdates: true)

         
         2) landscape mode - self.view.drawHierarchy(in: CGRect(x: -rect.origin.x - 44 ,y: -rect.origin.y - 32,width: view.bounds.size.width,height: view.bounds.size.height), afterScreenUpdates: true) */
        
        
    }
    
    // Custom keyboard funcs
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func mainViewMinusKeyboard(notification:Notification) -> CGFloat {
        let mainViewMinusKeyboard = self.view.frame.maxY - getKeyboardHeight(notification)
        return mainViewMinusKeyboard
    }
    
    func slideUpViewIfContentOverflows(textfield: UITextField, notification:Notification) {
        if self.view.frame.origin.y == 0 {
            let yMinusKeyboard = mainViewMinusKeyboard(notification: notification)
            if yMinusKeyboard > textfield.frame.maxY {
            } else {
                view.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    
    // MARK: Body
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        imagePicker.delegate = self
        
        configureUI(UIstate: .launch)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let availability = UIImagePickerController.isSourceTypeAvailable(.camera)
        if availability == false {
            cameraBarItem.isEnabled = false
        }
        
        subscribeToKeyboardNotifications()
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        alignTextFields(top: topTextField, bottom: bottomTextField, alignment: .center)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: Keyboard functions
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        // if actualState .pickedImage -> check if View should slide up based on whether keyboard overflows textfieldr triggered textfield moved out of View
        if actualState == .pickedImage {
            if triggeredTextField == .top {
                slideUpViewIfContentOverflows(textfield: topTextField, notification: notification)
            } else if triggeredTextField == .bottom {
                slideUpViewIfContentOverflows(textfield: bottomTextField, notification: notification)
            }
        }
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        // move View back to its natural position before keyboard slid up. (unless it's already there)
        if self.view.frame.origin.y == 0 {
        } else {
        view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    // MARK: Navbar actions
    
    @IBAction func activityButtonTapped(_ sender: Any) {
    
        // generate meme Image and present activity VC, if images were shared through activity view controller save them.
        resultImage = generateMemedImage()
        let activityVc = UIActivityViewController(activityItems: [resultImage!], applicationActivities: nil)
        configureUI(UIstate: .activity)
        present(activityVc, animated: true, completion: nil)
        
        activityVc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
        Bool, arrayReturnedItems: [Any]?, error: Error?) in
            if completed {
                
                            // Create the meme
                    let meme = Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.mainImage.image!, memedImage: self.resultImage!)
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.memes.append(meme)
                
                self.dismiss(animated: true, completion: nil)
                
                self.configureUI(UIstate: .pickedImage)
                return
            } else {
                self.configureUI(UIstate: .pickedImage)
            }
            if let shareError = error {
                let controller = UIAlertController(title: "Ups", message: "Something wrong happened, please try to share the Meme again.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { action in self.dismiss(animated: true, completion: nil)
                }
                controller.addAction(action)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        configureUI(UIstate: .launch)
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Picking Images
    
    @IBAction func takeAPhoto(_ sender: Any) {
        mainImage.image = nil
        imagePicker.sourceType = .camera
        configureUI(UIstate: .pickedImage)
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectImageFrom(_ sender: Any) {
        configureUI(UIstate: .pickedImage)
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        if let image = info[.originalImage] as? UIImage {
            print("yes there is an image")
            mainImage.contentMode = .scaleAspectFit
            mainImage.image = image
            return
            }
    }

    
    // MARK: TextFields Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if actualState == .pickedImage {
            if textField == topTextField {
                triggeredTextField = .top
                if topTextFieldOverwritten {
                } else {
                    topTextField.text = ""
                }
            }
            if textField == bottomTextField {
                triggeredTextField = .bottom
                if bottomTextFieldOverwritten {
                } else {
                    bottomTextField.text = ""
                }
            }
            return true
        }
        return false
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == topTextField {
            topTextFieldOverwritten = true
        } else if textField == bottomTextField {
            bottomTextFieldOverwritten = true
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


