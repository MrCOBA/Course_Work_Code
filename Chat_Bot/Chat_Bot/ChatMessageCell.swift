//
//  ChatMessageCell.swift
//  Chat_Bot
//
//  Created by OparinOleg on 04.01.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import UIKit

class ChatMessageCell: UITableViewCell {

    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    var trailingConstraint: NSLayoutConstraint!;
    var leadingConstraint: NSLayoutConstraint!;
    var isIncoming: Bool! {
        didSet{
            bubbleBackgroundView.backgroundColor = isIncoming ? .white : .systemGreen;
            messageLabel.textColor = isIncoming ? .black : .white;
            leadingConstraint.isActive = isIncoming;
            trailingConstraint.isActive = !isIncoming;
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        bubbleBackgroundView.backgroundColor = .lightGray
        bubbleBackgroundView.layer.cornerRadius = 12
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleBackgroundView)
        
        addSubview(messageLabel)
//        messageLabel.backgroundColor = .green
        messageLabel.text = "We want to provide a longer string that is actually going to wrap onto the next line and maybe even a third line."
        messageLabel.numberOfLines = 0
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // lets set up some constraints for our label
        let constraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
        messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
       // messageLabel.widthAnchor.constraint(equalToConstant: 180),
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            
        bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),
        bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -16),
        bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
        bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 16),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32);
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
