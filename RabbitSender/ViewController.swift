//
//  ViewController.swift
//  RabbitSender
//
//  Created by ChenYuan's Macbook Air on 2018/12/8.
//  Copyright © 2018 ChenYuan's Macbook. All rights reserved.
//

import UIKit
import RMQClient
import SCLAlertView
import SwiftyJSON

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    private var dataSource:[String] = [];
    private var timer: DispatchSource!
    private var isSending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initDataSource()

    }
    
    func initDataSource() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        self.dataSource = self.getPaths(inPath: path)
    }
    
    func updateDataSource() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        self.dataSource = self.getPaths(inPath: path)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeListCell") as! HomeListCell
        let title = self.dataSource[indexPath.row]
        cell.titleLabel.text = title
        cell.myClosure = {() -> Void in
            self.sendMessageInIndexPath(indexPath: indexPath)
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let title = self.dataSource[indexPath.row]
        let jsonString = self.readFileFromPathDocument(file: title)
        print("jsonString-> \(jsonString)")
    }
    
    func sendMessageInIndexPath(indexPath: IndexPath) {
        let title = self.dataSource[indexPath.row]
        let jsonString = self.readFileFromPathDocument(file: title)
        print("jsonString-> \(jsonString)")
        
        if let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false) {
            print(jsonData)
            do {
                let json = try JSON(data: jsonData as Data)
                let routingKey = json["routing-key"].stringValue
                let msgArray = json["msg"].arrayValue
                let timeCell = json["time-cell"].intValue
                print("routingKey:\(routingKey)\nmsgArray:\(msgArray)\ntimeCell:\(timeCell)\n")
                
                self.sendMessages(msgArray: msgArray, routingKey: routingKey, interval: timeCell)
            }
            catch {/* error handling here */
                print("parse json error")
                SCLAlertView().showError("parse json error", subTitle: "parse json error! Please Check!")
                
            }
        }
    }
    
    func sendMessages(msgArray: [SwiftyJSON.JSON],routingKey: String, interval: Int) {
        let uriRight = self.uriCheck()
        if uriRight {
            if self.isSending {
                SCLAlertView().showError("Sending Data", subTitle: "Please Wait!")
                return;
            }
            let count = msgArray.count
            var index = 0;
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main) as? DispatchSource //创建定时器资源
            self.timer.schedule(deadline:  .now() + DispatchTimeInterval.seconds(1), repeating: .seconds(1))   //设置延时和重复操作时间
            self.timer.setEventHandler { //重复处理。
                let m = msgArray[index].stringValue
                print("m:\(m)\n")
                self.emitLogDirect(m, severity: routingKey)
                index += 1;
                if index == count {
                    SCLAlertView().showSuccess("Send Success!", subTitle: "😊😊😊")
                    self.timer.cancel()  //销毁定时器，无法重启
                    self.isSending = false
                }
                
            }
            //启动定时器
            self.timer.resume() //不可重复启动。
            self.isSending = true
            
            
            
            

        }
    }
    
    func uriCheck() -> Bool {
        let user = UserDefaults.standard.object(forKey: "rabbit_mq_user")
        let password = UserDefaults.standard.object(forKey: "rabbit_mq_password")
        let host = UserDefaults.standard.object(forKey: "rabbit_mq_host")
        if user == nil || user as! String == "" {
            SCLAlertView().showError("Wrong", subTitle: "user == nil || user == “”")
            return false
        }
        if password == nil || password as! String == "" {
            SCLAlertView().showError("Wrong", subTitle: "password == nil || password == “”")
            return false
        }
        if host == nil || host as! String == "" {
            SCLAlertView().showError("Wrong", subTitle: "host == nil || host == “”")
            return false
        }
        
        return true
    }
    
    func emitLogDirect(_ msg: String, severity: String) {
        let user = UserDefaults.standard.object(forKey: "rabbit_mq_user")
        let password = UserDefaults.standard.object(forKey: "rabbit_mq_password")
        let host = UserDefaults.standard.object(forKey: "rabbit_mq_host")
        
        let uri = "amqp://\(user!):\(password!)@\(host!)"
        let conn = RMQConnection(uri: uri,
                                 delegate: RMQConnectionDelegateLogger())
        conn.start()
        let ch = conn.createChannel()
        let x = ch.direct("direct_logs")
        x.publish(msg.data(using: .utf8), routingKey: severity)
        print("Sent '\(msg)'")
        conn.close()
    }
    
    @IBAction func leftNavBarButtonClicked(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 216, height: 70))
        let x = (subview.frame.width - 180) / 2
        
        // Add textfield 1
        let textfield1 = UITextField(frame: CGRect(x: x,y: 10,width: 180,height: 25))
        textfield1.layer.borderColor = UIColor.green.cgColor
        textfield1.layer.borderWidth = 1.5
        textfield1.layer.cornerRadius = 5
        textfield1.placeholder = "Title"
        textfield1.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield1)
        
        // Add textfield 2
        let textfield2 = UITextField(frame: CGRect(x: x,y: textfield1.frame.maxY + 10,width: 180,height: 25))
        textfield2.layer.borderColor = UIColor.blue.cgColor
        textfield2.layer.borderWidth = 1.5
        textfield2.layer.cornerRadius = 5
        textfield1.layer.borderColor = UIColor.blue.cgColor
        textfield2.placeholder = "RabbitMQ Json String"
        textfield2.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield2)
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.addButton("Save") {
            print("saved json data")
            let title = textfield1.text
            let jsonString = textfield2.text
            if !(title == nil || title == "" || jsonString == nil || jsonString == "") {
                print("jsonString:\(jsonString!)");
                let fileName = title! + ".json"
                self.writeFileToPathDocument(text: jsonString!, file: fileName)
                self.updateDataSource()
                self.tableView.reloadData()
            }else {
                SCLAlertView().showError("Save Failed!", subTitle: "Please make sure that you have input the right string.")
            }
            
        }
        alert.addButton("Cancel", backgroundColor: UIColor.brown, textColor: UIColor.yellow, showTimeout: nil) {
            print("Cancel Button tapped")
        }
        
        alert.showInfo("Save", subTitle: "", closeButtonTitle: "Cancel")
    }
    
    @IBAction func rightNavBarButtonClicked(_ sender: Any) {
        // Example of using the view to add two text fields to the alert
        // Create the subview
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        // Initialize SCLAlertView using custom Appearance
        let alert = SCLAlertView(appearance: appearance)
        // Creat the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 216, height: 105))
        let x = (subview.frame.width - 180) / 2
        
        // Add textfield 1
        let textfield1 = UITextField(frame: CGRect(x: x,y: 10,width: 180,height: 25))
        textfield1.layer.borderColor = UIColor.green.cgColor
        textfield1.layer.borderWidth = 1.5
        textfield1.layer.cornerRadius = 5
        textfield1.placeholder = "Username"
        textfield1.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield1)
        
        // Add textfield 2
        let textfield2 = UITextField(frame: CGRect(x: x,y: textfield1.frame.maxY + 10,width: 180,height: 25))
        textfield2.layer.borderColor = UIColor.blue.cgColor
        textfield2.layer.borderWidth = 1.5
        textfield2.layer.cornerRadius = 5
        textfield1.layer.borderColor = UIColor.blue.cgColor
        textfield2.placeholder = "Password"
        textfield2.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield2)
        
        // Add textfield 3
        let textfield3 = UITextField(frame: CGRect(x: x,y: textfield2.frame.maxY + 10,width: 180,height: 25))
        textfield3.layer.borderColor = UIColor.blue.cgColor
        textfield3.layer.borderWidth = 1.5
        textfield3.layer.cornerRadius = 5
        textfield2.layer.borderColor = UIColor.blue.cgColor
        textfield3.placeholder = "Host"
        textfield3.textAlignment = NSTextAlignment.center
        subview.addSubview(textfield3)
        
        // Add the subview to the alert's UI property
        alert.customSubview = subview
        alert.addButton("Login") {
            print("Logged in")
            let user = textfield1.text
            let password = textfield2.text
            let host = textfield3.text
            UserDefaults.standard.set(user, forKey: "rabbit_mq_user")
            UserDefaults.standard.set(password, forKey: "rabbit_mq_password")
            UserDefaults.standard.set(host, forKey: "rabbit_mq_host")
        }
        
        // Add Button with Duration Status and custom Colors
        alert.addButton("Cancel", backgroundColor: UIColor.brown, textColor: UIColor.yellow, showTimeout: nil) {
            print("Cancel Button tapped")
        }
        
        alert.showInfo("Login", subTitle: "", closeButtonTitle: "Login")
    }
    
    func writeFileToPathDocument(text: String, file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    func readFileFromPathDocument(file: String) -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            
            //reading
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text
            }
            catch {/* error handling here */
                return ""
            }
        }
        return ""
    }
    
    /// 获取path路径下的所有文件或者目录的名字
    ///
    /// - Parameter path: path
    /// - Returns: 路径下所有文件或者目录的名字
    func getPaths(inPath path:String) -> [String] {
        let manager = FileManager.default
        let contentsOfPath:[String]?
        do {
            try contentsOfPath = manager.contentsOfDirectory(atPath: path)
        } catch  {
            contentsOfPath = []
        }
        
        //contentsOfPath：Optional([fold1, test1.txt])
        print("contentsOfPath: \(contentsOfPath!)")
        if (contentsOfPath?.contains(".DS_Store"))! {
            let index = contentsOfPath?.index(of: ".DS_Store")
            contentsOfPath?.remove(at: index!)
        }
        for p:String in contentsOfPath! {
            if(p.contains(" ")){
                let index = contentsOfPath?.index(of:p)
                contentsOfPath!.remove(at: index ?? 0)
            }
        }
        return contentsOfPath!
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cell2editvc" {
            let indexPath = self.tableView.indexPathForSelectedRow
            let title = self.dataSource[indexPath!.row]
            let jsonString = self.readFileFromPathDocument(file: title)
            let vc = segue.destination as! EditViewController
            vc.jsonString = jsonString
            vc.fileName = title
        }
        
        
    }
    
}
