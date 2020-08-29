//
//  ProfileCell.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 21.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {

    @IBOutlet weak var mainImage: UIImageView!
    var index = 0
//    var previousCellAttributes
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImage.layer.cornerRadius = contentView.bounds.width / 10
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let newLayoutAttributes = layoutAttributes
        newLayoutAttributes.size.width = UIScreen.main.bounds.width / 3
        let aspectRatio = mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).width / mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        newLayoutAttributes.size.height = (UIScreen.main.bounds.width / 3) / aspectRatio
        return newLayoutAttributes
    }
}
