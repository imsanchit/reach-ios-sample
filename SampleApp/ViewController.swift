//
//  ViewController.swift
//  SampleApp
//
//  Created by Sanchit Mittal on 14/11/18.
//  Copyright © 2018 Sanchit Mittal. All rights reserved.
//

import UIKit
import CoreLocation
import SixgillSDK
import Toast_Swift
import Foundation
import CoreMotion

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var dropDownPicker: UIPickerView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var startSDKButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dropDownPicker.delegate = self
        
        modifyUI(isRequestSent: false)

        requestForPermissions()
        
        if UserDefaults.standard.bool(forKey: Constants.IS_SDK_RUNNING) {
            
            SGSDK.enable()
            
            showEventsViewController()
        }
        
    }
    
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.urls.count
    }
    
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.urls[row]
    }
    
    // MARK: - IBActions
    
    @IBAction func startSDK(_ sender: UIButton) {
        
        phoneNumberTextField.resignFirstResponder()
        
        // Made mandatory to enter phone number as alias
        guard let phone_number = phoneNumberTextField.text, phone_number.count > 0 else {
            self.view.makeToast("Enter phone number")
            return
        }
        
        modifyUI(isRequestSent: true)
        
        // Configure Reach Config
        let config = SGSDKConfigManager();
        
        let dict = ["phone_number": phone_number];
        config.aliases = dict as? NSMutableDictionary;
        
        config.ingressURL = Constants.urls[dropDownPicker.selectedRow(inComponent: 0)]
        
        config.shouldSendDataToServer = false
        
        // StartWithApiKey
        DispatchQueue.global(qos: .background).async {
            SGSDK.sharedInstance()?.start(withAPIKey: "3360a86a37f9f397c34db3569e", andConfig: config, andSuccessHandler: {
                
                // Enable SDK
                SGSDK.enable(successHandler: {
                    
                    DispatchQueue.main.async {
                        
                        self.modifyUI(isRequestSent: false)
                        
                        UserDefaults.standard.set(true, forKey: Constants.IS_SDK_RUNNING)
                        self.showEventsViewController()
                        
                        return
                    }
                    
                }, andFailureHandler: { (failureMsg) in
                    DispatchQueue.main.async {
                        self.modifyUI(isRequestSent: false)
                        self.view.makeToast(failureMsg)
                    }
                })
                
            }) { (failureMsg) in
                DispatchQueue.main.async {
                    self.modifyUI(isRequestSent: false)
                    self.view.makeToast(failureMsg)
                }
            }
        }
       
    }
    
    // MARK: - Utility
    
    private func requestForPermissions() {
        // Location Permission
        SGSDK.requestAlwaysPermission()
        
        // Motion Activity Permission
        let motionActivityManager = CMMotionActivityManager()
        motionActivityManager.queryActivityStarting(from: Date(), to: Date(), to: .main) { (activities, error) in
            
        }
    }
    
    private func showEventsViewController() {
        // Push to Events Table View Controller
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let eventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsTableViewControllerIdentifier")
        self.navigationController?.pushViewController(eventsViewController, animated: false)
    }
    
    private func modifyUI(isRequestSent: Bool) {
        activityIndicatorView.isHidden = !isRequestSent
        startSDKButton.isHidden = isRequestSent
    }
}
