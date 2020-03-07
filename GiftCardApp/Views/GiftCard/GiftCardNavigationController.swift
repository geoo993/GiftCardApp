//
//  GiftCardNavigationController.swift
//  GiftCardApp
//
//  Created by GEORGE QUENTIN on 07/03/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit

class GiftCardNavigationController: UINavigationController {

    public enum UIConstant {
        static let storyboardID = "GiftCardViewController"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for:.default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}
