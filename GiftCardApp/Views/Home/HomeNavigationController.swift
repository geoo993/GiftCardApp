//
//  HomeNavigationController.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit

public final class HomeNavigationController: UINavigationController {

    public enum UIConstant {
        static let storyboardID = "HomeNavigationController"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for:.default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
 
}
