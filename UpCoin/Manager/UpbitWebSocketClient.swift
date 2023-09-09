//
//  UpbitWebSocketClient1.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/07.
//

import UIKit
import RxSwift
import Starscream

typealias WebSocketEvent = Starscream.WebSocketEvent
typealias WebSocketClient = Starscream.WebSocketClient

final class UpbitWebSocketClient {
    
    enum Constant {
        static let webSocketURL = "wss://api.upbit.com/websocket/v1"
    }
    
    private var retryCount = 0
    private var reconnectTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var request: String
    var socket: WebSocket
    var isConnected = false
    let dataSubject = PublishSubject<Data>()
    
    init(request: String) {
        self.request = request
        var request = URLRequest(url: URL(string: Constant.webSocketURL)!)
        request.timeoutInterval = 1
        self.socket = WebSocket(request: request)
        self.socket.delegate = self
    }
    
    func start() {
        self.socket.connect()
    }
    
    func stop() {
        self.socket.disconnect()
    }
    
    func send() {
        self.socket.write(string: self.request)
    }
    
    func reconnect() {
        if retryCount < 5 { // 재연결을 최대 5번까지 시도
            retryCount += 1
            reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.start()
            }
        }
    }
    
    func beginBackgroundTask() {
        self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "WebSocketBackgroundTask", expirationHandler: {
            self.endBackgroundTask()
        })
    }

    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid
    }
}

extension UpbitWebSocketClient: WebSocketDelegate {
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.send()
            retryCount = 0  // 연결이 성공하면 재시도 횟수 초기화
            reconnectTimer?.invalidate()  // 재연결 타이머 중지
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            reconnect()  // 연결이 끊어졌을 때 재연결 로직 수행
        case .text(let string):
            print("Received text: \(string)")
        case .binary(let data):
            print(".binary")
            dataSubject.onNext(data)
        case .ping(_), .pong(_), .viabilityChanged(_), .reconnectSuggested(_), .cancelled:
            print(".ping(_), .pong(_), .viabilityChanged(_), .reconnectSuggested(_), .cancelled")
            break
        case .error(let error):
            isConnected = false
            print("Error: \(error?.localizedDescription ?? "")")
            dataSubject.onError(error ?? NSError(domain: "", code: -1, userInfo: nil))
            reconnect()  // 오류 발생 시 재연결 로직 수행
        case .peerClosed:
            isConnected = false
            print("The peer (server/client) closed the connection.")
            reconnect()  // 연결이 닫혔을 때 재연결 로직 수행
        }
    }
}

