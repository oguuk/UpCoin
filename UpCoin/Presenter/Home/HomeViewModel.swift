//
//  HomeViewModel.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/06.
//

import UIKit
import RxSwift
import RxCocoa
import ActivityKit
import UpCoinWidgetExtension
import PushKit

final class HomeViewModel {
    
    struct Input {
        let keyboard: Observable<String>
    }
    
    struct Output {
        let stocks: Driver<[TickerResponse]> //Observable<[SectionModel<String, WebsocketTickerResponse>]>
        let coins: Observable<[TickerResponse]> //Observable<[SectionModel<String, WebsocketTickerResponse>]>
    }
    
    private let upbit: UpbitAPIManager = UpbitAPIManager()
    private var sockets: [String : UpbitWebSocketClient] = [:]
    private let soketsSubject: BehaviorSubject<[String : WebsocketTickerResponse]> = BehaviorSubject<[String : WebsocketTickerResponse]>(value: [:])
    private let searchResultsSubject: BehaviorSubject<[TickerResponse]> = BehaviorSubject<[TickerResponse]>(value: [])
    private var lastTradePrice: [String : Double] = [:]
    private let disposeBag: DisposeBag = DisposeBag()
    let starActionSubject = PublishSubject<IndexPath>()
    var activities: [String : Activity<UpCoinWidgetAttributes>] = [:]
    
    init() {
        configureSocket()
        addAppLifeCycleObservers()
    }
    
    func transform(input: Input) -> Output {
        let stocksObservable: Observable<[TickerResponse]> = input.keyboard
            .flatMapLatest { [weak self] text -> Observable<[TickerResponse]> in
                if text.isEmpty {
                    return self?.soketsSubject
                        .map { stocksDict -> [TickerResponse] in
                            return stocksDict.values
                                .sorted { $0.code < $1.code }
                                .compactMap { $0.toTickerResponse() }
                        }
                        .catch { error in
                            return Observable.just([])
                            
                        } ?? .empty()
                } else {
                    self?.searchStocks(coinName: text)
                    return self?.searchResultsSubject ?? .empty()
                }
            }

        return Output(stocks: stocksObservable.asDriver(onErrorJustReturn: []))
    }
    
    private func addAppLifeCycleObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appMovedToBackground() {
        print("DEBUG : appMovedToBackground")
        sockets.values.forEach { $0.beginBackgroundTask() }
    }

    @objc private func appMovedToForeground() {
        print("DEBUG : appMovedToForeground")

        sockets.values.forEach { $0.endBackgroundTask() }
    }
    
    func configureSocket() {
        CoreDataManager.default.fetch(type: BOOKMARK.self)?.forEach {
            fetchSocket(coin: $0.market!)
        }
    }
    
    func bookmark(market: String) {
        if !isBookmark(market: market) {
            if CoreDataManager.default.count(forEntityName: "BOOKMARK") > 5 { return }
            guard let datas = CoreDataManager.default.fetch(type: KRW.self, name: market),
                  let data = datas.first else { return }
            let marketValue = Market(market: data.market!, koreanName: data.koreanName!, englishName: data.englishName!)
            CoreDataManager.default.save(forEntityName: "BOOKMARK", value: marketValue)
            fetchSocket(coin: market)
        }
    }
    
    func unBookmark(market: String) {

        CoreDataManager.default.delete(type: BOOKMARK.self, name: market)
        sockets[market] = nil

        if var currentStocks = try? soketsSubject.value() {
            currentStocks[market] = nil
            soketsSubject.onNext(currentStocks)
        }
        activities.removeValue(forKey: market)
    }
    
    func isBookmark(market: String) -> Bool {
        return !(CoreDataManager.default.fetch(type: BOOKMARK.self, name: market)?.isEmpty ?? true)
    }
    
    func checkPrice(item: TickerResponse) -> Bool? {
        var returnValue: Bool? = nil
        if let price = lastTradePrice[item.market] {
            
            if price > item.tradePrice { returnValue = false }
            else if price < item.tradePrice { returnValue = true }
        }
        lastTradePrice[item.market] = item.tradePrice
        return returnValue
    }
    
