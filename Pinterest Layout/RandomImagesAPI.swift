//
//  RandomImagesAPI.swift
//  Pinterest Layout
//
//  Created by Yash Shah on 13/03/22.
//

import Foundation

public enum RandomImagesAPIError: Error {
    case invalidURL
    case error(Error)
    case invalidResponse(URLResponse?)
    case invalidData(Data?)
}

public final class RandomImagesAPI {
    
    private let endpoint = "https://picsum.photos/v2/list"
    public static let shared = RandomImagesAPI()
    private var lastDataTask: URLSessionDataTask?
    
    private init() {}
    
    public func getRandomImages(pageIndex: Int, completionHandler: @escaping([ImageObject]?, Error?) -> Void) {
        var urlComponents = URLComponents(string: endpoint)
        urlComponents?.queryItems = [URLQueryItem(name: "page", value: "\(pageIndex)")]
        urlComponents?.queryItems = [URLQueryItem(name: "limit", value: "100")]
        guard let url = urlComponents?.url else {
            // Handle error here
            completionHandler(nil, RandomImagesAPIError.invalidURL)
            print("Cannot create URL from the given endpoint")
            return
        }
        lastDataTask?.cancel()
        lastDataTask = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            // If we received some error - handle it and return immediately
            if let error = error {
                completionHandler(nil, RandomImagesAPIError.error(error))
                print("You encountered an error here \(error.localizedDescription)")
                return
            }
            // Check for the HTTP response that you received and verify if the status code is in the range from 200 to 299
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completionHandler(nil, RandomImagesAPIError.invalidResponse(response))
                      print("You received an invalid status code \(String(describing: response))")
                      return
                  }
            guard let data = data,
                  let result = try? JSONDecoder().decode([ImageObject].self, from: data) else {
                      completionHandler(nil, RandomImagesAPIError.invalidData(data))
                      print("Encountered error while parsing the data")
                      return
                  }
            completionHandler(result, nil)
            print("Data successfully received \(result.count)")
        }
        lastDataTask?.resume()
    }
}
