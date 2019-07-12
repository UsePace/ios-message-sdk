//
//  MessageCenterEvents.swift
//  MessageCenter
//
//  Created by Muhamed ALGHZAWI on 29/01/2019.
//

import Foundation

enum MessageCenterEvents : String {
    
    case callTapped = "call_rider.clicked"
    case callSubmitted = "call_rider.submitted"
    case callCanceled = "call_rider.canceled"
}


extension MessageCenterEvents {
    func occurred(in channel: String, userInfo: [AnyHashable: Any]) {
        MessageCenter.delegate?.eventDidOccur(forChannel: channel, event: self, userInfo: userInfo)
    }
}
