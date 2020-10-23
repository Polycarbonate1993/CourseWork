//
//  FeedCellWithoutContent.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 24.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher
import MastodonKit
import Streamoji


class FeedCellWithoutContent: UICollectionViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var displayName: UILabel!
    let newAPIHandler = NewAPIHandler()
    var post: MutableStatus?
    var emojiSource: [String: EmojiSource] = [:]
    weak var delegate: FeedCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
        // Initialization code
    }
    
    fileprivate func setUpView() {
        avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toProfile)))
        username.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toProfile)))
        likes.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toLikes)))
//            self.contentView.layer.cornerRadius = contentView.bounds.size.width / 10
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = contentView.bounds.size.width / 10
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        mainView.backgroundColor = UIColor(named: "background")
        avatar.layer.cornerRadius = avatar.bounds.width/2
    }
        
    func fill() {
        guard let status = post else {
            return
        }
        
        avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: status.account.avatar)!, cacheKey: status.account.avatar))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        date.text = dateFormatter.string(from: status.createdAt)
        date.textColor = UIColor(named: "label")
        let attributedDescription = try? NSMutableAttributedString(data: status.content.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        if attributedDescription!.string != "" {
            attributedDescription?.deleteCharacters(in: NSRange.init(location: attributedDescription!.length - 1, length: 1))
            descriptionText.attributedText = attributedDescription
            let emojis = status.emojis
            for item in emojis {
                emojiSource[item.shortcode] = .imageUrl(item.staticURL.absoluteString)
            }
            descriptionText.configureEmojis(emojiSource, rendering: .lowestQuality)
            descriptionText.font = UIFont.init(name: "Helvetica-Bold", size: 14)
            descriptionText.textColor = UIColor(named: "label")
        } else {
            descriptionText.attributedText = nil
        }
        displayName.text = status.account.username
        displayName.textColor = UIColor(named: "label")
        likes.text = "Likes: \(status.favouritesCount)"
        likes.textColor = UIColor(named: "label")
        username.text = "@" + status.account.acct
        username.textColor = UIColor(named: "secondaryLabel")
        if status.favourited! {
            likeButton.tintColor = UIColor(named: "liked")
        } else {
            likeButton.tintColor = UIColor(named: "unliked")
        }
        self.setNeedsDisplay()
    }
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//            
//        setNeedsLayout()
//        layoutIfNeeded()
//            
//        let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
//        let newLayoutAttributes = layoutAttributes
//        newLayoutAttributes.size.width = UIScreen.main.bounds.width - 20
//        newLayoutAttributes.size.height = size.height
//        self.contentView.layer.cornerRadius = newLayoutAttributes.size.width / 10
//        return newLayoutAttributes
//    }

        // MARK: - Action handling
        
        @objc func doubleTap() {
    //        (delegate as? FeedViewController)?.apiHandler.get(.like, withID: post?.id, completionHandler: {likedPost in
    //            guard let newPost = likedPost as? Post else {
    //                return
    //            }
    //            self.post = newPost
    //            DispatchQueue.main.async {
    //                self.likes.text = "Likes: \(self.post!.likedByCount!)"
    //                self.bigLike.alpha = 0
    //                self.bigLike.isHidden = false
    //                self.likeButton.tintColor = .systemBlue
    //                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
    //                    self.bigLike.alpha = 1
    //                }, completion: { _ in
    //                    self.bigLike.alpha = 1
    //                    UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut, animations: {
    //                        self.bigLike.alpha = 0
    //                    }, completion: { _ in
    //                        self.bigLike.alpha = 0
    //                        self.bigLike.isHidden = true
    //                    })
    //                })
    //            }
    //        })
        }
        
        @objc func toProfile() {
            avatar.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
                self.avatar.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            }, completion: {_ in
                UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear], animations: {
                    self.avatar.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {_ in
                    self.avatar.isUserInteractionEnabled = true
                    self.delegate?.toAuthorProfile(withID: self.post!.account.id)
                })
            })
        }
        
        @objc func toLikes() {
            likes.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
                self.likes.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }, completion: {_ in
                UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear], animations: {
                    self.likes.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {_ in
                    self.likes.isUserInteractionEnabled = true
                    self.delegate?.toLikes(ofPostID: self.post!.id)
                })
            })
        }
        
        @IBAction func tappedLikeButton(_ sender: Any) {
            guard let post = post else {
                return
            }
            likeButton.isUserInteractionEnabled = false
            if post.favourited != nil, post.favourited! {
                UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
                    self.likeButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
                }, completion: {_ in
                    UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear], animations: {
                        self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: {_ in
                        self.newAPIHandler.unlike(postID: post.id, completion: {status in
                            guard let status = status else {
                                DispatchQueue.main.async {
                                    self.likeButton.isUserInteractionEnabled = true
                                }
                                return
                            }
//                            self.post = status
                            self.post?.favourited = status.favourited
                            self.post?.favouritesCount = status.favouritesCount == self.post?.favouritesCount ? self.post!.favouritesCount - 1 : status.favouritesCount
                            DispatchQueue.main.async {
                                self.likeButton.tintColor = UIColor(named: "unliked")
                                self.likes.text = "Likes: \(post.favouritesCount)"
                                self.likeButton.isUserInteractionEnabled = true
                            }
                        })
                    })
                })
            } else if post.favourited != nil {
                UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
                    self.likeButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
                }, completion: {_ in
                    UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear], animations: {
                        self.likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: {_ in
                        self.newAPIHandler.like(postID: post.id, completion: {status in
                            guard let status = status else {
                                DispatchQueue.main.async {
                                    self.likeButton.isUserInteractionEnabled = true
                                }
                                return
                            }
//                            self.post = status
                            self.post?.favourited = status.favourited
                            self.post?.favouritesCount = status.favouritesCount
                            DispatchQueue.main.async {
                                self.likeButton.tintColor = UIColor(named: "liked")
                                self.likes.text = "Likes: \(post.favouritesCount)"
                                self.likeButton.isUserInteractionEnabled = true
                            }
                        })
                    })
                })
            } else {
                likeButton.isUserInteractionEnabled = true
            }
        }
}
