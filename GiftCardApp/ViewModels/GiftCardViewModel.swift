//
//  GiftCardViewModel.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class GiftCardViewModel {
    
    // MARK: - Properties

    private(set) lazy var cards = BehaviorRelay<[GiftCard]>(value: [])
    let isRefreshing = BehaviorRelay<Bool>(value: false)

    fileprivate let queue = DispatchQueue(label: "DataManager.queue", qos: .utility)

    private func createError(message: String, code: Int) -> Error {
        return NSError(domain: "dataManager", code: code, userInfo: ["message": message ])
    }

    
    // MARK: - Private properties
    
    //private let homeDataProvider = MSMHomeDataProvider()
    private var mockCards: [GiftCard] {
        let denominations = [Decimal(10), Decimal(25), Decimal(50)]
        return [
            GiftCard(id: 1, name: "Amazon Gift Certificate", logo: .amazon, denominations: denominations),
            GiftCard(id: 2, name: "Tesco In-store", logo: .tesco, denominations: denominations),
            GiftCard(id: 3, name: "Debenhams", logo: .debenhams, denominations: denominations),
            GiftCard(id: 4, name: "Argos", logo: .argos, denominations: denominations),
            GiftCard(id: 5, name: "Starbucks", logo: .starbucks, denominations: denominations),
            GiftCard(id: 6, name: "iTunes", logo: .itunes, denominations: denominations),
            GiftCard(id: 7, name: "Uber", logo: .uber, denominations: denominations),
            GiftCard(id: 8, name: "Primark", logo: .primark, denominations: denominations),
            GiftCard(id: 9, name: "Google Play", logo: .google, denominations: denominations),
            GiftCard(id: 10, name: "Virgin Experience Days", logo: .virgin, denominations: denominations),
            GiftCard(id: 11, name: "Caffè Nero", logo: .caffeNero, denominations: denominations),
            GiftCard(id: 12, name: "Pizza Express", logo: .pizzaExpress, denominations: denominations),
        ]
    }

    // MARK: - Initializer
    
    init() {
        
    }
    
    // MARK: - Internal functions
    
    func reload() {
        guard isRefreshing.value == false else { return }
        isRefreshing.accept(true)
        fetchGiftCards()
    }
    
    // MARK: - Private functions

    private func fetchGiftCards() {
        
        let completion: ([GiftCard]) -> Void = { [weak self] (result) in
            self?.isRefreshing.accept(false)
            self?.cards.accept(result)
        }
        
        //getBrands(completion: completion)
        //searchRequest(closure: nil)
        self.cards.accept(mockCards)
        self.isRefreshing.accept(false)
        
        /*
        if let userId = authorizationController.userID, authorizationController.authorized {
            MSMAnalyticsController.fetchBool(forRemoteConfiguration: .merchantBannerEnabled) { [weak self] (isEnabled) in
                self?.homeDataProvider.fetchAuthenticatedOffers(for: userId, isMerchantBannerEnabled: isEnabled) { [weak self] (result) in
                    if let error = result.error, error.isAuthenticationRequired {
                        self?.homeDataProvider.fetchUnauthenticatedOffers(isMerchantBannerEnabled: isEnabled, completion: completion)
                    } else {
                        completion(result)
                    }
                }
            }
        } else {
            MSMAnalyticsController.fetchBool(forRemoteConfiguration: .merchantBannerEnabled) { [weak self] (isEnabled) in
                self?.homeDataProvider.fetchUnauthenticatedOffers(isMerchantBannerEnabled: isEnabled, completion: completion)
            }
        }
        */
    }
    
    func getBrands(completion: @escaping (([GiftCard]) -> Void)) {
        guard let url = URL(string: "https://gift-cards.qco-9658-gift-cards.aws1-test.syrupme.net/api/brands") else {
            completion([])
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            print(response)
            print(data)
            print(error)
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]) as [String : Any]??) else {
                completion([])
                return
            }
            print(json)
            
            //completion(json)
        })
        task.resume()
    }

    private func make(session: URLSession = URLSession.shared, request: URLRequest, closure: ((_ json: [String: Any]?, _ error: Error?)->Void)?) {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.queue.async {
                let complete: (_ json: [String: Any]?, _ error: Error?) ->() = { json, error in DispatchQueue.main.async { closure?(json, error) } }

                guard let self = self, error == nil else { complete(nil, error); return }
                guard let data = data else { complete(nil, self.createError(message: "No data", code: 999)); return }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        complete(json, nil)
                    }
                } catch let error { complete(nil, error); return }
            }
        }

        task.resume()
    }

    func searchRequest(closure: ((_ json: [String: Any]?, _ error: Error?)->Void)?) {
        //let url = URL(string: "https://itunes.apple.com/search?term=\(term.replacingOccurrences(of: " ", with: "+"))")
        let url = URL(string: "https://gift-cards.local.syrupme.net/api/brands/")
        let request = URLRequest(url: url!)
        make(request: request) { json, error in closure?(json, error) }
    }
    
//    func makeRequest(with url: URL) throws -> URLRequest {
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        return request
//    }
//
//    func check() {
//
//        let requestURL = URL(string: "https://gift-cards.local.syrupme.net/api/brands/")!
//        let request =  makeRequest(with: requestURL)
//        let task = session?.dataTask(with: request) { (data, urlResponse, error) in
//            completionHandler(request, urlResponse as? HTTPURLResponse, data, error)
//        }
//        task?.resume()
//        return task
//    }
}
