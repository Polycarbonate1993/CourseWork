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
//    var previousCellAttributes
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainImage.layer.cornerRadius = contentView.bounds.width / 10
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let newLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        setNeedsLayout()
        layoutIfNeeded()
//        let newLayoutAttributes = layoutAttributes
        newLayoutAttributes.size.width = UIScreen.main.bounds.width / 2
        let aspectRatio = mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).width / mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        newLayoutAttributes.size.height = (UIScreen.main.bounds.width / 3) / aspectRatio
        print("blah blah")
        return newLayoutAttributes
    }
}
