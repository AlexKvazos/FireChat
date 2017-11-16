//
//  LoginController.swift
//  FireChat
//
//  Created by Alejandro Cavazos on 11/8/17.
//  Copyright © 2017 Alejandro Cavazos. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var messagesController: MessagesController?
    
    var inputsContainerView: UIView?
    var loginRegisterButton: UIButton?
    var nameTextField: UITextField?
    var emailTextField: UITextField?
    var passwordTextField: UITextField?
    var logoImageView: UIImageView?
    var loginRegisterSegmentedControl: UISegmentedControl?
    var inputsContainerHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(12, 12, 12)
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupNameTextField()
        setupEmailField()
        setupPasswordField()
        setupSegmentedControl()
        setupImageView()
    }
    
    func setupSegmentedControl() {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor(85, 85, 85)
        sc.selectedSegmentIndex = 1
        self.view.addSubview(sc)
        
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        
        sc.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        sc.bottomAnchor.constraint(equalTo: inputsContainerView!.topAnchor, constant: -12).isActive = true
        sc.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        sc.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        loginRegisterSegmentedControl = sc
    }
    
    @objc func handleLoginRegisterChange() {
        let index = loginRegisterSegmentedControl!.selectedSegmentIndex
        let title = loginRegisterSegmentedControl?.titleForSegment(at: index)
        loginRegisterButton?.setTitle(title, for: .normal)
        
        inputsContainerHeightAnchor!.constant = index == 0 ? 100 : 150
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField?.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: index == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField?.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField?.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: index == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }

    func setupInputsContainerView() {
        let view = UIView()

        // Styling
        view.backgroundColor = UIColor(25, 25, 25)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true

        self.view.addSubview(view)

        // Constraints
        view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        view.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -30).isActive = true
        self.inputsContainerHeightAnchor = view.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerHeightAnchor!.isActive = true
        
        self.inputsContainerView = view
    }

    func setupLoginRegisterButton() {
        let button = UIButton(type: .system)

        // Styling
        button.backgroundColor = UIColor(45, 45, 45)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)

        // Constraints
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.topAnchor.constraint(equalTo: inputsContainerView!.bottomAnchor, constant: 12).isActive = true
        button.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true

        loginRegisterButton = button
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl?.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    func handleLogin() {
        guard
            let email = emailTextField!.text,
            let password = passwordTextField!.text
            else {
                print("Form is not valid")
                return
            }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            self.messagesController?.updateNavbarTitle()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        guard
            let email = emailTextField!.text,
            let password = passwordTextField!.text,
            let name = nameTextField!.text
            else {
                print("Form is not valid")
                return
            }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let uuid = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(uuid).png")
            if let uploadData = UIImageJPEGRepresentation((self.logoImageView?.image!)!, 0.1) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    // Successfully authenticated user
                    let ref = Database.database().reference().child("users").child(uid)
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let data = ["name": name, "email": email, "profileImageUrl": profileImageUrl] as [String : Any]
                        ref.updateChildValues(data) { (error, ref) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            
                            self.messagesController?.updateNavbarTitle()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                }
            }
            
        }
            
    }
    
    func setupNameTextField() {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardAppearance = .dark
        tf.textColor = UIColor.white
        tf.attributedPlaceholder = NSAttributedString(string: tf.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(75, 75, 75)])
        inputsContainerView!.addSubview(tf)
        
        tf.leftAnchor.constraint(equalTo: inputsContainerView!.leftAnchor, constant: 12).isActive = true
        tf.topAnchor.constraint(equalTo: inputsContainerView!.topAnchor).isActive = true
        tf.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = tf.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(45, 45, 45)
        separator.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView!.addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: inputsContainerView!.leftAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: tf.bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        nameTextField = tf
    }
    
    func setupEmailField() {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.keyboardAppearance = .dark
        tf.textColor = UIColor.white
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.reloadInputViews()
        tf.attributedPlaceholder = NSAttributedString(string: tf.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(75, 75, 75)])
        inputsContainerView!.addSubview(tf)
        
        tf.leftAnchor.constraint(equalTo: inputsContainerView!.leftAnchor, constant: 12).isActive = true
        tf.topAnchor.constraint(equalTo: nameTextField!.bottomAnchor).isActive = true
        tf.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = tf.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(45, 45, 45)
        separator.translatesAutoresizingMaskIntoConstraints = false
        inputsContainerView!.addSubview(separator)
        
        separator.leftAnchor.constraint(equalTo: inputsContainerView!.leftAnchor).isActive = true
        separator.topAnchor.constraint(equalTo: tf.bottomAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        emailTextField = tf
    }
    
    func setupPasswordField() {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardAppearance = .dark
        tf.textColor = UIColor.white
        tf.isSecureTextEntry = true
        tf.attributedPlaceholder = NSAttributedString(string: tf.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(75, 75, 75)])
        inputsContainerView!.addSubview(tf)
        
        tf.leftAnchor.constraint(equalTo: inputsContainerView!.leftAnchor, constant: 12).isActive = true
        tf.topAnchor.constraint(equalTo: emailTextField!.bottomAnchor).isActive = true
        tf.widthAnchor.constraint(equalTo: inputsContainerView!.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = tf.heightAnchor.constraint(equalTo: inputsContainerView!.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        passwordTextField = tf
    }
    
    @objc func handleSelectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            logoImageView?.image = originalImage
        } else if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            logoImageView?.image = editedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func setupImageView() {
        let img = UIImageView()
        img.image = UIImage(named: "logo")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.isUserInteractionEnabled = true
        
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImage)))
        
        self.view.addSubview(img)
        
        img.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        img.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl!.topAnchor, constant: -12).isActive = true
        img.widthAnchor.constraint(equalToConstant: 250).isActive = true
        img.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        logoImageView = img
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
