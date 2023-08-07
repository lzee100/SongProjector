//
//  SubscriptionsManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/08/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI
import StoreKit
import StoreKitTest

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalInfo



class SubscriptionsManager: ObservableObject {
    
    enum StoreManagerError: LocalizedError {
        case noUserFound
        case verificationFailed
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .noUserFound: return "No user found"
            case .verificationFailed: return "Verification failed"
            default: return "Unknown error"
            }
        }
    }
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var renewalState: RenewalState?
    @Published private(set) var error: Error?

    private let productIds = ["beam", "song"]
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        do {
            updateListenerTask = try listenForTransactions()
        } catch {
            self.error = error
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    @MainActor
    func requestProducts() async throws {
        subscriptions = try await Product.products(for: productIds).sorted(by: { $0.id < $1.id })
        try await updateCustomerProductStatus()
        print(subscriptions)
    }
    
    @discardableResult func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        guard let user = await GetUserUseCase().get() else {
            throw StoreManagerError.noUserFound
        }

        let result = try await product.purchase()
        
        switch result {
        case .success(.verified(let transaction)):
            try await updateCustomerProductStatus()
            try await validateReceipt(transaction: transaction)
            await transaction.finish()
            return transaction
        case .success(.unverified): throw StoreManagerError.verificationFailed
        case .pending, .userCancelled: return nil
        @unknown default: throw StoreManagerError.unknown
        }
    }
    
    private func listenForTransactions() throws -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                let transaction = try self.check(result)
                try await self.updateCustomerProductStatus()
                await transaction.finish()
            }
        }
    }
    
    private func check<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreManagerError.verificationFailed
        case .verified(let result): return result
        }
    }
    
    private func updateCustomerProductStatus() async throws {
        for await result in StoreKit.Transaction.currentEntitlements {
            let transaction = try check(result)
            
            switch transaction.productType {
            case .autoRenewable:
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    if transaction.revocationDate == nil {
                        self.purchasedSubscriptions.append(subscription)
                    } else {
                        self.purchasedSubscriptions.removeAll(where: { $0.id == subscription.id })
                    }
                    print(purchasedSubscriptions)
                }
            default: break
            }
            await transaction.finish()
        }
    }
    
    private func validateReceipt(transaction: StoreKit.Transaction) async throws {
        try await VerifyPurachaseTransactionUseCase().request(transaction: transaction)
        
    }
}
