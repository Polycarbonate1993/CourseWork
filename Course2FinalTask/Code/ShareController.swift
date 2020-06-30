//
//  ShareController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 27.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

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
        // Do any additional setup after loading the view.
    }

    @objc func shareAction() {
        apiHandler.createPost(image: photoImage.image ?? UIImage(), description: descriptionFiled.text, completionHandler: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToFeed", sender: self)

                (self.tabBarController?.viewControllers?[0].children[0] as! FeedViewController).getFeed()
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ShareController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        apiHandler.createPost(image: photoImage.image ?? UIImage(), description: descriptionFiled.text, completionHandler: {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ToFeed", sender: self)

                (self.tabBarController?.viewControllers?[0].children[0] as! FeedViewController).getFeed()
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        })
        return true
    }
}
