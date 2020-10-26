//
//  FilterCell.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var thumbnailShadow: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var filterDisplayName: UILabel!
    var filterName: String?
    var picture: UIImage?
    let context = CIContext()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailShadow.layer.masksToBounds = false
        thumbnailShadow.layer.shadowOpacity = 0.6
        thumbnailShadow.layer.shadowOffset = CGSize(width: 3, height: 3)
        thumbnailShadow.layer.shadowColor = UIColor.black.cgColor
        thumbnail.layer.cornerRadius = self.thumbnail.bounds.size.width / 2
        thumbnail.layer.borderColor = UIColor(named: "liked")?.cgColor
        thumbnail.layer.borderWidth = 5
    }

    func getFilter() {
        guard let text = filterName, let image = picture else {
            return
        }
        DispatchQueue.global(qos: .utility).async {
            let inputImage = CIImage(image: image)
            let filter = CIFilter(name: text, parameters: [kCIInputImageKey: inputImage as Any])
            let result = filter?.outputImage
            let cgImage = self.context.createCGImage(result!, from: result!.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            DispatchQueue.main.async {
                self.thumbnail.image = uiImage
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection != nil {
            if previousTraitCollection!.userInterfaceStyle == .light {
                thumbnail.layer.borderColor = UIColor(named: "liked")?.cgColor
            } else {
                thumbnail.layer.borderColor = UIColor(named: "liked")?.cgColor
            }
        }
    }
}
