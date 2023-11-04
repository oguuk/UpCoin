//
//  UpbitAPIManager.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/07.
//

import Foundation
import RxSwift

final class UpbitAPIManager {
    
    static let `default` = UpbitAPIManager()
    
    enum Constant {
        static let baseURL: String = "https://api.upbit.com/v1"
        static let pathOfCheckMarketCode = "/market/all"
        static let pathOfCurrentPrice = "/ticker"
        static let pathOfCandles = "/candles"
        static let pathOfMinutes = "/minutes"
    }
    
    private let disposeBag = DisposeBag()
    
    func fetchTicker<T: Codable>(marketCode: String) -> Observable<[T]?> {
        return Observable.create { observer in
            let disposable = Network.default.get(url: Constant.baseURL + Constant.pathOfCurrentPrice, parameters: ["markets":marketCode])
                .subscribe(onNext: { result in
                    switch result {
                    case let .success(data):
                        print("DEBUG : \(String(data: data ?? Data(), encoding: .utf8))")
                        self.handleSuccess(data: data, observer: observer)
                    case let .failure(error):
                        print("\(markets) error \(error.localizedDescription)")
                        observer.onError(error)
                    }
                })
            
            return Disposables.create { disposable.dispose() }
        }
    }
    
    func fetchUpbitTradableMarkets() -> Observable<[Market]?> {
        return Observable.create { observer in
            let disposable = Network.default.get(url: Constant.baseURL + Constant.pathOfCheckMarketCode)
                .subscribe(onNext: { result in
                    switch result {
                    case let.success(data):
                        self.handleSuccess(data: data, observer: observer)
                    case let .failure(error):
                        observer.onError(error)
                    }
                })
            return Disposables.create { disposable.dispose() }
        }
    }
    
    func fetchCandles(kind: CandleAPIType, _ marketCode: String, _ to: String? = nil) -> Observable<[CandleData]?> {
        var param = to == nil ? ["market" : marketCode, "count" : 200] : ["market" : marketCode, "count" : 200, "to" : to!]
        return Observable.create { observer in
            let disposable = Network.default
                .get(url: Constant.baseURL + Constant.pathOfCandles + kind.rawValue,
                     parameters: param)
                .subscribe(onNext: { result in
                    switch result {
                    case let .success(data):
                        self.handleSuccess(data: data, observer: observer)
                    case let .failure(error):
                        print("\(marketCode) error \(error.localizedDescription)")
                        observer.onError(error)
                    }
                })
            
            return Disposables.create { disposable.dispose() }
        }
        
    }
    
    func fetchCandles(_ minutes: AvailableMinutesUnit,  _ marketCode: String, _ to: String? = nil) -> Observable<[CandleData]?> {
        return Observable.create { observer in
            let urlString = Constant.baseURL + Constant.pathOfCandles + Constant.pathOfMinutes + minutes.rawValue
            var param = to == nil ? ["market" : marketCode, "count" : 200] : ["market" : marketCode, "count" : 200, "to" : to!]
            let disposable = Network.default
                .get(url: urlString,
                     parameters: param)
                .subscribe(onNext: { result in
                    switch result {
                    case let .success(data):
                        self.handleSuccess(data: data, observer: observer)
                    case let .failure(error):
                        print("\(marketCode) error \(error.localizedDescription)")
                        observer.onError(error)
                    }
                })
            
            return Disposables.create { disposable.dispose() }
        }
        
    }
    
    private func handleSuccess<T: Codable>(data: Data?, observer: AnyObserver<[T]?>) {
        guard let data = data else {
            observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data is nil"]))
            return
        }
        
        do {
            let response = try JSONDecoder().decode([T].self, from: data)
            observer.onNext(response)
            observer.onCompleted()
        } catch {
            print("Decoding error: \(error)")
            observer.onError(error)
        }
    }
}

