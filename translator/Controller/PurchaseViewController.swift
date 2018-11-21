//
//  PurchaseViewController.swift
//  translator
//
//  Created by a on 15/11/18.
//  Copyright © 2018 tms. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseViewController: ParentViewController,
                            SKProductsRequestDelegate,
                            SKPaymentTransactionObserver
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonBuyMonthly: UIButton!
    @IBOutlet weak var buttonBuyYearly: UIButton!
    
    var product_id: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scrollView.contentSize = CGSize(width: self.view.frame.size.width*2, height: self.view.frame.size.height)
        buttonBuyMonthly.layer.cornerRadius = 20
        buttonBuyYearly.layer.cornerRadius = 20
        ChangeBG(sender: self, image: "BG iPhone 2")
    }
    
    
    //MARK: IBAction
    @IBAction func Back(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func MonthlyPurchase(_ sender: Any)
    {
        loading?.removeFromSuperview()
        ShowLoading()
        self.product_id = INAPP_PRODUCT_MONTHLY
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
    
    @IBAction func YearlyPurchase(_ sender: Any)
    {
        loading?.removeFromSuperview()
        ShowLoading()
        self.product_id = INAPP_PRODUCT_YEARLY
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
    
    //MARK: In App Purchase Delegate
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
    {
        let productArr = response.products;
        NSLog("%@", productArr)
        if (productArr.count == 0) {
            loading?.removeFromSuperview()
//            [self showAlert:@"Invalid Product." title:@"Warning!" btn:@"OK" tag:0 delegate:self];
            return;
        }
        
        var p:SKProduct? = nil
        
        for pro in productArr {
            if (pro.productIdentifier == INAPP_PRODUCT_MONTHLY)
            {
                p = pro;
            }
            else if (pro.productIdentifier == INAPP_PRODUCT_YEARLY)
            {
                p = pro
            }
        }
        
        SKPaymentQueue.default().add(SKPayment(product: p!));
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    print("Product Purchased");
                    loading?.removeFromSuperview()
                    ShowLoading()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    SKPaymentQueue.default().remove(self)
//                    self.RequestAPIAppPurchaseAds(urlRequest: URL_REQUESTAPI_APPPURCHASEADS, params: String(format: "bundle_id=%@", BUNDLEID))
                    break;
                case .failed:
                    print("Purchased Failed");
                    loading?.removeFromSuperview()
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    print("Already Purchased");
                    loading?.removeFromSuperview()
//                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
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
