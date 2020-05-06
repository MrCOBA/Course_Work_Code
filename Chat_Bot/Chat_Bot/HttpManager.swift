//
//  HttpManager.swift
//  Chat_Bot
//
//  Created by OparinOleg on 23.01.2020.
//  Copyright © 2020 OparinOleg. All rights reserved.
//

import Foundation
import UIKit

class HTTPManager:NSObject{
    
    var completionHandler: ((Data)-> Void)!
    
    func retrieveURL(_ url: URL, completionHandler: @escaping ((Data) -> Void)){
        self.completionHandler = completionHandler;
        let request: URLRequest = URLRequest(url: url);
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil);
        let task: URLSessionDownloadTask = session.downloadTask(with: request);
        task.resume();
    }
}

extension HTTPManager: URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        
        do{
            let data: Data = try Data(contentsOf: location)
            DispatchQueue.main.async(){
                self.completionHandler(data);
            }
        }
        catch{
            print("Can't get data from location.");
        }
        
    }
}
