//
//  DBASRSettingVC.swift
//  DBAudioSDKDemo
//
//  Created by 林喜 on 2023/5/26.
//

import UIKit

@objc protocol DBAsetSettingDelegate {
    
    @objc optional func updateAsr(server:String, isVad: Bool, maxEndSilence:Int, maxBeginSilence:Int , version:String)
    
    @objc optional func updateAser(longAsr server:String,version:String)
}

class DBASRSettingVC: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var serverTF: UITextField!
    
    @IBOutlet weak var vadSwitch: UISwitch!
    
    @IBOutlet weak var maxEndSilence: UITextField!
    
    @IBOutlet weak var maxBeginSilence: UITextField!
    
    @IBOutlet weak var versionTF: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @objc public  var delegate:DBAsetSettingDelegate?
    
    @objc public var isLongAsr = false
    
    override func viewDidLoad() {
        precondition(delegate != nil,"DBASRSettingVC precondition need set a delegate")
        resumeData()
        if isLongAsr  {
            vadSwitch.isOn = false
            vadSwitch.isEnabled = false;
            disableTextField(maxBeginSilence)
            disableTextField(maxEndSilence)
        }

    }

    @IBAction func saveButton(_ sender: UIButton) {
        let array = [serverTF.text, maxEndSilence.text,maxBeginSilence.text,serverTF.text,versionTF.text]
        let resultArray: [()] = array.enumerated().map { (index,element) in
            guard !element!.isEmpty else {
                print("index \(index) is inValid")
                return
            }
        }
        print("result array \(resultArray)")
        let version = versionTF.text ?? "1.0"
        if isLongAsr {
            let server = serverTF.text!
            delegate?.updateAser?(longAsr: server,version:version)
            save(longAsr: server,version: version)
        }else {
            let vad = vadSwitch.isOn
            let mes = Int(maxEndSilence.text ?? "0")!
            let mbs = Int(maxBeginSilence.text ?? "0")!
            let server = serverTF.text!
            delegate?.updateAsr?(server: serverTF.text!, isVad: vad, maxEndSilence: mes , maxBeginSilence: mbs,version:version)
            saveData(vad,server:server, mes: mes, mbs: mbs,version: version)
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func resumeData() {
        let userDefault = UserDefaults.standard
        if isLongAsr {
            let longServer = userDefault.string(forKey: "longServer")
            let version = userDefault.string(forKey: "longVersion")
            serverTF.text = longServer
            versionTF.text = version
            return
        }
        let server = userDefault.string(forKey: "server")
        let mes = userDefault.integer(forKey: "mes")
        let mbs = userDefault.integer(forKey: "mbs")
        let isOnVad = userDefault.bool(forKey: "vad")
        let version = userDefault.string(forKey: "version")
        serverTF.text = server
        vadSwitch.isOn = isOnVad
        maxEndSilence.text = String(mes)
        maxBeginSilence.text = String(mbs)
        versionTF.text = version
    }
    
    
    // MARK: Save Data
    
    private func saveData(_ isVad:Bool = false, server:String, mes:Int = 0, mbs:Int = 0, version:String = "1.0") {
        let userDefault = UserDefaults.standard
        if isLongAsr {
            userDefault.set(server, forKey: "longServer")
            userDefault.set(version, forKey: "longVersion")
            return
        }
        userDefault.set(version, forKey: "version")
        userDefault.set(server, forKey: "server")
        userDefault.set(mes, forKey: "mes")
        userDefault.set(mbs, forKey: "mbs")
        userDefault.set(isVad, forKey: "vad")
    }
    
    //  Save long asr
    private func save(longAsr server:String, version:String) {
        saveData(server: server,version: version)
    }
    
    private func disableTextField(_ tv:UITextField) {
        tv.text = "0"
        tv.textColor = UIColor.lightGray
        tv.isEnabled = false
    }
    
    
    // MARK: TextField delegate
    
}


