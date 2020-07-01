//
//  NewPostController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class NewPostController: UIViewController {
    
    @IBOutlet weak var photoCollection: UICollectionView!
    var photos:[UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...7 {
            photos.append(UIImage(named: "new\(i + 1)")!)
        }
        photoCollection.register(UINib(nibName: "NewPostCell", bundle: nil), forCellWithReuseIdentifier: "NewPostCell")

        photoCollection.delegate = self
        photoCollection.dataSource = self

    }
}

    // MARK: - UICollectionViewDataSource

extension NewPostController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewPostCell", for: indexPath) as! NewPostCell
        cell.photo.image = photos[indexPath.item]
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension NewPostController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? NewPostCell
        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Filters") as! FiltersController
        newVC.photo = cell?.photo.image
        newVC.thumbnail = cell?.photo.image
        let backButtonTitle = self.navigationItem.title
        self.navigationController?.pushViewController(newVC, animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
    }
}
