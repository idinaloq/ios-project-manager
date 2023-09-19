//
//  ProjectManager - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

//import UIKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//    }
//
//
//}

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    var databasePath = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib. // DB Check
        let fileMgr = FileManager.default
        
        // 파일 찾기, 유저 홈 위치
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(dirPath)
        // Document 경로
        let docsDir = dirPath[0]
        print(docsDir)
        
        // Document/contacts.db라는 경로(커스터마이징 db임)
        databasePath = docsDir.appending("/contacts.db")
        print(databasePath)
        
        if !fileMgr.fileExists(atPath: databasePath) {
            // DB 접속
            let contactDB = FMDatabase(path: databasePath)
            
            if contactDB.open() {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS CONTACTS ( ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER )"
                if !contactDB.executeStatements(sql_stmt){
                    print("Error : contactDB execute Fail, \(contactDB.lastError())")
                }
                contactDB.close()
                
            } else {
                print("Error : contactDB open Fail, \(contactDB.lastError())")
            }
        } else {
            print("contactDB is exist")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func saveBtnClicked(_ sender: UIButton) {
        // DB접속
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            print("[Save to DB Name : \(nameTextField.text!) Age : \(ageTextField.text!)")
            let insertSQL = "INSERT INTO CONTACTS (NAME, AGE) values ('\(nameTextField.text!)', '\(ageTextField.text!)')"
            print(insertSQL)
            let result = contactDB.executeUpdate(insertSQL, withArgumentsIn: [])
            if !result{
                resultLabel.text = "Fail to add contact"
                print("Error : contactDB add Fail, \(contactDB.lastError())")
            } else {
                resultLabel.text = "Success to add contact"
                nameTextField.text = ""
                ageTextField.text = ""
            }
        } else {
            print("Error : contactDB open Fail, \(contactDB.lastError())")
        }
    }

    @IBAction func findBtnClicked(_ sender: UIButton) {
        // DB접속
        let contactDB = FMDatabase(path: databasePath)
        if contactDB.open(){
            print("[Find to DB Name : \(nameTextField.text!) Age : \(ageTextField.text!)")
            let selectSQL = "SELECT NAME, AGE FROM CONTACTS WHERE NAME = '\(nameTextField.text!)'"
            print(selectSQL)
            do {
                let result = try contactDB.executeQuery(selectSQL, values: [])
                if result.next(){
                    ageTextField.text = result.string(forColumn: "AGE")
                    resultLabel.text = "\(result.string(forColumn: "NAME")!) find!"
                } else {
                    nameTextField.text = ""
                    ageTextField.text = ""
                    resultLabel.text = "Record is not founded"
                }
            } catch  {
                print("error")
            }
        } else {
            print("Error : contactDB open Fail, \(contactDB.lastError())")
        }
    }
}
