//
//  GetActiveSubscriptionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/11/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import StoreKit

struct GetActiveSubscriptionsUseCase {

    enum SubscriptionType: String {
        case song, beam, none
    }

    func fetch() async -> SubscriptionType {
        var activeTransactions: Set<StoreKit.Transaction> = []

        for await entitlement in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue, transaction.expirationDate?.isAfter(Date()) ?? true {
                activeTransactions.insert(transaction)
            }
        }

        if activeTransactions.contains(where: { $0.productID == SubscriptionType.song.rawValue }) {
            return .song
        } else if activeTransactions.contains(where: { $0.productID == SubscriptionType.beam.rawValue }) {
            return .beam
        }
        return .none
    }
}
