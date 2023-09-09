//
//  Network.swift
//  UpStock
//
//  Created by 오국원 on 2023/07/28.
//

import Foundation
import RxSwift
import Alamofire

final class Network {
    
    static let `default` = Network()
    
    func get(url: String, parameters: [String : Any] = [:]) -> Observable<Result<Data?, AFError>> {
        return Observable.create { observer in
            let request = AF.request(url,
                                     method: .get,
                                     parameters: parameters)
                            .validate()
                            .response { response in
                                switch response.result {
                                case .success(let data):
                                    observer.onNext(.success(data))
                                case .failure(let error):
                                    observer.onNext(.failure(error))
                                }
                                observer.onCompleted()
                            }
            return Disposables.create { request.cancel() }
        }
    }
    
    func post(url: String, parameters: [String: Any]) -> Observable<Result<Data?, AFError>> {
        return Observable.create { observer in
            let request = AF.request(url,
                                     method: .post,
                                     parameters: parameters,
                                     encoding: JSONEncoding.default)
                             .validate()
                             .response { response in
                                switch response.result {
                                case .success(let data):
                                    observer.onNext(.success(data))
                                case .failure(let error):
                                    observer.onNext(.failure(error))
                                }
                                observer.onCompleted()
                             }
            
            return Disposables.create { request.cancel() }
        }
    }
}
