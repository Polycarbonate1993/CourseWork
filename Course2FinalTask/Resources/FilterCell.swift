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

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var filterName: UILabel!
    var picture: UIImage? {
        didSet {
            self.getFilter()
        }
    }
    let context = CIContext()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func getFilter() {
        DispatchQueue.global(qos: .utility).async {
            let processor = Kingfisher.DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))
            let thumbnailInput = processor.process(item: .image(self.picture!), options: [])
            let inputImage = CIImage(image: thumbnailInput!)
            let filter = CIFilter(name: self.filterName.text!, parameters: [kCIInputImageKey: inputImage as Any])
            let result = filter?.outputImage
            let cgImage = self.context.createCGImage(result!, from: result!.extent)
            let uiImage = UIImage(cgImage: cgImage!)
            DispatchQueue.main.async {
//                (self.filtersCollection.cellForItem(at: indexPath) as? FilterCell)?.thumbnail.image = uiImage
                
                
                self.thumbnail.image = uiImage
            }
        }
    }
}
