//
//  ChartViewController.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/14.
//

import UIKit
import DGCharts

final class ChartViewController: UIViewController {
    
    private var chartView: UIView
    var ticker: TickerResponse
    
    required init(_ ticker: TickerResponse, _ chartView: UIView) {
        self.chartView = chartView
        self.ticker = ticker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = chartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
