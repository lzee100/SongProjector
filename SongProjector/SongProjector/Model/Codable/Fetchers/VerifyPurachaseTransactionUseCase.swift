//
//  VerifyPurachaseTransactionUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/08/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import StoreKit

protocol RefresherDelegate {
    func didRefresh()
}

class Refresher: NSObject, SKRequestDelegate {

    var delegate: RefresherDelegate?

    func refresh() {
        let bla = SKReceiptRefreshRequest(receiptProperties: nil)
        bla.delegate = self
        bla.start()
    }

    func requestDidFinish(_ request: SKRequest) {
        delegate?.didRefresh()
    }

}

actor VerifyPurachaseTransactionUseCase: ObservableObject, RefresherDelegate {
    nonisolated func didRefresh() {
        Task {
            if let transaction = await transaction {
                try? await request(transaction: transaction)
            }
        }
    }
    
    
    @Published private(set) var isFetching = false
    private let endpoint = "verifyAppleReceipt"
    let refresher = Refresher()
    var transaction: StoreKit.Transaction?

    enum AuthError: Error {
        case noOauthToken
    }
    
    func request(transaction: StoreKit.Transaction) async throws {
        guard !isFetching else { return }

        self.transaction = transaction
        refresher.delegate = self
        refresher.refresh()

        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }

        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,

           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL)
                print(receiptData)
                
                
                let receiptString = receiptData.base64EncodedString(options: [])
                
                var request = URLRequest(url: URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!)
                request.addValue(token, forHTTPHeaderField: "Authorization")
                request.httpMethod = "POST"
                request.addValue(receiptString, forHTTPHeaderField: "originalTransaction")

//                request.httpBody = """
//                    {
//                        environment: \(ChurchBeamConfiguration.environment.appleServerValue),
//                        originalTransaction: \(receiptString)
//                    }
//                    """
//                    .data(using: .utf8)
                
                let (result, error) = try await URLSession.shared.data(for: request)
                print(error)
                let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String : Any]
                print(json)
                isFetching = false
                
                isFetching = false
            } catch {
                isFetching = false
                print(error)
                throw error
            }
            //
            //        isFetching = true
            //        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            //            isFetching = false
            //            throw AuthError.noOauthToken
            //        }
            //        do {
            //            var request = URLRequest(url: URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!)
            //            request.addValue(token, forHTTPHeaderField: "Authorization")
            //
            //            request.httpBody = """
            //                {
            //                    environment: \(ChurchBeamConfiguration.environment.appleServerValue),
            //                    originalTransaction: \(JSONEncoder().encode(transaction))
            //                }
            //                """
            //                .data(using: .utf8)
            //
            //            let (result, error) = try await URLSession.shared.data(for: request)
            //            print(error)
            //            let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String : Any]
            //            print(json)
            //            isFetching = false
            //        } catch {
            //            isFetching = false
            //            throw error
            //        }
        }
    }

}
