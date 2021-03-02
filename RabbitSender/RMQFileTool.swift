//
//  RMQFileTool.swift
//  RabbitSender
//
//  Created by ChenYuan's Macbook Pro on 2021/3/2.
//  Copyright © 2021 ChenYuan's Macbook. All rights reserved.
//

import UIKit

class RMQFileTool: NSObject {

    static func writeFileToPathDocument(text: String, file: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(file)
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
    }
    
    static func readFileFromPathDocument(file: String) -> String {
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
    static func getPaths(inPath path:String) -> [String] {
        let manager = FileManager.default
        var contentsOfPath:[String]?
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
    
    static func IsfileExists(path:String){

            let  fileManager = FileManager.default

            let result = fileManager.fileExists(atPath: path)

            if result {
                print("yes")
            }else{
                print("false")
            }
        }
    
    static func deleteFile(inPathURL url:URL) -> Bool {
        let manager = FileManager.default
        do {
            try manager.removeItem(at: url)
            return true
        } catch  {
            return false
        }
    }
    
    static func getFileFullPath(withFileName fileName: String) -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            return fileURL
        }
        return nil
    }
}
