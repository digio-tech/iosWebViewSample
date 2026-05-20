//
//  MyViewController.swift
//  DigioTestAkash
//
//  Created by Akash on 25/11/24.
//

import UIKit
import DigiokycSDK

class MyViewController: UIViewController,DigioKycResponseDelegate {
    let delayInSeconds = 2.0
    var activityIndicator: UIActivityIndicatorView!

    func onDigioKycResponseSuccess(successResponse: String) {
        print("Response Success --> \(successResponse)")
        self.dismiss(animated: true, completion: nil)

    }
    
    func onDigioKycResponseFailure(failureResponse: String) {
        print("Response Failure --> \(failureResponse)")
        self.dismiss(animated: true, completion: nil)

    }
    
    func onGateWayEvent(event: String) {
        print("GatewayEvent--> \(event)")
    }
    
    
    override func viewDidLoad() {
//        startDigio()
        setupLoader()
        startLoader()
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                    self.startDigio()
                }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func startDigio()  {
        do{
            try DigioKycBuilder()
                .withController(viewController: self)
                .setDocumentId(documentId: "KID260417181505702SWHKPFREAWGLOB")
                .setIdentifier(identifier: "akash.kumar@digio.in")
                .setLogo(logo: "")
                .setAdditionalParams(additionalParams: [:])
                .setEnvironment(environment: .PRODUCTION)
                .setTokenId(tokenId: "GWT2604171815057124L7ATHFDOVW67S")
                .setPrimaryColor(hexColor: "#28b842")
                .build()
        }catch {
            print("Exception --> \(error.localizedDescription)")
           
        }
        
    }
    
    func setupLoader() {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
        }

    
    func startLoader() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false // Disable user interaction while loader is active
    }

    func stopLoader() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true // Re-enable user interaction
    }
}
