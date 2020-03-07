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

private enum PaymentBrand: Int {
    case visa
    case amex
    case mastercard
    case discover
    case jcb
    case dinersClub
    case unionPay
    case unknown
    case applePay
    
    var image: UIImage? {
        switch self {
        case .visa: return UIImage(named: "visa")
        case .mastercard: return UIImage(named: "mastercard")
        case .applePay: return UIImage(named: "apple-pay")
        default: return nil
        }
    }
}

public final class GiftCardViewController: UIViewController {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var paymentTypeButton: UIButton!
    @IBOutlet weak var paymentTypeImageView: UIImageView!
    @IBOutlet weak var activityIndicator1: UIActivityIndicatorView!
    @IBOutlet weak var paymentButton1: UIButton!
    @IBOutlet weak var activityIndicator2: UIActivityIndicatorView!
    @IBOutlet weak var paymentButton2: UIButton!
    @IBOutlet weak var activityIndicator3: UIActivityIndicatorView!
    @IBOutlet weak var paymentButton3: UIButton!
    
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    private var stripePublishableKey = "pk_test_K85SBlgfWjU4xuS0IsagbLz700YVn4uYQ2"

    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend/tree/v18.1.0, click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    private var backendBaseURL: String? = "https://peaceful-wildwood-56269.herokuapp.com"

    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    private var appleMerchantID: String = "merchant.com.geo-games.GiftCardApp"
    private var companyName = "Origon Studios"
    private var country = "United Kingdom"
    private var paymentCurrency = "GBP"
    private var paymentContext: STPPaymentContext!
    private var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    switch self.selectedIndex {
                    case 0:
                        self.activityIndicator1.startAnimating()
                        self.activityIndicator1.alpha = 1
                    case 1:
                        self.activityIndicator2.startAnimating()
                        self.activityIndicator2.alpha = 1
                    case 2:
                        self.activityIndicator3.startAnimating()
                        self.activityIndicator3.alpha = 1
                    default: break
                    }
                    
//                    self.buyButton.alpha = 0
                } else {
                    switch self.selectedIndex {
                    case 0:
                        self.activityIndicator1.stopAnimating()
                        self.activityIndicator1.alpha = 0
                    case 1:
                        self.activityIndicator2.stopAnimating()
                        self.activityIndicator2.alpha = 0
                    case 2:
                        self.activityIndicator3.stopAnimating()
                        self.activityIndicator3.alpha = 0
                    default: break
                    }
//                    self.buyButton.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    var amount: Int {
        guard let giftCard = card else { return 0 }
        let denomination = giftCard.denominations[selectedIndex]
        let result = NSDecimalNumber(decimal: denomination)
        return Int(truncating: result) * 100
    }
    
    private var selectedIndex = 0
    public var card: GiftCard?
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        paymentContextSetup()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setTitleView()
    }
    
    func paymentContextSetup() {
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
        
        let customerContext = STPCustomerContext(keyProvider: APIClient.shared)
        let config = STPPaymentConfiguration.shared()
        config.appleMerchantIdentifier = self.appleMerchantID
        config.companyName = self.companyName
        //config.requiredBillingAddressFields = settings.requiredBillingAddressFields
        //config.requiredShippingAddressFields = settings.requiredShippingAddressFields
        //config.shippingType = settings.shippingType
        //config.additionalPaymentOptions = settings.additionalPaymentOptions
        
        let paymentContext = STPPaymentContext(customerContext: customerContext,
                                               configuration: config,
                                               theme: STPTheme.default())
        paymentContext.delegate = self
        paymentContext.hostViewController = self
        paymentContext.paymentCurrency = self.paymentCurrency
        
        self.paymentContext = paymentContext

    }
    
    func setup() {
    
//        self.hero.isEnabled = true
//        self.containerView?.hero.id = "cardhero"
//        imageView?.hero.id = "cardimagehero"
        
        if let giftCard = card {
            titleLabel?.text = giftCard.name + " Gift Card"
            imageView?.image = UIImage(named: giftCard.logo.background)
            activityIndicator1.alpha = 0
            paymentButton1.isEnabled = false
            activityIndicator2.alpha = 0
            paymentButton2.isEnabled = false
            activityIndicator3.alpha = 0
            paymentButton3.isEnabled = false

        }
    }
    
    func chargePayment(at index: Int) {
        self.selectedIndex = index
        self.paymentInProgress = true
        self.paymentContext.paymentAmount = amount
        self.paymentContext.requestPayment()
    }
    
    @IBAction func selectPaymet(_ sender: UIButton) {
//        if self.navigationController != nil {
//            self.paymentContext.pushPaymentOptionsViewController()
//        } else {
            self.paymentContext.presentPaymentOptionsViewController()
//        }
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
  
    @IBAction func payOne(_ sender: UIButton) {
        chargePayment(at: 0)
    }
    
    @IBAction func payTwo(_ sender: UIButton) {
        chargePayment(at: 1)
    }
    
    @IBAction func payThree(_ sender: UIButton) {
       chargePayment(at: 2)
    }
    
}


extension GiftCardViewController: STPPaymentContextDelegate {
    enum CheckoutError: Error {
        case unknown

        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }
    
    public func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
 
        var brandType: PaymentBrand? {
            if let _ = paymentContext.selectedPaymentOption as? STPApplePayPaymentOption {
                return .applePay
            } else if let new = paymentContext.selectedPaymentOption as? STPPaymentMethod, let card = new.card {
                return PaymentBrand(rawValue: card.brand.rawValue)
            }
            return nil
        }
        
        paymentTypeImageView.image = brandType?.image
        paymentButton1.isEnabled = brandType != nil
        paymentButton2.isEnabled = brandType != nil
        paymentButton3.isEnabled = brandType != nil
        
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        APIClient.shared.charge(result: paymentResult, amount: amount, shippingAddress: nil, shippingMethod: nil) { [weak self] result in
            if let error = result.error {
                completion(.error, error)
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let self = self,
                let giftcard = self.card,
                let confirmationVC =
                storyboard.instantiateViewController(withIdentifier: "ConfirmationViewController") as? ConfirmationViewController else { return }
            let denomination = giftcard.denominations[self.selectedIndex]
            confirmationVC.setCard(card: giftcard, amount: denomination)
            self.paymentInProgress = false
            self.present(confirmationVC, animated: true, completion: nil)
            /*
            if let clientSecret = result.key, let paymentMethodId = paymentResult.paymentMethod?.stripeId {
                // Assemble the PaymentIntent parameters
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentMethodId
                
                print(paymentResult.paymentMethod?.stripeId, paymentIntentParams.paymentMethodId, paymentMethodId)

                // Confirm the PaymentIntent
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    switch status {
                    case .succeeded:
                        // Our example backend asynchronously fulfills the customer's order via webhook
                        // See https://stripe.com/docs/payments/payment-intents/ios#fulfillment
                        print(paymentIntent?.stripeId)
                        print(paymentIntent?.receiptEmail)
                        print(paymentIntent?.amount)
                        print(paymentIntent?.currency)
                        // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                        completion(.success, nil)
                    case .failed:
                        completion(.error, error) // Report error
                    case .canceled:
                        completion(.userCancellation, nil) // Customer cancelled
                    @unknown default:
                        completion(.error, nil)
                    }
                }
            }
            
            */
        }
    }
    
    // Note: this delegate method is optional. If you do not need to collect a
    // shipping method from your user, you should not implement this method.
    public func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
    
    }

    public func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "Your purchase was successful!"
        case .userCancellation:
            return()
        @unknown default:
            return()
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

}
