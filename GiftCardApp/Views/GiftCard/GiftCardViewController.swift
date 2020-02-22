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


class MyAPIClient: NSObject, STPCustomerEphemeralKeyProvider {

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = URL(string: "http://gift-cards.gift-cards.aws1-test.syrupme.net/stripe/session")!
        //self.baseURL.appendingPathComponent("ephemeral_keys")
//        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
//        urlComponents.queryItems = [URLQueryItem(name: "api_version", value: apiVersion)]
        //var request = URLRequest(url: urlComponents.url!)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??) else {
                completion(nil, error)
                return
            }
            completion(json, nil)
        })
        task.resume()
    }
}



public final class GiftCardViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var merchant: String = ""
    private var logo: Logo = .amazon
    private var denominations: [Decimal] = []
    private var selectedIndex: Int = 0
   
    
    
    //let paymentContext: STPPaymentContext!
    //let customerContext = STPCustomerContext(keyProvider: MyAPIClient())
    
    public required init?(coder: NSCoder) {
        //self.paymentContext = STPPaymentContext(customerContext: customerContext)
        super.init(coder: coder)
        setup()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
    
    func setup() {
        overrideUserInterfaceStyle = .light
        //self.paymentContext.delegate = self
        //self.paymentContext.hostViewController = self
        
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
        let amount = denominations[index]
        //self.paymentContext.presentPaymentOptionsViewController()
        //self.paymentContext.requestPayment()
        //let result = NSDecimalNumber(decimal: amount)
        //self.paymentContext.paymentAmount =  Int(truncating: result)
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

/*
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
*/

// MARK: -

extension GiftCardViewController {
    
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let destinationVC = segue.destination as? ConfirmationViewController else { return }
        let amount = denominations[selectedIndex]
        destinationVC.setAmount(value: amount, logo: logo)
    }
    
}
