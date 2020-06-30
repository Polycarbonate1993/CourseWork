//
//  FeedCell.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 20.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class FeedCell: UICollectionViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var bigLike: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    let apiHandler = APIHandler()
    var post: Post?
    weak var delegate: FeedCellDelegate?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpView()
        
        // Initialization code
    }
    
    
    fileprivate func setUpView() {
        bigLike.isHidden = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        mainImage.addGestureRecognizer(gestureRecognizer)
        
        descriptionLabel.sizeToFit()
        
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toProfile)))
        
        username.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toProfile)))
        
        likes.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toLikes)))
    }

    @objc func doubleTap() {
        
        (delegate as? FeedViewController)?.apiHandler.get(.like, withID: post?.id, completionHandler: {likedPost in
            guard let newPost = likedPost as? Post else {
                return
            }
            self.post = newPost
            DispatchQueue.main.async {
                self.likes.text = "Likes: \(self.post!.likedByCount!)"
                self.bigLike.alpha = 0
                self.bigLike.isHidden = false
                self.likeButton.tintColor = .systemBlue
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.bigLike.alpha = 1
                }, completion: { _ in
                    self.bigLike.alpha = 1
                    UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
                        self.bigLike.alpha = 0
                    }, completion: { _ in
                        self.bigLike.alpha = 0
                        self.bigLike.isHidden = true
                    })
                })
            }
        })
        
        
        
    }
    
    @objc func toProfile() {
        delegate?.toAuthorProfile(withID: post!.author)
    }
    
    @objc func toLikes() {
        delegate?.toLikes(ofPostID: post!.id)
    }
    
    @IBAction func tappedLikeButton(_ sender: Any) {
        if likeButton.tintColor == .lightGray {
            
            (delegate as? FeedViewController)?.apiHandler.get(.like, withID: post?.id, completionHandler: {likedPost in
                guard let newPost = likedPost as? Post else {
                    return
                }
                self.post = newPost
                DispatchQueue.main.async {
                    self.likeButton.tintColor = .systemBlue
                    self.likes.text = "Likes: \(self.post!.likedByCount!)"
                }
            })

        } else {
            
            (delegate as? FeedViewController)?.apiHandler.get(.unlike, withID: post?.id, completionHandler: {unlikedPost in
                guard let newPost = unlikedPost as? Post else {
                    return
                }
                self.post = newPost
                DispatchQueue.main.async {
                    self.likeButton.tintColor = .lightGray
                    self.likes.text = "Likes: \(self.post!.likedByCount!)"
                }
            })

        }

    }
    
}

protocol FeedCellDelegate: class {
    func toAuthorProfile(withID id: String) -> Void
    func toLikes(ofPostID id: String) -> Void
}
