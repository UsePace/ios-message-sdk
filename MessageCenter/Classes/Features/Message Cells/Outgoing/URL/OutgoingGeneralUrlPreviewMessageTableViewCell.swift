//
//  OutgoingGeneralUrlPreviewMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Gyeong on 6/13/17.
//  Copyright © 2017 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import FLAnimatedImage
import Alamofire



class OutgoingGeneralUrlPreviewMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate!
    
    
    @IBOutlet weak var cnImageHeight: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var previewSiteNameLabel: UILabel!
    @IBOutlet weak var previewTitleLabel: UILabel!
    @IBOutlet weak var previewDescriptionLabel: UILabel!
    @IBOutlet weak var previewThumbnailImageView: FLAnimatedImageView!
    @IBOutlet weak var previewThumbnailLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var resendMessageButton: UIButton!
    @IBOutlet weak var messageContainerView: UIView!
    @IBOutlet weak var imgMessageStatus: UIImageView!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage?
    
    var previewData: Dictionary<String, Any>!
    
    public var containerBackgroundColour: UIColor = UIColor(red: 122.0/255.0, green: 188.0/255.0, blue: 65.0/255.0, alpha: 1.0)
    
    var themeObject : ThemeObject! {
        didSet {
            
        }
    }
    
    
    static func nib() -> UINib {
        
        return UINib(nibName: String(describing: self), bundle: Bundle.bundleForXib(OutgoingGeneralUrlPreviewMessageTableViewCell.self))
//        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    @objc private func clickUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    @objc private func clickResendUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickResend(view: self, message: self.message!)
        }
    }
    
    @objc private func clickDeleteUserMessage() {
        if self.delegate != nil {
            self.delegate?.clickDelete(view: self, message: self.message!)
        }
    }
    
    @objc private func clickPreview() {
        let url: String = self.previewData["url"] as! String
        if url.count > 0 {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: url)!)
            }
        }
    }
    
    func setModel(aMessage: SBDUserMessage, channel: SBDBaseChannel?) {
        self.message = aMessage
        
        self.resendMessageButton.setTitle("ms_chat_failed_to_send".localized, for: .normal)
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            self.resendMessageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        }
        else {
            self.resendMessageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        }
        self.resendMessageButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)

        let data = self.message.data?.data(using: String.Encoding.utf8)
        do {
            self.previewData = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? Dictionary
        }
        catch let error as NSError {
            print("Details of JSON parsing error:\n \(error)")
        }
        
        let siteName = self.previewData?["site_name"] as? String
        let title = self.previewData?["title"] as? String
        let description = self.previewData?["description"] as! String
        
        let previewThumbnailImageViewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewThumbnailImageView.isUserInteractionEnabled = true
        self.previewThumbnailImageView.addGestureRecognizer(previewThumbnailImageViewTapRecognizer)
        
        let previewSiteNameLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewSiteNameLabel.isUserInteractionEnabled = true
        self.previewSiteNameLabel.addGestureRecognizer(previewSiteNameLabelTapRecognizer)
        
        let previewTitleLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewTitleLabel.isUserInteractionEnabled = true
        self.previewTitleLabel.addGestureRecognizer(previewTitleLabelTapRecognizer)
        
        let previewDescriptionLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickPreview))
        self.previewDescriptionLabel.isUserInteractionEnabled = true
        self.previewDescriptionLabel.addGestureRecognizer(previewDescriptionLabelTapRecognizer)

        self.resendMessageButton.isHidden = true
        
        self.resendMessageButton.addTarget(self, action: #selector(clickDeleteUserMessage), for: UIControl.Event.touchUpInside)
        
        // Message Status
        if self.message.channelType == CHANNEL_TYPE_GROUP {
            if self.message.messageId == 0 {
                self.imgMessageStatus.image = UIImage(named: "icMsgsent", in: Bundle.bundleForXib(OutgoingGeneralUrlPreviewMessageTableViewCell.self), compatibleWith: nil)
            }
            else {
                if let channelOfMessage = channel as? SBDGroupChannel? {
                    let unreadMessageCount = channelOfMessage?.getReadReceipt(of: self.message)
                    if unreadMessageCount == 0 {
                        // 0 means everybody has read the message
                        self.imgMessageStatus.image = UIImage(named: "icMsgread", in: Bundle.bundleForXib(OutgoingGeneralUrlPreviewMessageTableViewCell.self), compatibleWith: nil)
                    }
                    else {
                        self.imgMessageStatus.image = UIImage(named: "icMsgdelivered", in: Bundle.bundleForXib(OutgoingGeneralUrlPreviewMessageTableViewCell.self), compatibleWith: nil)
                    }
                }
            }
        }
        else {
            self.hideMessageStatus()
        }
        
        self.previewSiteNameLabel.text = siteName
        self.previewTitleLabel.text = title
        self.previewDescriptionLabel.text = description
        
        let fullMessage = self.buildMessage()
        self.messageTextView.attributedText = fullMessage
        messageContainerView.layer.cornerRadius = 8.0
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    private func buildMessage() -> NSMutableAttributedString {
        let messageAttribute = [
            NSAttributedString.Key.font: Constants.messageFont,
            NSAttributedString.Key.foregroundColor: Constants.outgoingMessageColor
        ]
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString?

        fullMessage = NSMutableAttributedString(string: message!)
        fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.count)!))
        
        return fullMessage!
    }
    
    func updateBackgroundColour () {
        self.messageContainerView.backgroundColor = self.containerBackgroundColour
    }
    
    func getHeightOfViewCell() -> CGFloat {
        self.cnImageHeight.constant = previewData["image"] == nil ? 0.0 : 85.0
        self.layoutIfNeeded()
        return 225.0 + cnImageHeight.constant
    }
    
    func hideMessageResendButton() {
        self.resendMessageButton.isHidden = true
    }
    
    func showMessageResendButton() {
        
        self.imgMessageStatus.isHidden = true
        self.resendMessageButton.isHidden = false
    }
    
    func showSendingStatus() {
        self.imgMessageStatus.isHidden = true
        self.resendMessageButton.isHidden = true
    }
    
    func showFailedStatus() {
        self.imgMessageStatus.isHidden = true
        self.messageDateLabel.isHidden = true
        self.resendMessageButton.isHidden = false
    }
    func hideMessageStatus () {
        self.messageDateLabel.isHidden = true
        self.imgMessageStatus.isHidden = true
    }
    func showMessageStatus() {
        self.imgMessageStatus.isHidden = false
        self.messageDateLabel.isHidden = false
        self.resendMessageButton.isHidden = true
    }
}
