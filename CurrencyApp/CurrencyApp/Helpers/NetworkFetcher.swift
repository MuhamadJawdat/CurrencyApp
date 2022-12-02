//
//  NetworkFetcher.swift
//  CurrencyApp
//
//  Created by Muhamad jawdat Akoum on 02/12/2022.
//

import Foundation

class NetworkFetcher {
    class func fetchFixerData<T:Codable>(apiURL: String, onCompletion: @escaping (T)->()) {
        NetworkMonitor.shared.startMonitoring()
        guard let resourceURL = URL(string: apiURL) else {
            print("invalid url")
            return
        }
        var request = URLRequest(url: resourceURL)
        request.httpMethod = "GET"
        request.addValue("K11RbCa1n6x4f3ULWYlB7ogomlUOVoPQ", forHTTPHeaderField: "apikey")
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = self.extractData(data: data, error: error) else {
                return
            }
            if let jsonData = try? JSONDecoder().decode(T.self, from: data) {
                onCompletion(jsonData)
            } else {
                print("problem parsing response.\nResponse:\n\(String(decoding: data, as: UTF8.self))")
            }
        }
        dataTask.resume()
    }
    
    //Error Handling
    private class func extractData(data: Data?, error: Error?) -> Data? {
        // checks internet
        NetworkMonitor.shared.stopMonitoring()
        if !NetworkMonitor.shared.isReachable
            && (data == nil
                || error == nil) {
            print("Device is not connected to the internet, connect and try again")
            return nil
        }
        // checks error
        if let error = error {
            print("error occured \(error.localizedDescription)")
            return nil
        }
        //checks data
        guard let data = data else {
            print("invalid data")
            return nil
        }
        //returns data if available finally
        return data
    }
}
