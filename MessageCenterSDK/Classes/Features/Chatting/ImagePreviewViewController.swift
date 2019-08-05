//
//  ImagePreviewViewController.swift
//  MessageCenter
//
//  Created by Ikarma Khan on 14/12/2018.
//

import UIKit
import IQKeyboardManagerSwift

protocol ImagePreviewProtocol: class {
    func imagePreviewDidDismiss(_ image: UIImage? , caption: String)
}

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var messageInputView: SBMessageInputView!
    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var vwGradient: UIView!
    @IBOutlet weak var inputViewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    private var keyboardShown: Bool = false
    
    var strCaption: String = ""
    var imageToUpload : UIImage?
    var shouldShowCaption: Bool = true
    weak var delegate: ImagePreviewProtocol?
    var theme: ThemeObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSend.layer.cornerRadius = 22.0
        self.imgPicture.image = imageToUpload!
        
        if UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft {
            if let sendBtnImage = self.btnSend.imageView {
                sendBtnImage.transform = sendBtnImage.transform.rotated(by: CGFloat(Double.pi))
            }
            
        }
        
        self.messageInputView.textView.text = strCaption
        messageInputView.layer.borderColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.12).cgColor
        self.messageInputView.layer.cornerRadius = 8.0
        self.messageInputView.layer.masksToBounds = true
        self.messageInputView.layer.borderWidth = 1.0
        self.messageInputView.delegate = self
        self.lblCaption.isHidden = strCaption.count > 0
        self.lblCaption.text = "caption".localized
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        if self.shouldShowCaption == false {
            self.bottomView.removeFromSuperview()
        }
        
        let closeImg = UIImage(named: "btn_close", in: Bundle.bundleForXib(ImagePreviewViewController.self), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.btnDismiss.setImage(closeImg, for: .normal)
        self.btnDismiss.tintColor = self.theme?.primaryActionIconsColor
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeKeyboardObservers()
    }
    func createGradientLayer() {
//        let gradientLayer = CAGradientLayer()
//        let startColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.52)
//        let endColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//        
//        gradientLayer.frame = self.imgPicture.bounds
//        
//        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
//        gradientLayer.locations = [0.0, 0.20]
//        self.imgPicture.layer.addSublayer(gradientLayer)
        if self.shouldShowCaption == true {
            self.imgPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        }
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            view.endEditing(true)
        }
        //sender.cancelsTouchesInView = false
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func addObservers() {
        removeKeyboardObservers()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        self.keyboardShown = true
        var offset = 0.0
        if #available(iOS 11.0, *   ) {
            offset =  Double(view.safeAreaInsets.bottom)
        }
        let keyboardInfo = notification.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        
        // FIXME:  Make it optional
        
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.bottomMargin.constant = keyboardFrameBeginRect.size.height - CGFloat(offset)
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (status) in
                
            })
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        self.keyboardShown = false
        
        DispatchQueue.main.async {
            self.bottomMargin?.constant = 0
            
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveLinear, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (status) in
                
            })
        }
    }
    
    
    @IBAction func btnDismissTapped(_ sender: Any) {
        removeKeyboardObservers()
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        self.view.endEditing(true)
        strCaption = messageInputView?.textView.text ?? ""
        if strCaption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            strCaption = ""
        }
        if self.delegate != nil {
            self.delegate?.imagePreviewDidDismiss(self.imageToUpload, caption: strCaption)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}


extension ImagePreviewViewController : UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        strCaption = textView.text!
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }        
        return true
    }
    
}

extension ImagePreviewViewController: SBMessageInputViewDelegate {
    func inputViewDidTapButton(button: UIButton) {
        
    }
    func inputViewDidBeginEditing(textView: UITextView) {
        if UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft {
            textView.contentInset = UIEdgeInsets(top: textView.contentInset.top, left: 0.0, bottom: 0.0, right: 0.0)
        }
        else {
            textView.contentInset = UIEdgeInsets(top: textView.contentInset.top, left: 0.0, bottom: 0.0, right: 0.0)
        }
        textView.layoutIfNeeded()
    }
    
    func inputViewShouldBeginEditing(textView: UITextView) -> Bool {
        IQKeyboardManager.shared.enableAutoToolbar = false
        return true
    }
    
    func inputView(textView: UITextView, shouldChangeTextInRange: NSRange, replacementText: String) -> Bool {
        return true
    }
    
    func inputViewDidChange(textView: UITextView) {
        
        if textView.text.count > 0  {
            self.lblCaption.isHidden = true
        }
        else {
            self.lblCaption.isHidden = false
        }
    }
}

extension ImagePreviewViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {        
        return self.imgPicture
    }
    
}
