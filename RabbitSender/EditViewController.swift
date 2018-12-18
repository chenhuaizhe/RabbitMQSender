//
//  EditViewController.swift
//  RabbitSender
//
//  Created by ChenYuan's Macbook Air on 2018/12/18.
//  Copyright © 2018 ChenYuan's Macbook. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView

class EditViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    open var jsonString = ""
    open var fileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.jsonString
        
        
    }
    
    @IBAction func rightNavBarButtonClicked(_ sender: Any) {
        self.jsonString = self.textView.text
        
        if !self.jsonStringCheck(jsonString: self.jsonString) {
            SCLAlertView().showError("Wrong Json", subTitle: "parse json error! Please Check!")
            return;
        }
        self.reWriteFileToPathDocument(text: self.jsonString, file: self.fileName)
        SCLAlertView().showSuccess("Save Success!", subTitle: "😊💐😊")
    }
    
    func reWriteFileToPathDocument(text: String, file: String) {
        let fileManager = FileManager.default
        if let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                //Delete
                try! fileManager.removeItem(at: fileURL)
                //writing
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    func jsonStringCheck(jsonString: String) -> Bool {
        if let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false) {
            print(jsonData)
            do {
                let json = try JSON(data: jsonData as Data)
                let routingKey = json["routing-key"].stringValue
                let msgArray = json["msg"].arrayValue
                let timeCell = json["time-cell"].intValue
                print("jsonStringCheck---> routingKey:\(routingKey)\nmsgArray:\(msgArray)\ntimeCell:\(timeCell)\n")
                return true
                
            }
            catch {/* error handling here */
                print("parse json error")
                return false
                
            }
        }
        return false
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
