//
//  GiftCardViewController.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Hero
import Stripe


public final class GiftCardViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    var stripePublishableKey = "pk_test_K85SBlgfWjU4xuS0IsagbLz700YVn4uYQ2"

    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend/tree/v18.1.0, click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    var backendBaseURL: String? = "https://peaceful-wildwood-56269.herokuapp.com"

    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    var appleMerchantID: String? = ""

    // These values will be shown to the user when they purchase with Apple Pay.
    var paymentCurrency: String = ""

    var paymentContext: STPPaymentContext!
    
    private var merchant: String = ""
    private var logo: Logo = .amazon
    private var denominations: [Decimal] = []
    private var selectedIndex: Int = 0
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        if let stripePublishableKey = UserDefaults.standard.string(forKey: "StripePublishableKey") {
            self.stripePublishableKey = stripePublishableKey
        }
        if let backendBaseURL = UserDefaults.standard.string(forKey: "StripeBackendBaseURL") {
            self.backendBaseURL = backendBaseURL
        }
        let stripePublishableKey = self.stripePublishableKey
        let backendBaseURL = self.backendBaseURL

        assert(stripePublishableKey.hasPrefix("pk_"), "You must set your Stripe publishable key at the top of CheckoutViewController.swift to run this app.")
        assert(backendBaseURL != nil, "You must set your backend base url at the top of CheckoutViewController.swift to run this app.")

        APIClient.shared.baseURLString = self.backendBaseURL

        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        Stripe.setDefaultPublishableKey(self.stripePublishableKey)
        /*
                let config = STPPaymentConfiguration.shared()
                config.appleMerchantIdentifier = self.appleMerchantID
                config.companyName = self.companyName
                config.requiredBillingAddressFields = settings.requiredBillingAddressFields
                config.requiredShippingAddressFields = settings.requiredShippingAddressFields
                config.shippingType = settings.shippingType
                config.additionalPaymentOptions = settings.additionalPaymentOptions
                self.country = settings.country
                self.paymentCurrency = settings.currency
                
                let customerContext = STPCustomerContext(keyProvider: APIClient.shared)
                let paymentContext = STPPaymentContext(customerContext: customerContext,
                                                       configuration: config,
                                                       theme: settings.theme)
                let userInformation = STPUserInformation()
                paymentContext.prefilledInformation = userInformation
                paymentContext.paymentAmount = products.reduce(0) { result, product in
                    return result + product.price
                }
                paymentContext.paymentCurrency = self.paymentCurrency

                let paymentSelectionFooter = PaymentContextFooterView(text:
                    """
        The sample backend attaches some test cards:

        • 4242 4242 4242 4242
            A default VISA card.

        • 4000 0000 0000 3220
            Use this to test 3D Secure 2 authentication.

        See https://stripe.com/docs/testing.
        """)
                paymentSelectionFooter.theme = settings.theme
                paymentContext.paymentOptionsViewControllerFooterView = paymentSelectionFooter

                let addCardFooter = PaymentContextFooterView(text: "You can add custom footer views to the add card screen.")
                addCardFooter.theme = settings.theme
                paymentContext.addCardViewControllerFooterView = addCardFooter

                self.paymentContext = paymentContext
        */
        let customerContext = STPCustomerContext(keyProvider: APIClient.shared)
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        setup()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        overrideUserInterfaceStyle = .light
        
//        self.hero.isEnabled = true
//        self.containerView?.hero.id = "cardhero"
//        imageView?.hero.id = "cardimagehero"
        
        titleLabel?.text = merchant + " Gift Card"
        imageView?.image = UIImage(named: logo.background)
        if denominations.count >= 2 {
            
        } else if denominations.count >= 1 {
            
        } else if denominations.count == 1 {
            
        } else {
            
        }
    }
    
    func chargePayment(at index: Int) {
        let denomination = denominations[index]
        let result = NSDecimalNumber(decimal: denomination)
        let amount = 100//Int(truncating: result) * 100
        self.paymentContext.paymentAmount = amount
        self.paymentContext.presentPaymentOptionsViewController()
        //self.paymentContext.presentPaymentOptionsViewController()
    }
    
    func set(merchant: String, logo: Logo, denominations: [Decimal]) {
        self.merchant = merchant
        self.logo = logo
        self.denominations = denominations
    }
    

    @IBAction func done(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
  
    @IBAction func payOne(_ sender: UIButton) {
        selectedIndex = 0
        chargePayment(at: selectedIndex)
    }
    
    @IBAction func payTwo(_ sender: UIButton) {
        selectedIndex = 1
        chargePayment(at: selectedIndex)
    }
    
    @IBAction func payThree(_ sender: UIButton) {
        selectedIndex = 2
       chargePayment(at: selectedIndex)
    }
    
}


extension GiftCardViewController: STPPaymentContextDelegate {
    public func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    public func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        
    }
    
}


// MARK: -

extension GiftCardViewController {
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let destinationVC = segue.destination as? ConfirmationViewController else { return }
        let amount = denominations[selectedIndex]
        destinationVC.setAmount(value: amount, logo: logo)
    }
    
}
