//
//  ViewController.swift
//  HelpButton
//
//  Created by Nurmerey Shakhanova on 14/6/19.
//  Copyright © 2019 simulgirl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let createGistPath = "https://api.github.com/users/nurmerey/gists?public=true"
    let deleteGistPath = "https://google.com"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func helpButton(_ sender: UIButton) {
        print("Help Button");
        createGistAPICall();
    }
    @IBAction func cancelButton(_ sender: UIButton) {
        print("Cancel Button");
        deleteGistAPICall()
    }

    func createGistAPICall(){
        print("createGistAPICall")
        load(path:createGistPath)
    }

    func deleteGistAPICall(){
        print("deleteGistAPICall")
        load(path:deleteGistPath)
    }

    func load(path:String) {
        DispatchQueue.global(qos: .utility).async {
            let result = self.makeAPICall(path:path)
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    print("SUCCESS DATA", data ?? "empty data")
                case let .failure(error):
                    print("ERROR", error)
                }
            }
        }
    }

    

    enum NetworkError: Error {
        case url
        case server
    }
    func makeAPICall(path:String) -> Result<String?, NetworkError> {

        guard let url = URL(string: path) else {
            return .failure(.url)
        }
        var result:Result<String?, NetworkError>!
        let semaphore = DispatchSemaphore(value: 0)


        URLSession.shared.dataTask(with: url){(data, _, _) in
            if let data = data{
                result = .success(String(data: data, encoding: .utf8))
            }else{
                result = .failure(.server)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return result
    }


}

