//
//  IAPManager.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/10/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit
import StoreKit

enum IAPError: LocalizedError {
    case paymentNotAllowed
    case busyPurchasing
    case unableToPurchage(Error?)
    case unableToReadReceipt(Error?)
    case unableToGetReceipt(Error?)
    case unableToReachStore(Error?)

    
    var errorDescription: String? {
        switch self {
        case .paymentNotAllowed: return AppText.IAPErrors.paymentNotAllowed
        case .busyPurchasing: return AppText.IAPErrors.busyPurchasing
        case .unableToReadReceipt(let error): return AppText.IAPErrors.unableToReadReceipt(error: error)
        case .unableToGetReceipt(let error): return AppText.IAPErrors.unableToGetReceipt(error: error)
        case .unableToPurchage(let error): return AppText.IAPErrors.unableToPurchage(error: error)
        case .unableToReachStore(let error): return AppText.IAPErrors.unableToReachStore(error: error)
        }
    }
}

let IAP_PRODUCTS_DID_LOAD_NOTIFICATION = Notification.Name("IAP_PRODUCTS_DID_LOAD_NOTIFICATION")

protocol IAPManagerDelegate {
    func succes()
    func didFetchProducts(products: [SKProduct])
    func didRefreshReceipt(products: [(IAPProduct, Date)])
    func failure(_ error: IAPError)
}

extension IAPManagerDelegate {
    func succes() { }
    func didFetchProducts(products: [SKProduct]) { }
    func didRefreshReceipt(products: [(IAPProduct, Date)]) { }
    func failure(_ error: IAPError) { }
}

enum IAPProduct: String, CaseIterable {
    case song
    case beam
    
    init?(_ string: String) {
        if let product = IAPProduct.allCases.first(where: { $0.rawValue == string }) {
            self = product
            return
        }
        return nil
    }
}

class IAPManager : NSObject {
    
    private var sharedSecret = ""
    private(set) var products : Array<SKProduct>?
    
    private var productIds : Set<String> = Set(IAPProduct.allCases.map({ $0.rawValue }))
    private var delegate: IAPManagerDelegate?
    
    // MARK:- Main methods
    
    init(delegate: IAPManagerDelegate?, sharedSecret: String) {
        self.delegate = delegate
        super.init()
        self.sharedSecret = sharedSecret
        UserSubmitter.addObserver(self)
        loadProducts()
    }
    
    func expirationDateFor(_ identifier : String) -> Date?{
        return UserDefaults.standard.object(forKey: identifier) as? Date
    }
    
    func purchaseProduct(product : SKProduct){
        
        guard SKPaymentQueue.canMakePayments() else {
            delegate?.failure(IAPError.paymentNotAllowed)
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            delegate?.failure(IAPError.busyPurchasing)
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases(){
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /* It's the most simple way to send verify receipt request. Consider this code as for learning purposes. You shouldn't use current code in production apps.
     This code doesn't handle errors.
     */
    func refreshSubscriptionsStatus(){
        
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            refreshReceipt()
            // do not call block in this case. It will be called inside after receipt refreshing finishes.
            return
        }
        
        #if DEBUG
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
        let urlString = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        let optionalReceiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        guard let receiptData = optionalReceiptData else {
            refreshReceipt()
//            delegate?.failure(.unableToGetReceipt(nil))
            return
        }
        let requestData = ["receipt-data" : receiptData, "password" : self.sharedSecret, "exclude-old-transactions" : true] as [String : Any]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            Queues.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        self.parseReceipt(json as! Dictionary<String, Any>)
                        return
                    }
                }
                self.delegate?.failure(.unableToGetReceipt(error))
            }
            }.resume()
    }
    
    /* It's the most simple way to get latest expiration date. Consider this code as for learning purposes. You shouldn't use current code in production apps.
     This code doesn't handle errors or some situations like cancellation date.
     */
    private func parseReceipt(_ json : Dictionary<String, Any>) {
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
            return
        }
        
        let products: [(IAPProduct, Date)] = receipts_array.compactMap({ receipt in
            guard let product = IAPProduct(receipt["product_id"] as! String) else {
                return nil
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            guard let date = formatter.date(from: receipt["expires_date"] as! String), date > Date() else {
                return nil
            }
            return (product, date)
        })
        if let user = VUser.first(moc: moc) {
            user.productId = products.first?.0.rawValue
            user.productExpireDate = products.first?.1
            UserSubmitter.submit([user], requestMethod: .put)
        }
        if products.count > 0 {
            NotificationCenter.default.post(name: .autoRenewableSubscriptionDidChange, object: nil)
        }
        self.delegate?.didRefreshReceipt(products: products)
    }
    
    /*
     Private method. Should not be called directly. Call refreshSubscriptionsStatus instead.
     */
    private func refreshReceipt() {
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }
    
    private func loadProducts() {
        let request = SKProductsRequest.init(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }
    
}

// MARK:- SKReceipt Refresh Request Delegate
extension IAPManager : SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        if request is SKReceiptRefreshRequest {
            refreshSubscriptionsStatus()
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error){
        if request is SKReceiptRefreshRequest {
            Queues.main.async {
                self.delegate?.failure(.unableToGetReceipt(error))
            }
        } else {
            self.delegate?.failure(.unableToReachStore(error))
        }
    }
}

// MARK:- SKProducts Request Delegate
extension IAPManager: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        DispatchQueue.main.async {
            self.delegate?.didFetchProducts(products: response.products)
            NotificationCenter.default.post(name: IAP_PRODUCTS_DID_LOAD_NOTIFICATION, object: nil)
            print(response.products.compactMap({ $0.localizedTitle }))
        }
    }
    
}

// MARK:- SKPayment Transaction Observer
extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Queues.main.async {
            for transaction in transactions {
                switch (transaction.transactionState) {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    self.notifyIsPurchased(transaction: transaction)
                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    print("purchase error : \(transaction.error?.localizedDescription ?? "")")
                    if (transaction.error as? SKError)?.code != SKError.paymentCancelled {
                        self.delegate?.failure(.unableToPurchage(transaction.error))
                    }
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    self.notifyIsPurchased(transaction: transaction)
                    break
                case .deferred, .purchasing:
                    break
                default:
                    break
                }
            }
        }
    }
    
    private func notifyIsPurchased(transaction: SKPaymentTransaction) {
        refreshSubscriptionsStatus()
    }
    
}

extension IAPManager: RequesterObserver1 {
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        if let user: VUser = VUser.first(moc: moc) {
            if user.hasActiveSongContract {
                NotificationCenter.default.post(name: .hasSongSubscription, object: nil)
            } else if user.hasActiveBeamContract {
                NotificationCenter.default.post(name: .hasBeamSubscription, object: nil)
            }
        }
    }
    
}
