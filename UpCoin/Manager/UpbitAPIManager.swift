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
    }
    
    private let disposeBag = DisposeBag()
    
    func fetchTicker<T: Codable>(markets: String) -> Observable<[T]?> {
        return Observable.create { observer in
            let disposable = Network.default.get(url: Constant.baseURL + Constant.pathOfCurrentPrice, parameters: ["markets":markets])
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

