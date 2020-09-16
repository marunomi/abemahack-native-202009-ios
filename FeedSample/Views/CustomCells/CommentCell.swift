//
//  CommentCell.swift
//  FeedSample
//
//  Created by 新井まりな on 2020/09/15.
//  Copyright © 2020 AbemaTV, Inc. All rights reserved.
//

import Foundation
import UIKit

final class CommentsCell: UITableViewCell {

    public var commentLabel = UILabel()
    public var userIdLabel = UILabel()
    private let containerView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commentLabel.numberOfLines = 0
        userIdLabel.numberOfLines = 0

        backgroundColor = UIColor.hex(string: "000000", alpha: 1)

        containerView.backgroundColor = UIColor.hex(string: "212121", alpha: 1)
        containerView.layer.cornerRadius = 12

        containerView.addSubview(commentLabel)
        containerView.addSubview(userIdLabel)
        contentView.addSubview(containerView)

        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        userIdLabel.textColor = UIColor.hex(string: "E6E6E6", alpha: 1)
        commentLabel.textColor = UIColor.hex(string: "E6E6E6", alpha: 1)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95),
            containerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            userIdLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            userIdLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            commentLabel.leftAnchor.constraint(equalTo: userIdLabel.rightAnchor, constant: 16),
            commentLabel.heightAnchor.constraint(equalTo: userIdLabel.heightAnchor),

        ])

        /*
         containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
         containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
         containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
         containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8),
         */
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }

}

extension UIColor {
    class func hex ( string: String, alpha: CGFloat) -> UIColor {
        let string_ = string.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: string_ as String)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        } else {
            return UIColor.white
        }
    }
}
