//
//  GiftCard.swift
//  GiftCardApp
//
//  Created by George Quentin Ngounou on 20/02/2020.
//  Copyright © 2020 Quidco. All rights reserved.
//

import Foundation

enum Logo {
    case amazon
    case argos
    case debenhams
    case google
    case itunes
    case caffeNero
    case pizzaExpress
    case primark
    case starbucks
    case tesco
    case uber
    case virgin
    
    var card: String {
        switch self {
        case .amazon: return "amazon card"
        case .argos: return "argos card"
        case .debenhams: return "debenhams card"
        case .google: return "google card"
        case .itunes: return "itunes card"
        case .caffeNero: return "nero card"
        case .pizzaExpress: return "pizza card"
        case .primark: return "primark card"
        case .starbucks: return "starbucks card"
        case .tesco: return "tesco card"
        case .uber: return "uber card"
        case .virgin: return "virgin card"
        }
    }
    
    var background: String {
        switch self {
        case .amazon: return "amazon group card"
        case .argos: return "argos group card"
        case .debenhams: return "debenhams group card"
        case .google: return "google group card"
        case .itunes: return "itunes group card"
        case .caffeNero: return "nero group card"
        case .pizzaExpress: return "pizza group card"
        case .primark: return "primark group card"
        case .starbucks: return "starbucks group card"
        case .tesco: return "tesco group card"
        case .uber: return "uber group card"
        case .virgin: return "virgin group card"
        }
    }
}

struct GiftCard {
    let id: UInt
    let name: String
    let logo: Logo
    let denomination: [Decimal]
}

