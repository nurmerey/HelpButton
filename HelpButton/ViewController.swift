//
//  ViewController.swift
//  HelpButton
//
//  Created by Nurmerey Shakhanova on 14/6/19.
//  Copyright © 2019 simulgirl. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var helpButtonGistId: String? = nil
    var networkLayer: NetworkLayer! = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    @IBOutlet weak var helpButtonReference: UIButton!
    @IBOutlet weak var deleteButtonReference: UIButton!
    var bleDevice:CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkLayer = NetworkLayer();
        centralManager = CBCentralManager(delegate: self, queue: nil)

        if(self.helpButtonGistId==nil){
            self.deleteButtonReference.isEnabled = false;
            self.deleteButtonReference.alpha = 0.3;
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {

        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)//[myBLEServiceCBUUID])
        @unknown default:
            print("fatal error!")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if(peripheral.identifier.description=="375DFD02-7B00-D7BC-ACA3-9CCFC2D7D415"){ // feel free to plug in your favorite ble device UUID
            centralManager.stopScan()
            bleDevice = peripheral
            centralManager.connect(bleDevice)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!", peripheral)
        self.activityIndicator.startAnimating();
        self.networkLayer.makeGistWithDeviceInfo(deviceInfo: peripheral.description)
        self.activityIndicator.stopAnimating();
    }
    
    @IBAction func helpButton(_ sender: UIButton) {
        activityIndicator.startAnimating();
        handleCreateGist();
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        activityIndicator.startAnimating();
        handleDeleteGist()
    }


    func handleCreateGist() {
        DispatchQueue.global(qos: .utility).async {
            let result = self.networkLayer.makePostAPICall()
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    let data = self.convertJSONStringToDictionary(text: data!);
                    let gistId = data?.object(forKey:"id") as! String;
                    self.helpButtonGistId = gistId;
                    self.deleteButtonReference.isEnabled = true;
                    self.deleteButtonReference.alpha = 1;
                    self.helpButtonReference.isEnabled = false;
                    self.helpButtonReference.alpha = 0.3;
                    self.activityIndicator.stopAnimating();
                case let .failure(error):
                    print("ERROR", error)
                }
            }
        }
    }

    func convertJSONStringToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data) as? NSDictionary;
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }


    func handleDeleteGist() {
        DispatchQueue.global(qos: .utility).async {
            let result = self.networkLayer.makeDeleteAPICall(gistId:self.helpButtonGistId ?? "")
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.helpButtonGistId = nil;
                    self.helpButtonReference.isEnabled = true;
                    self.helpButtonReference.alpha = 1;
                    self.deleteButtonReference.isEnabled = false;
                    self.deleteButtonReference.alpha = 0.3;
                    self.activityIndicator.stopAnimating();
                case let .failure(error):
                    print("ERROR", error)
                }
            }
        }
    }

    

    

}

