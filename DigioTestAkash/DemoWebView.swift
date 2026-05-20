//
//  DemoWebView.swift
//  DigioTestAkash
//
//  Created by Akash on 16/12/24.
//

import UIKit
import WebKit
import CoreLocation
import Photos


class DemoWebView : UIViewController, CLLocationManagerDelegate, WKUIDelegate {
    private var digioMainWebView: WKWebView!
    var activityIndicator:UIActivityIndicatorView?
    var requiredPermissions = Stack<Permissions>()
    var locationManager = CLLocationManager()
    
    enum Permissions: String, CaseIterable{
        case LOCATION_PERMISSION = "LOCATION_PERMISSION"
        case CAMERA_PERMISSION = "CAMERA_PERMISSION"
        case MICROPHONE_PERMISSION = "MICROPHONE_PERMISSION"
        case PHOTOLIBRARY_PERMISSION = "PHOTOLIBRARY_PERMISSION"
    }

    enum URLSCHEMES {
        static let LOCATION_SERVICE_SETTINGS_URL = UIApplication.openSettingsURLString
        static let PRIVACY_LOCATION_SETTINGS_URL = "App-prefs:root=Privacy&path=LOCATION"
        static let CAMERA_SETTINGS_URL = "App-prefs:root=Privacy&path=CAMERA"
    }

    
    override func viewDidLoad() {
        setupWebView()
        digioMainWebView.uiDelegate = self
    }
    
    
    // webview setup
    private func setupWebView() {
        activityIndicator = UIActivityIndicatorView()
        let pref = WKPreferences()
        pref.javaScriptEnabled = true
        pref.javaScriptCanOpenWindowsAutomatically = true
        let contentController = WKUserContentController()
        view.backgroundColor = UIColor.white

        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        config.preferences = pref
        
        /** medial play back required for 2 way video kyc  */
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        /** **************************** ** */
        
        digioMainWebView = WKWebView(frame: view.frame, configuration: config)
        digioMainWebView.allowsBackForwardNavigationGestures = true
        digioMainWebView.translatesAutoresizingMaskIntoConstraints = false
        
        digioMainWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        digioMainWebView!.navigationDelegate = self
        
        // add webview in view
        view.addSubview(digioMainWebView!)
        
        if let url = URL(string: generateUrl()) {
            digioMainWebView.load(URLRequest(url: url))
        }
        
    }
    
    // webview configuration
    private func generateUrl()-> String {
        
        let baseUrl_Prod = "https://app.digio.in"
        let baseUrl_Sandbox = "https://ext.digio.in"
        let baseUrl_Local = "http://10.50.2.115:8083"
        
        var mapParams = [String:String]()
        
        let txnId = Double.random(in: 0.01...3.14)
        // pass your logo here
        mapParams["logo"] = "https://www.digio.in/images/digio_blue.png"
        
        mapParams["token_id"] = "GWT260519160940754S8FW39GWWVGI8S"
        
        //adding configuring the theme
        var themeDictionary : [String: Any] = [:]
        themeDictionary["PRIMARY_COLOR"] = "#0066ff"
        themeDictionary["FONT_FAMILY"] = "fontFamily"
        themeDictionary["FONT_URL"] = "fontUrl"
        themeDictionary["FONT_FORMAT"] = "fontFormat"
        
        let jsonData = try! JSONSerialization.data(withJSONObject: themeDictionary, options: [])
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        mapParams["theme"] = jsonString.addingPercentEncoding(withAllowedCharacters: .alphanumerics.union(CharacterSet(charactersIn: "~-_.")))
        
        // pass your redirect url then digio will re-direct on same url after jounery
        mapParams["redirect_url"] = "https://your-redirect-url.in"
        
//        var url : String = (baseUrl_Sandbox)
        var url : String = (baseUrl_Prod)
        url.append("/#/gateway/login/")
        url.append("KID260519160940735IQ33TPQ79UU4BR") // documentId/NachId/KycId
        url.append("/")
        url.append(String(txnId)) // random number
        url.append("/")
        url.append("akash.kumar@digio.in") //identifier --> email/phone number
        
        var initialised = false;
        for (key, value) in mapParams {
            url.append(initialised ? "&":"?")
            initialised = true
            url.append(key)
            url.append("=")
            url.append(value)
        }
        
        print(url)
        
        return url
    }
    
    
    func checkPermissions(){
        if self.requiredPermissions.isEmpty(){
            return
        }
        let permission = self.requiredPermissions.peek()
        DispatchQueue.main.async {
            switch permission{
            case .LOCATION_PERMISSION:
                self.checkLocationPermission()
                break
            case .CAMERA_PERMISSION:
                self.checkCameraPermission()
                break
            case .MICROPHONE_PERMISSION:
                self.checkMicrophonePermission()
                break
            case .PHOTOLIBRARY_PERMISSION:
                //not implementated yet
                break
            default:
                break
                
            }
        }
    }
    
    
    /** Check for location */
    func checkLocationPermission(){
        //                if CLLocationManager.locationServicesEnabled() {
        if !CLLocationManager.locationServicesEnabled(){
            showAlertForNavigationToSettings()
        }else{
            switch CLLocationManager.authorizationStatus() {
            case .restricted, .denied:
                print("No location access")
                self.showAlertForTurnOnLocationServiceForApp()
                break
            case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
                print(CLLocationManager.authorizationStatus().rawValue)
                // initialize location here
                locationPermission()
            @unknown default:
                print("unknow location error")
                break
            }
        }
    }
    
