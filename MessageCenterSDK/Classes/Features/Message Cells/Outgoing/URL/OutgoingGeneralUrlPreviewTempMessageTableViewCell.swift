//
//  OutgoingGeneralUrlPreviewTempMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 6/15/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OutgoingGeneralUrlPreviewTempMessageTableViewCell: UITableViewCell {
    
    
    
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageLabel: UITextView!
    @IBOutlet weak var previewLoadingIndicator: UIActivityIndicatorView!
    
    var message: OutgoingGeneralUrlPreviewTempModel?
    var prevMessage: SBDBaseMessage?
    
    public var containerBackgroundColour: UIColor = UIColor(red: 122.0/255.0, green: 188.0/255.0, blue: 65.0/255.0, alpha: 1.0)
    
    static func nib() -> UINib {
        
        let podBundle = Bundle.bundleForXib(OutgoingGeneralUrlPreviewTempMessageTableViewCell.self)
        return UINib(nibName: String(describing: self), bundle: podBundle)
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    func setModel(aMessage: OutgoingGeneralUrlPreviewTempModel) {
        self.message = aMessage
        
        let fullMessage = self.buildMessage()
        
        self.messageLabel.attributedText = fullMessage
        
        self.previewLoadingIndicator.startAnimating()
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        let messageAttribute = [
            NSAttributedString.Key.font: Constants.messageFont
        ]
        
        let message = self.message?.message
        
        let fullMessage = NSMutableAttributedString.init(string: message!)
        fullMessage.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.count)!))
        
        return fullMessage
    }
    func updateBackgroundColour () {
        self.messageContainer.backgroundColor = self.containerBackgroundColour
    }
    func getHeightOfViewCell() -> CGFloat {        
        let fullMessage = self.buildMessage()
        let heightOfString = fullMessage.height(withConstrainedWidth: UIScreen.main.bounds.size.width - 120.0)
        return heightOfString + 40.0
    }
    
}
