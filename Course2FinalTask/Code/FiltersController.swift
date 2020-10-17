//
//  FiltersController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class FiltersController: UIViewController {
    
    // MARK: - Outlets and properties
    
    
    @IBOutlet weak var imageShadowView: UIView!
    @IBOutlet weak var descriptionShadowView: UIView!
    @IBOutlet weak var imageDescription: UITextView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var filtersCollection: UICollectionView!
    @IBOutlet weak var resetButton: BackItem!
    @IBOutlet weak var postButton: BackItem!
    var apiHandler = NewAPIHandler()
    let placeholderText = "What's on your mind?"
    let context = CIContext()
    var photo: UIImage? {
        didSet {
            guard let image = photo else {
                return
            }
            let aspectRatio = image.size.width / image.size.height
            let processor = Kingfisher.DownsamplingImageProcessor(size: CGSize(width: 100, height: 100 / aspectRatio))
            let thumbnailInput = processor.process(item: .image(image), options: [])
            thumbnail = thumbnailInput
            filtersCollection.reloadData()
        }
    }
    var thumbnail: UIImage? = UIImage(named: "imagePlaceholder")
//    let context = CIContext()
    let filterQueue = DispatchQueue(label: "FiltersQueue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    let filterGroup = DispatchGroup()
    var filters = ["CIMedianFilter", "CIColorPosterize", "CIPhotoEffectChrome", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectTransfer"]
    var filterDisplayNames = ["No Noise", "Posterization", "Chrome", "Instant", "Noir", "Transfer"]
    

    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoImage.image = photo
        filtersCollection.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        apiHandler.delegate = self
        filtersCollection.delegate = self
        filtersCollection.dataSource = self
        imageDescription.delegate = self
        imageDescription.layer.cornerRadius = imageDescription.bounds.size.width / 10
        imageDescription.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 10)
        photoImage.layer.cornerRadius = photoImage.bounds.size.width / 10
        imageShadowView.layer.masksToBounds = false
        imageShadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageShadowView.layer.shadowColor = UIColor.black.cgColor
        imageShadowView.layer.shadowOpacity = 0.6
        descriptionShadowView.layer.masksToBounds = false
        descriptionShadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        descriptionShadowView.layer.shadowColor = UIColor.black.cgColor
        descriptionShadowView.layer.shadowOpacity = 0.6
        
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        photoImage.addGestureRecognizer(gestureRecognizer)
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photo = UIImage(named: "new8")
        photoImage.image = UIImage(named: "imagePlaceholder")
        imageDescription.text = placeholderText
        resetButton.isHidden = true
    }
    
    @objc func imageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func postTapped(_ sender: BackItem) {
        sender.showAnimation {
            guard let image = self.photoImage.image, image != UIImage(named: "imagePlaceholder") else {
                if let text = self.imageDescription.text, text != "" {
                    self.apiHandler.post(text: text, image: nil, completion: {
                        DispatchQueue.main.async {
                            self.tabBarController?.selectedIndex = 0
                        }
                    })
                }
                return
            }
            if let text = self.imageDescription.text, text != self.placeholderText {
                self.apiHandler.post(text: text, image: image, completion: {
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedIndex = 0
                    }
                })
            } else {
                self.apiHandler.post(text: "", image: image, completion: {
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }
    }
    @IBAction func resetTapped(_ sender: BackItem) {
        sender.showAnimation {
            self.photoImage.image = self.photo
            self.resetButton.isHidden = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection != nil {
            if previousTraitCollection!.userInterfaceStyle == .light {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
            } else {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
            }
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension FiltersController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollection.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterName = filters[indexPath.item]
        cell.filterDisplayName.text = filterDisplayNames[indexPath.item]
        cell.picture = thumbnail
        cell.getFilter()
        return cell
    }
}

    // MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension FiltersController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photo = photo else {
            return
        }
        if photo == UIImage(named: "new8") {
            return
        }
        print("orientation: \(photo.imageOrientation.rawValue)")
        let text = filters[indexPath.item]
        DispatchQueue.global(qos: .utility).async {
            let inputImage = CIImage(image: photo)
            let filter = CIFilter(name: text, parameters: [kCIInputImageKey: inputImage as Any])
            let result = filter!.outputImage!
            let cgImage = self.context.createCGImage(result, from: result.extent)
            let uiImage = UIImage(cgImage: cgImage!, scale: 1, orientation: photo.imageOrientation)
//            let uiImage2 = UIImage(ciImage: result, scale: 1, orientation: .right)
            DispatchQueue.main.async {
                self.photoImage.image = uiImage
                self.resetButton.isHidden = false
            }
        }
    }
}

extension FiltersController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        photo = image
        photoImage.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension FiltersController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == placeholderText {
            textView.text = ""
            return true
        } else if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
        }
    }
    
    
}