    func checkMicrophonePermission(){
        switch AVAudioSession.sharedInstance().recordPermission {

        case .granted:
            //do nothing
            if self.requiredPermissions.isEmpty(){
                return
            }
            let _ = requiredPermissions.pop()
            self.checkPermissions()
            break
        case .denied:
            //navigate to settings for microphone permission
            self.showAlertForTurnOnMicroPhonePermission()
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if granted {
                    //do nothing
                    self.checkMicrophonePermission()
                } else {
                    //close error
                    self.showAlertForTurnOnCameraPermission()
                }
            })
        default:
            break
        }

    }
    
    func checkCameraPermission()  {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status{
        case .authorized:
            print("Camera Authorized")
            if self.requiredPermissions.isEmpty(){
                return
            }
            requiredPermissions.pop()
            self.checkPermissions()
            break
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    //do nothing
                    self.checkCameraPermission()
                }else{
                    self.showAlertForTurnOnCameraPermission()
                    //show alert for mandatory
                }
            }
            break
            
        case .denied, .restricted:
            //show alert for camera permission
            self.showAlertForTurnOnCameraPermission()
            break
        default:
            break
        }
    }
    
    func navigateToSetting(with urlString:String, reason: String){
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        UserDefaultsManager.setString(reason, forKey: .APP_REDIRECT_REASON)
        UIApplication.shared.open(URL(string: urlString)!)
    }
    
    
    func showAlertForTurnOnCameraPermission(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Camera Permission Required", message: "Please Enable Camera Permission in Settings -> Privacy -> Camera", preferredStyle: .alert)
            let goToSettingsButton = UIAlertAction(title: "Go To Settings", style: .default) { (action) in
                //navigate to app settings
                self.navigateToSetting(with: URLSCHEMES.CAMERA_SETTINGS_URL, reason: "CAMERA_PERMISSION")
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(goToSettingsButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertForTurnOnMicroPhonePermission(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Microphone Permission Required", message: "Please enable Microphone permission in Settings -> Privacy -> Microphone", preferredStyle: .alert)
            let goToSettingsButton = UIAlertAction(title: "Go To Settings", style: .default) { (action) in
                //navigate to app settings
                self.navigateToSetting(with: URLSCHEMES.CAMERA_SETTINGS_URL, reason: "MICROPHONE_PERMISSION")
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(goToSettingsButton)
            alert.addAction(cancelButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertForTurnOnLocationServiceForApp(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Location Permission Required", message: "Please Enable Location Permission in Settings -> Privacy -> Location Service", preferredStyle: .alert)
            let positiveButton:UIAlertAction = UIAlertAction(title: "Turn On in Settings", style: .default) { action in
                self.navigateToSetting(with: URLSCHEMES.LOCATION_SERVICE_SETTINGS_URL, reason: "LOCATION_PERMISSION")
            }
            
            let negativeButton = UIAlertAction(title: "Keep Location Services Off", style: .default, handler: { [self]
                ac in
                self.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(positiveButton)
            alert.addAction(negativeButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showAlertForNavigationToSettings(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Location Permission Required", message: "Turn on Location Services in Settings -> Privacy -> Location Services", preferredStyle: .alert)
            let positiveButton:UIAlertAction = UIAlertAction(title: "Go To Settings", style: .default) { action in
                print("\(URLSCHEMES.LOCATION_SERVICE_SETTINGS_URL)")
                self.navigateToSetting(with: URLSCHEMES.PRIVACY_LOCATION_SETTINGS_URL, reason: "LOCATION_PERMISSION")
            }
            
            let negativeButton = UIAlertAction(title: "Don't Use Location", style: .cancel, handler: { [self]
                ac in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(positiveButton)
            alert.addAction(negativeButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func willEnterForeground(){
        print("")
        let reason = UserDefaultsManager.getString(forKey: .APP_REDIRECT_REASON) ?? "NONE"
        switch Permissions(rawValue: reason){
        case Permissions.LOCATION_PERMISSION?:
            self.checkLocationPermission()
            break
        case Permissions.CAMERA_PERMISSION?:
            self.checkCameraPermission()
            break
        case Permissions.MICROPHONE_PERMISSION?:
            self.checkMicrophonePermission()
            break
        case Permissions.PHOTOLIBRARY_PERMISSION?:
            break
        default:
            break
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /** initialize location  and send to web method */
    func locationPermission()  {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        print("inside locationpermission")
        if let locationCoordinates = locationManager.location?.coordinate{
            let lat = Double(locationCoordinates.latitude)
            let long = Double(locationCoordinates.longitude)
            let user_accuracy = Double(locationManager.desiredAccuracy)
            print("getLocationFromIosListener('\(lat)','\(long)','\(user_accuracy)','\("")')")
            if self.requiredPermissions.isEmpty(){
                return
            }
            let _ = requiredPermissions.pop()
            checkPermissions()
        }
    }
}

extension DemoWebView : WKNavigationDelegate {
    /*func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false){
                print("TestUrl :\(url)")
                if components.host == "your-redirect-url.in" {
                    if let queryItems = components.queryItems {
                        print("Success_Failure_Response: \(queryItems)")
                        // here you can get all result use it as per your requirment
                        decisionHandler(.cancel)
                        
                        // closing this screen after result recived
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        return
                    }
                }
                
            }
            decisionHandler(.allow)
        }
    }*/
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                print("TestUrl : \(url.absoluteString)")
                
                //  Case 1: Handle redirect success/failure
                if components.host == "your-redirect-url.in" {
                    if let queryItems = components.queryItems {
                        print("Success_Failure_Response: \(queryItems)")
                        
                        decisionHandler(.cancel)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        return
                    }
                }
                
                //  Case 2: Handle custom schemes
                if let scheme = components.scheme?.lowercased(),
                   scheme != "http", scheme != "https" {
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("⚠️ No app found for scheme: \(scheme)")
                        
                        //  Map scheme → App Store link
                        var appStoreURL: URL?
                        
                        switch scheme {
                        case "ppe": // PhonePe
                            appStoreURL = URL(string: "https://apps.apple.com/in/app/phonepe-secure-payments-app/id1170055821")
                            
                        case "paytm":
                            appStoreURL = URL(string: "https://apps.apple.com/in/app/paytm-payments-app-wallet-upi/id473941634")
                            
                        case "gpay", "tez": // Google Pay (also supports "tez" scheme)
                            appStoreURL = URL(string: "https://apps.apple.com/in/app/google-pay-save-pay-manage/id1193357041")
                            
                        case "bhim", "upi":
                            appStoreURL = URL(string: "https://apps.apple.com/in/app/bhim-making-india-cashless/id1172681205")
                            
                        default:
                            break
                        }
                        
                        if let appStoreURL = appStoreURL {
                            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
                        }
                    }
                    
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }

}

// redirection reason

struct UserDefaultsManager {
    enum Key: String {
        case APP_REDIRECT_REASON = "APP_REDIRECT_REASON"
    }
    
    static let userDefaults = UserDefaults.standard
    
    static func setString(_ value: String, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    static func getString(forKey key: Key) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }
    
    static func setInt(_ value: Int, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    static func getInt(forKey key: Key) -> Int? {
        return userDefaults.integer(forKey: key.rawValue)
    }
}


// permission stack
struct Stack<T> {
    private var items: [T] = []
    
    func isEmpty() -> Bool{
        return items.count == 0
    }
    
    /**
     Before using this function Check every time if stack is empty or not
     */
    func peek() -> T {
        guard let topElement = items.first else {
            print("Empty Stack")
            fatalError("Stack Empty")
        }
        return topElement
    }
    
    /**
     Before using this function Check every time if stack is empty or not
     */
    mutating func pop() -> T {
        if isEmpty(){
            fatalError("stack Empty")
        }
        return items.removeFirst()
    }
  
    mutating func push(_ element: T) {
        items.insert(element, at: 0)
    }
}

