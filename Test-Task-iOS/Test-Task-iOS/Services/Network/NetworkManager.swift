//
//  NetworkManager.swift
//  Test-Task-iOS
//
//  Created by Марк Киричко on 20.11.2025.
//

import Network

protocol INetworkManager: AnyObject {
    func checkInternetConnection(completion: @escaping(Bool)->Void)
}

final class NetworkManager: INetworkManager {
    
    private var monitor: NWPathMonitor?
    
    func checkInternetConnection(completion: @escaping(Bool)->Void) {
        
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                completion(path.status == .satisfied)
            }
            monitor.cancel()
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        self.monitor = monitor
    }
}