    private func searchStocks(coinName: String) {
        guard let observables = (CoreDataManager.default
            .fetch(type: KRW.self, name: coinName)?
            .map { (krw) -> Observable<[TickerResponse]?> in
                UpbitAPIManager.default.fetchTicker(marketCode: krw.Market ?? "")
            }) else { return }
        
        Observable.combineLatest(observables)
            .subscribe(
                onNext: { [weak self] responses in
                    let updatedResponses = responses.compactMap { // 첫 번째 flatMap을 compactMap으로 변경
                        $0?.compactMap { // 두 번째 flatMap을 compactMap으로 변경
                            var newRes = $0
                            newRes.bookmark = self?.isBookmark(market: newRes.market) ?? false
                            return newRes
                        }
                    }
                    .flatMap { $0 } // 중첩된 배열을 평평하게 만들기 위한 flatMap
                    self?.searchResultsSubject.onNext(updatedResponses)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func fetchSocket(coin name: String) {
        
        CoreDataManager.default.fetch(type: KRW.self, name: name)?
            .forEach { coin in
                let request = "[{\"ticket\":\"UpCoin\"},{\"type\":\"ticker\",\"codes\":[\"\(coin.market!)\"]}]"
                let service = UpbitWebSocketClient(request: request)
                sockets[coin.market!] = service
                sockets[coin.market!]?.dataSubject
                    .subscribe(onNext: { [weak self] data in
                        do {
                            guard let ticker = try? JSONDecoder().decode(WebsocketTickerResponse.self, from: data) else { return }
                            if var currentStocks = try? self?.soketsSubject.value() {
                                currentStocks[ticker.code] = ticker
                                Task { [weak self] in
                                    await self?.startLiveActivity(ticker: ticker)
                                }
                                
                                self?.soketsSubject.onNext(currentStocks)
                            } else {
                                self?.soketsSubject.onNext([ticker.code: ticker])
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    })
                    .disposed(by: disposeBag)
                sockets[coin.market!]?.start()
        }
    }
}

// MARK: -LiveActivity
extension HomeViewModel {
    
    private func startLiveActivity(ticker: WebsocketTickerResponse) async {
        if #available(iOS 16.2, *) {
            if ActivityAuthorizationInfo().areActivitiesEnabled {
                let initialContentState = UpCoinWidgetAttributes.ContentState(
                    imageName: liveActivityImage(ticker: ticker),
                    price: ticker.tradePrice.formattedWithSeparator,
                    tradeVolume: ticker.accTradePrice24H.toPercentage(3),
                    fluctuationRate: "\(ticker.signedChangeRate.toPercentage(2, 100))%",
                    priceFluctuation: ticker.signedChangePrice.formattedWithSeparator, // 비트토렌트 같은 경우 0으로 나옴
                    state: ticker.signedChangePrice > 0 ? 1 : (ticker.signedChangePrice == 0 ? 0 : -1)
                )

                let activityAttributes = UpCoinWidgetAttributes(coinName: ticker.code)
                let activityContent = ActivityContent(state: initialContentState, staleDate: Calendar.current.date(byAdding: .minute, value: 10, to: Date())!)

                do {
                    if !activities.keys.contains(ticker.code) {
                        let activity = try Activity.request(attributes: activityAttributes, content: activityContent)
                        activities[ticker.code] = activity
                        print("Requested Lockscreen Live Activity(Timer) \(String(describing: activity.id)).")
                    } else {
                        print("update중")
                        try await activities[ticker.code]?.update(activityContent)
                    }
                } catch (let error) {
                    print("Error requesting Lockscreen Live Activity(Timer) \(error.localizedDescription).")
                }
            }
        }
    }
    
    private func liveActivityImage(ticker data: WebsocketTickerResponse) -> String {
        let curr = data.tradePrice, open = data.openingPrice, high = data.highPrice, low = data.lowPrice
        
        if curr > open {
            if high == curr {
                if open == low { return "bigRise" }
                else { return "rise1" }
            } else {
                if  open == low { return "rise3" }
                else { return "rise2" }
            }
        } else if curr < open {
            if low == curr {
                if open == high { return "bigFall" }
                else { return "fall3" }
            } else {
                if  open == high { return "fall1" }
                else { return "fall2" }
            }
        } else {
            if high == curr {
                if open == low { return "even" }
                else { return "even1" }
            } else {
                if  open == low { return "even3" }
                else { return "even2" }
            }
        }
    }
}
