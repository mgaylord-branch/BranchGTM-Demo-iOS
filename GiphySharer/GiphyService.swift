//
//  GiphyService.swift
//  GiphySharer
//
//  Created by Michael on 07/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import Foundation
import GiphyCoreSDK

struct GiphyService {
    
    static let shared = GiphyService()
    
    //Initializer access level change now
    private init(){
        GiphyCore.configure(apiKey: "FeTq994M6ed3ZVvraNAYSqmCY2hjkJOG")
    }
    
    @discardableResult func trending(
        _ completion: @escaping (_ media: [GPHMedia]?, _ error: Error?) -> Void
    ) -> Operation {
        debugPrint("Loading trending...")
        let operation = GiphyCore.shared.trending() { response, error in
            DispatchQueue.main.async {
                guard let data = response?.data else {
                    debugPrint("error: \(String(describing: error))")
                    completion(nil, error)
                    return
                }
                debugPrint("item count: \(String(describing: data.count))")
                completion(data, nil)
            }
        }
        operation.start()
        return operation
    }
    
    @discardableResult func get(byID giphyId: String,
             _ completion: @escaping (_ media: GPHMedia?, _ error: Error?) -> Void) -> Operation {
        let operation = GiphyCore.shared.gifByID(giphyId) { response, error in
            DispatchQueue.main.async {
                guard let data = response?.data else {
                    debugPrint("error: \(String(describing: error))")
                    completion(nil, error)
                    return
                }
                debugPrint("item with id: \(giphyId) retrieved successfully")
                completion(data, nil)
            }
        }
        operation.start()
        return operation
    }
}
