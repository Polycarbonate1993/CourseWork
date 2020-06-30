//
//  FiltersController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class FiltersController: UIViewController {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var filtersCollection: UICollectionView!
    var thumbnail: UIImage?
    var photo: UIImage?
    let context = CIContext()

    let filterQueue = DispatchQueue(label: "FiltersQueue", qos: .utility, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    let filterGroup = DispatchGroup()
    var filters = ["CIHexagonalPixellate", "CILineOverlay", "CIPixellate", "CIBoxBlur", "CIPhotoEffectChrome", "CIPhotoEffectInstant", "CIPhotoEffectNoir", "CIPhotoEffectTransfer"]
    var filteredImages: [(String, UIImage)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.nextAction))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue

        photoImage.image = photo
        filtersCollection.register(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        filtersCollection.delegate = self
        filtersCollection.dataSource = self
//        getFilters()

    }

    @objc func nextAction() {
        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareController") as! ShareController
        newVC.image = photoImage.image
        let backButtonTitle = self.navigationItem.title
        self.navigationController?.pushViewController(newVC, animated: true)


        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
    }

//    func getFilters() {
//        tabBarController?.runActivityIndicatorSafe()
//        var namesImages: [(String, UIImage)] = []
//        for filterName in filters {
//            filterQueue.async(group: filterGroup) {
//
//                let inputImage = CIImage(image: self.thumbnail!)
//                let filter = CIFilter(name: filterName, parameters: [kCIInputImageKey: inputImage as Any])
//                let result = filter!.outputImage!
//                let cgImage = self.context.createCGImage(result, from: result.extent)
//                let uiImage = UIImage(cgImage: cgImage!)
//                self.filterQueue.sync {
//                    namesImages.append((filterName, uiImage))
//                }
//
//            }
//        }
//
//        filterGroup.notify(queue: DispatchQueue.main, execute: {
//            self.filteredImages = namesImages
//            self.tabBarController?.stopActivityindicatorSafe()
//            self.filtersCollection.reloadData()
//        })
//    }


}

extension FiltersController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filtersCollection.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.filterName.text = filters[indexPath.item]
        cell.picture = thumbnail
        return cell
    }
    
    
}

extension FiltersController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 120, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.tabBarController?.runActivityIndicatorSafe()
        let text = (collectionView.cellForItem(at: indexPath) as! FilterCell).filterName.text!
        DispatchQueue.global(qos: .utility).async {
            let inputImage = CIImage(image: self.photo!)
            let filter = CIFilter(name: text, parameters: [kCIInputImageKey: inputImage as Any])
            let result = filter!.outputImage!
            let cgImage = self.context.createCGImage(result, from: result.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            DispatchQueue.main.async {
                self.tabBarController?.stopActivityindicatorSafe()
                self.photoImage.image = uiImage
            }
            
        }
    }
}
