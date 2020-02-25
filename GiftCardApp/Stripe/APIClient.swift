//
//  BackendAPIAdapter.swift
//  Basic Integration
//
//  Created by Ben Guo on 4/15/16.
//  Copyright © 2016 Stripe. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class APIClient: NSObject, STPCustomerEphemeralKeyProvider {
    enum APIError: Error {
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }

    static let shared = APIClient()
    
    var paymentCurrency: String = "GBP"
    var baseURLString: String? = nil
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func charge(result: STPPaymentResult, amount: Int, shippingAddress: STPAddress?, shippingMethod: PKShippingMethod?, completion: @escaping STPErrorBlock) {
        let url = self.baseURL.appendingPathComponent("charge")
        var params: [String: Any] = [
            "source": result.paymentMethod?.stripeId ?? "",
            "amount": amount,
            "currency": paymentCurrency,
            "customer_id": "cus_GmzZKoRobKM6D2"
        ]
        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<400)
            .responseString { (response) in
                switch response.result {
                case .success(let clientSecret):
                    print(clientSecret)
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        let params: [String: Any] = [
            "api_version": apiVersion,
            "customer_id": "cus_GmzZKoRobKM6D2"
        ]
        AF.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<400)
            .responseJSON{ (response) in
                switch response.result {
                case .success(let json):
                    print(json)
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    /*
    func createPaymentIntent(product: GiftCard?, shippingMethod: PKShippingMethod?, country: String? = nil, completion: @escaping ((Result<String, Error>) -> Void)) {
        let url = self.baseURL.appendingPathComponent("create_payment_intent")
        var params: [String: Any] = [
            "metadata": [
                // example-ios-backend allows passing metadata through to Stripe
                "payment_request_id": "B3E611D1-5FA1-4410-9CEC-00958A5126CB",
            ],
        ]
        params["product"] = product?.name ?? ""
        if let shippingMethod = shippingMethod {
            params["shipping"] = shippingMethod.identifier
        }
        params["country"] = country
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??),
                let secret = json?["secret"] as? String else {
                    completion(.failure(error ?? APIError.unknown))
                    return
            }
            completion(.success(secret))
        })
        task.resume()
    }

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems =
            [URLQueryItem(name: "api_version", value: apiVersion),// "2019-05-16"
             URLQueryItem(name: "customer_id", value: "cus_GmzZKoRobKM6D2")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let parameters = ["api_version" : apiVersion, "customer_id" : "cus_GmzZKoRobKM6D2"]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print("error while serialization parameters is \(error.localizedDescription)")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??)
                    else {
                completion(nil, error)
                return
            }
            print(json)
            completion(json, nil)
        })
        task.resume()
    }
 */

}
