//
//  InteractiveCanvasSocket.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 3/16/21.
//  Copyright © 2021 Eric Versteeg. All rights reserved.
//

import UIKit
import SocketIO

protocol InteractiveCanvasSocketConnectionDelegate: AnyObject {
    func notifySocketConnect()
    func notifySocketDisconnect()
    func notifySocketConnectionError()
}

class InteractiveCanvasSocket: NSObject, URLSessionDelegate {
    
    static let instance = InteractiveCanvasSocket()
    
    weak var socketConnectionDelegate: InteractiveCanvasSocketConnectionDelegate?
    
    var manager: SocketManager!
    var socket: SocketIOClient? = nil
    
    var isConnected = false
    
    func startSocket(server: Server) {
        // socket init
        //manager = SocketManager(socketURL: URL(string: "https://192.168.200.69:5010")!, config: [.log(true), .compress, .selfSigned(true), .sessionDelegate(self)])
        
        manager = SocketManager(socketURL: URL(string: server.socketUrl())!, config: [.log(true), .reconnectAttempts(0), .forceWebsockets(true)])
        
        socket = manager.defaultSocket
        
        socket?.connect(timeoutAfter: 5) {
            self.socketConnectionDelegate?.notifySocketConnectionError()
        }
        
        socket?.on(clientEvent: .connect) { (data, ack) in
            print(data)
            self.socket?.emit("connect2")
            self.socketConnectionDelegate?.notifySocketConnect()
            self.isConnected = true
        }
        
        socket?.on(clientEvent: .disconnect) { (data, ack) in
            print(data)
            
            DispatchQueue.main.async {
                self.socketConnectionDelegate?.notifySocketDisconnect()
            }
            self.isConnected = false
        }
        
        socket?.on(clientEvent: .error) { (data, ack) in
            print(data)
            
            DispatchQueue.main.async {
                self.socketConnectionDelegate?.notifySocketConnectionError()
            }
            self.isConnected = false
        }
    }
    
    func disconnect() {
        socket?.disconnect()
        //self.socketConnectionDelegate = nil
    }
    
    /*func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }*/
}
