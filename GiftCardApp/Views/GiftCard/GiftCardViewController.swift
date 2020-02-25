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
    private var stripePublishableKey = "pk_test_K85SBlgfWjU4xuS0IsagbLz700YVn4uYQ2"

    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend/tree/v18.1.0, click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    private var backendBaseURL: String? = "https://peaceful-wildwood-56269.herokuapp.com"

    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    private var appleMerchantID: String? = ""

    private var paymentContext: STPPaymentContext!
    private var paymentInProgress: Bool = false {
        didSet {
            
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
        
        if let giftCard = card {
            titleLabel?.text = giftCard.name + " Gift Card"
            imageView?.image = UIImage(named: giftCard.logo.background)
            if giftCard.denominations.count >= 2 {
                
            } else if giftCard.denominations.count >= 1 {
                
            } else if giftCard.denominations.count == 1 {
                
            } else {
                
            }
        }
    }
    
    func chargePayment(at index: Int) {
        //guard let giftCard = card else { return }
        self.selectedIndex = index
        self.paymentInProgress = true
        self.paymentContext.paymentAmount = amount
//        self.paymentContext.presentPaymentOptionsViewController()
        self.paymentContext.requestPayment()
        //self.paymentContext.presentPaymentOptionsViewController()
    }
    
    @IBAction func done(_ sender: UIButton) {
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
        
    }
    
    public func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        APIClient.shared.charge(result: paymentResult, amount: amount, shippingAddress: nil, shippingMethod: nil) { result in
            
        }
        
        /*
        // Request a PaymentIntent from your backend
        APIClient.shared.createPaymentIntent(product: self.card, shippingMethod: paymentContext.selectedShippingMethod) { result in
            switch result {
            case .success(let clientSecret):
                // Assemble the PaymentIntent parameters
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId

                // Confirm the PaymentIntent
                STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                    switch status {
                    case .succeeded:
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
            case .failure(let error):
                completion(.error, error) // Report error from your API
                break
            }
        }
 */
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


// MARK: -

extension GiftCardViewController {
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let destinationVC = segue.destination as? ConfirmationViewController, let giftCard = card else { return }
        let amount = giftCard.denominations[selectedIndex]
        destinationVC.setAmount(value: amount, logo: giftCard.logo)
    }
    
}
