//
//  ExchangeRates.swift
//  ExchangeRates
//
//  Created by SaikiranK on 13/02/21.
//  Copyright © 2021 Saikiran Komirishetty. All rights reserved.
//

import Foundation

// MARK: - ExchangeRates
struct ExchangeRates: Codable {
    let success: Bool
    let terms, privacy: String
    let timestamp: Int
    let source: String
    let quotes: [String: Double]
}
