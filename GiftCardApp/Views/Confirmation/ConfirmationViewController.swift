//
//  ConfirmationViewController.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit
import PassKit

public final class ConfirmationViewController: UIViewController {

    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var logo: Logo = .amazon
    private var amount = Decimal()
    private var selectedIndex: Int = 0
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        overrideUserInterfaceStyle = .light
        amountLabel?.text = "£ \(amount)"
        imageView?.image = UIImage(named: logo.card)
        
    }
   
    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func setAmount(value: Decimal, logo: Logo) {
        self.amount = value
        self.logo = logo
    }
}
