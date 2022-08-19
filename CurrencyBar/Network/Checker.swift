//
//  CurrencyConverter.swift
//  YouBar
//
//  Created by Steven J. Selcuk on 16.08.2022.
//

import Alamofire
import Foundation
import SwiftUI


struct CurrencyConvert: Codable {
    let motd: MOTD
    let success: Bool
    let query: Query
    let info: Info
    let historical: Bool
    let date: String
    var result: Double? = 0
}

// MARK: - Info

struct Info: Codable {
    var rate: Double? = 0
}

// MARK: - MOTD

struct MOTD: Codable {
    let msg: String
    let url: String
}

// MARK: - Query

struct Query: Codable {
    let from, to: String
    let amount: Double
}

final class CurrencyConverter {
    static let `default`: CurrencyConverter = CurrencyConverter()

    func convert(baseCurrency: String = "USD", toConvert: String = "USD", amount: Double = 0, completion: @escaping (Double) -> Void) {
        if Reachability.isConnectedToNetwork() == false { completion(0) }
        guard let url = URL(string: "https://api.exchangerate.host/convert?from=\(baseCurrency)&to=\(toConvert)&amount=\(String(amount))&places=2") else {
            return completion(0)
        }

        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseData { response in

            switch response.result {
            case let .success(data):
                do {
                    let result = try JSONDecoder().decode(CurrencyConvert.self, from: data)
                    completion(result.result ?? amount)

                } catch {
                    print("CurrencyConverter: Encoding error: \(error)")
                    completion(0)
                }
            case .failure:
                break
            }
        }
    }
}
