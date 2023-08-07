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

actor VerifyPurachaseTransactionUseCase: ObservableObject {
    
    @Published private(set) var isFetching = false
    private let endpoint = "verifyAppleReceipt"
    
    enum AuthError: Error {
        case noOauthToken
    }
    
    func request(transaction: StoreKit.Transaction) async throws {
        guard !isFetching else { return }
        
        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }
        
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                print(receiptData)
                
                
                let receiptString = receiptData.base64EncodedString(options: [])
                
                var request = URLRequest(url: URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!)
                request.addValue(token, forHTTPHeaderField: "Authorization")
                
                request.httpBody = """
                    {
                        environment: \(ChurchBeamConfiguration.environment.appleServerValue),
                        originalTransaction: \(receiptString)
                    }
                    """
                    .data(using: .utf8)
                
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
