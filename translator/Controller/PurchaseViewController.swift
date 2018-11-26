//
//  PurchaseViewController.swift
//  Lite Translate
//
//  Created by MC on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseViewController: ParentViewController,
                            SKProductsRequestDelegate,
                            SKPaymentTransactionObserver
{
    @IBOutlet weak var buttonBuyYearly: UIButton!
    @IBOutlet weak var labelTerms: UITextView!
    @IBOutlet weak var buttonAgreement: UIButton!
    
    var product_id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        buttonBuyYearly.layer.cornerRadius = 20
        buttonAgreement.layer.cornerRadius = 20
        
        ChangeBG(sender: self, image: "BG iPhone 1")
        
        let stringAtr: NSMutableAttributedString = NSMutableAttributedString(string: L(key: "key39"))
        labelTerms.attributedText = stringAtr
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func YearlyPurchase(_ sender: Any)
    {
        loading?.removeFromSuperview()
        ShowLoading()
        self.product_id = INAPP_PRODUCT
        SKPaymentQueue.default().add(self)
        if (SKPaymentQueue.canMakePayments()) {
            let productID:NSSet = NSSet(object: self.product_id!);
            let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>);
            productsRequest.delegate = self;
            productsRequest.start();
        } else {
            print("can't make purchases");
        }
    }
    
    @IBAction func Agreement(_ sender: Any)
    {
        self.OpenURL(urlStr: "")
    }
    
    //MARK: In App Purchase Delegate
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let productArr = response.products;
        NSLog("%@", productArr)
        
        if (productArr.count == 0) {
            loading?.removeFromSuperview()
            present(ShowAlertViewController(sender: self, title: self.L(key: "key34"), message: self.L(key: "key36")), animated: true, completion: nil)
            return;
        }
        
        var p:SKProduct? = nil
        
        for pro in productArr {
            if (pro.productIdentifier == INAPP_PRODUCT)
            {
                p = pro;
            }
        }
        
        SKPaymentQueue.default().add(SKPayment(product: p!));
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    loading?.removeFromSuperview()
                    ShowLoading()
                    self.completeTransaction(transaction: transaction as! SKPaymentTransaction)
                    break;
                case .failed:
                    print("Purchased Failed");
                    loading?.removeFromSuperview()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    loading?.removeFromSuperview()
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }
    
    func completeTransaction(transaction:SKPaymentTransaction) -> Void {
        SKPaymentQueue.default().finishTransaction(transaction)
        let temptransactionReceipt = try! Data(contentsOf: Bundle.main.appStoreReceiptURL!).base64EncodedString(options: [])
        
        var base64:String = JoDess.encodeBase64(with: temptransactionReceipt)
        base64 = base64.replacingOccurrences(of: "\n", with: "")
        base64 = base64.replacingOccurrences(of: "\r", with: "")
        base64 = base64.replacingOccurrences(of: "+", with: "%2B")
        
        self.RequestAPIAppPurchaseAds(urlRequest: URL_REQUESTAPI_APPPURCHASEADS, params: String(format: "receipt=%@&goods_id=%@&bundle_id=%@&uuid=%@", base64, INAPP_PRODUCT, BUNDLEID, self.getDeviceID()))
    }
    
    
    //MARK: API
    func RequestAPIAppPurchaseAds(urlRequest:String, params:String) -> Void
    {
        loading?.removeFromSuperview()
        ShowLoading()
        DispatchQueue.global().async
            {
                self.response = self.RequestAPIenc(urlRequest: urlRequest, params: params)
                DispatchQueue.main.async
                    {
                        KeyChainStore.save("PurchaseID", data: ((self.response?.object(forKey: "data") as! NSDictionary).object(forKey: "uuid") as? String)!)
                        KeyChainStore.save("ExpiredDate", data: ((self.response?.object(forKey: "data") as! NSDictionary).object(forKey: "expired_time") as? String)!)
                        self.loading?.removeFromSuperview()
                }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
