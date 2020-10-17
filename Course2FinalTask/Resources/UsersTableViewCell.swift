//
//  UsersTableViewCell.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 22.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher
import MastodonKit
import Streamoji

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    var user: Account?
    var emojiSource: [String: EmojiSource] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = contentView.bounds.size.height / 2
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        avatar.layer.cornerRadius = avatar.bounds.height / 2
    }
    
    func fill() {
        guard let user = user else {
            return
        }
        
        avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: user.avatar)!, cacheKey: user.avatar))
        displayName.text = user.username
        
        print("coorner: \(avatar.layer.cornerRadius), height: \(avatar.bounds.height)")
    }
}
