//
//  XMPPHelper.swift
//  WeatherAppAssignment
//
//  Created by Brijesh Singh on 17/02/22.
//

import UIKit
import XMPPFramework

enum XMPPHelperError: Error {
    case wrongUserJID
}

class XMPPHelper: NSObject {
    
    var xmppStream: XMPPStream
   // var hostName = "sqli.io"
    var hostName = "hell.la"
    let userJID: XMPPJID
   // let hostPort: UInt16
    var hostPort:UInt16 = 5222

    let password: String
    
    var completionHandler: ((Bool,Error?) -> Void)?
    
    init(userJIDString: String, hostPort: UInt16 = 5222, password: String) throws {
        guard let userJID = XMPPJID(string: userJIDString) else {
            throw XMPPHelperError.wrongUserJID
        }
        self.userJID = userJID
        self.hostPort = hostPort
        self.password = password
        // Stream Configuration
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func connect(completionHandler: ((Bool,Error?) -> Void)?) {
        self.completionHandler = completionHandler
        if !self.xmppStream.isDisconnected {
            return
        }
       try? self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }

}

extension XMPPHelper: XMPPStreamDelegate {
    func xmppStreamDidConnect(_ stream: XMPPStream) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    func xmppStreamDidDisconnect(_ sender: XMPPStream, withError error: Error?) {
        print("Stream: Disconnect", error as Any)
        completionHandler?(false, error)
    }
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        completionHandler?(true, nil)
    }
}
