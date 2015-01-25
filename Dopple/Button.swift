//
//  Button.swift
//  Dopple
//
//  Created by Giles Van Gruisen on 1/24/15.
//  Copyright (c) 2015 Giles Van Gruisen. All rights reserved.
//

import UIKit
import Publinks

public class Button: UIButton {
    public var downlink = Publink<Void>()
    public var uplink = Publink<Void>()

    public override func layoutSubviews() {
        super.layoutSubviews()
        addTarget(self, action: "downPublish:", forControlEvents: .TouchDown)
        addTarget(self, action: "upPublish:", forControlEvents: .TouchUpInside)
    }

    func upPublish(sender: Button!) {
        uplink.publish()
    }

    func downPublish(sender: Button!) {
        downlink.publish()
    }
    
}
