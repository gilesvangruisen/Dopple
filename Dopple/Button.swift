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
    public var downlink = Publink<Button>()
    public var uplink = Publink<Button>()

    public override func layoutSubviews() {
        super.layoutSubviews()
        addTarget(self, action: "downPublish:", forControlEvents: .TouchDown)
        addTarget(self, action: "upPublish:", forControlEvents: .TouchUpInside)
    }

    func upPublish(sender: Button!) {

        self.layer.removeAllAnimations()
        uplink.publish(self)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 30, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)

    }

    func downPublish(sender: Button!) {

        self.layer.removeAllAnimations()
        downlink.publish(self)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 30, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            self.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1)
            }, completion: nil)

    }
    
}
