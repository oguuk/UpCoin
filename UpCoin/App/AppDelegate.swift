//
//  AppDelegate.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/05.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let result = BGTaskScheduler.shared.register(forTaskWithIdentifier: "oguuk.UpCoin.process",
                                                   using: nil) { task in
            self.handleAppProcess(task: task as! BGProcessingTask)
            
        }
        
        UpbitAPIManager().fetchUpbitTradableMarkets()
            .subscribe(onNext: { markets in
                markets?.forEach { market in
                    switch market.market.split(separator: "-").first {
                    case "KRW": CoreDataManager.default.save(forEntityName: "KRW", value: market)
                    case "BTC": CoreDataManager.default.save(forEntityName: "BTC", value: market)
                    default: CoreDataManager.default.save(forEntityName: "USDT", value: market)
                    }
                }
                
                let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                sceneDelegate.hideSpinnerView()
            })
            .disposed(by: disposeBag)
        return true
    }
    
    func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "oguuk.UpCoin.process")
        request.requiresNetworkConnectivity = true // we need internet
        request.requiresExternalPower = false // Don't need device charging
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5) // 5초 후
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("BGTask 백그라운드 작업 예약에 실패했습니다: \(error)")
        }
    }
    
    func handleAppProcess(task: BGProcessingTask) {
        scheduleAppRefresh() // 다음 작업 예약
        
        guard let bookmarks: [BOOKMARK] = CoreDataManager.default.fetch(type: BOOKMARK.self) else {
            task.setTaskCompleted(success: false)
            return
        }
        
        let group = DispatchGroup()
                
        for bookmark in bookmarks {
            guard let market = bookmark.value(forKey: "market") as? String else {
                print("Error retrieving market from bookmark")
                continue
            }
            group.enter()
            let disposable = UpbitAPIManager.default.fetchTicker(marketCode: market)
                .subscribe(onNext: { (result: [TickerResponse]?) in
                    group.leave()
                    // 위젯에 표시할 데이터로 변환하고 저장하는 코드
                }, onError: { error in
                    print("백그라운드 작업 중 오류 발생: \(error)")
                    group.leave()
                })

            task.expirationHandler = {
                disposable.dispose()
            }
        }

        group.notify(queue: .main) {
            task.setTaskCompleted(success: true)
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "UpCoin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
