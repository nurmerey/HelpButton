//
//  NetworkLayer.swift
//  HelpButton
//
//  Created by Nurmerey Shakhanova on 19/6/19.
//  Copyright © 2019 simulgirl. All rights reserved.
//

import Foundation

class NetworkLayer {



    enum NetworkError: Error {
        case url
        case server
    }

    func makePostAPICall() -> Result<String?, NetworkError> {
        guard let url = URL(string: Config.gistPath) else {
            return .failure(.url)
        }
        let loginData = String(format: "%@:%@", Config.username, Config.token).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = Data("{\"description\":\"HelpButton API\",\"public\":\"true\",\"files\":{\"help.txt\":{\"content\":\"Button Press!\"}}".utf8)
        return runDataTask(urlRequest: urlRequest)
    }

    func makeDeleteAPICall(gistId:String) -> Result<String?, NetworkError> {
        guard let url = URL(string: "\(Config.gistPath)/\(gistId)") else {
            return .failure(.url)
        }
        let loginData = String(format: "%@:%@", Config.username, Config.token).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        return runDataTask(urlRequest: urlRequest)

    }

    func makeGistWithDeviceInfo(deviceInfo:String) {
        let url = URL(string: Config.gistPath)
        let loginData = String(format: "%@:%@", Config.username, Config.token).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
        urlRequest.httpBody = Data("{\"description\":\"HelpButton API\",\"public\":\"true\",\"files\":{\"deviceInfo.txt\":{\"content\":\"\(deviceInfo))\"}}".utf8)
        let result = runDataTask(urlRequest: urlRequest)
        print("result", result)
    }

    func runDataTask(urlRequest:URLRequest)->Result<String?, NetworkError>{
        var result:Result<String?, NetworkError>!
        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: urlRequest){(data, _, _) in
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


