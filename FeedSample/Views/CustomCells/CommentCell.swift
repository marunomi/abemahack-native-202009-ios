//
//  CommentCell.swift
//  FeedSample
//
//  Created by 新井まりな on 2020/09/15.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import Foundation
import UIKit


final class CommentsCell: UITableViewCell{
    
    public let commentLabel = UILabel()
    public let userIdLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        commentLabel.numberOfLines = 0
        userIdLabel.numberOfLines = 0
        
        contentView.addSubview(commentLabel)
        contentView.addSubview(userIdLabel)
        
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        userIdLabel.leadingAnchor.constraint(equalTo:self.leadingAnchor,constant: 16).isActive = true
        userIdLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        userIdLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
        userIdLabel.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.7).isActive = true
        
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        commentLabel.leftAnchor.constraint(equalTo: userIdLabel.leftAnchor, constant: 16).isActive = true
        commentLabel.heightAnchor.constraint(equalTo: userIdLabel.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
