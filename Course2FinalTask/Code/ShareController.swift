//
//  ShareController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 27.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import CoreData

class ShareController: UIViewController {

    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var descriptionFiled: UITextField!
    var image: UIImage?
    let apiHandler = APIHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        apiHandler.delegate = self
        photoImage.image = image
        descriptionFiled.delegate = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.shareAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }

    @objc func shareAction() {
        apiHandler.createPost(image: photoImage.image ?? UIImage(), description: descriptionFiled.text, completionHandler: {post in
            guard let post = post else {
                self.generateAlert(title: "Oops!", message: "There is no post.", buttonTitle: "OK")
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToFeed", sender: self)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
}

    // MARK: - UITextFieldDelegate

extension ShareController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        apiHandler.createPost(image: photoImage.image ?? UIImage(), description: descriptionFiled.text, completionHandler: {post in
            guard let post = post else {
                self.generateAlert(title: "Oops!", message: "There is no post.", buttonTitle: "OK")
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToFeed", sender: self)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        return true
    }
}
