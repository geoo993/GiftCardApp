//
//  ViewController+Ext.swift
//  GiftCardApp
//
//  Created by GEORGE QUENTIN on 07/03/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var leftBarFrame: CGRect? {
        if let barButtonItem = self.navigationItem.leftBarButtonItem, let buttonItemView = barButtonItem.value(forKey: "view") as? UIView {
            return buttonItemView.frame
        }
        return nil
    }
    
    var rightBarFrame: CGRect? {
        if let barButtonItem = self.navigationItem.leftBarButtonItem, let buttonItemView = barButtonItem.value(forKey: "view") as? UIView {
            return buttonItemView.frame
        }
        return nil
    }
    
    func setTitleView() {
        var titleView: UIImageView? {
            guard let image = UIImage(named: "Wizgift") else { return nil }
            let imageView = UIImageView(image: image)
            let frame: CGRect
            if let navigationController = self.navigationController, let leftFrame = leftBarFrame {
                let bannerWidth = navigationController.navigationBar.frame.size.width
                let bannerHeight = navigationController.navigationBar.frame.size.height
                let bannerX = (bannerWidth / 2 - image.size.width / 2)
                let bannerY = bannerHeight / 2 - image.size.height / 2
                frame = CGRect(x: bannerX - leftFrame.size.width, y: bannerY, width: bannerWidth, height: bannerHeight)
            } else if let navigationController = self.navigationController {
                let bannerWidth = navigationController.navigationBar.frame.size.width
                let bannerHeight = navigationController.navigationBar.frame.size.height
                let bannerX = bannerWidth / 2 - image.size.width / 2
                let bannerY = bannerHeight / 2 - image.size.height / 2
                frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
            } else {
                let defaultSize = CGSize(width: 129, height: 63)
                let bannerX = defaultSize.width / 2 - image.size.width / 2
                let bannerY = defaultSize.height / 2 - image.size.height / 2
                frame = CGRect(x: bannerX, y: bannerY, width: defaultSize.width, height: defaultSize.height)
            }
            //imageView.frame = frame
            imageView.contentMode = .scaleAspectFit
            
            return imageView
        }
        self.navigationItem.titleView = titleView
    }
    
    
}
