//
//  ChartView.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/14.
//

import UIKit
import DGCharts

final class ChartView: UIView {
    
    private var candleUnit: CandleAPIType?
    private var candleChartView: CandleStickChartView = CandleStickChartView()
    private var barChartView: BarChartView = BarChartView()
    var chartDatas: [CandleData]
    
    init(_ chartDatas: [CandleData], _ candleUnit: CandleAPIType) {
        self.candleUnit = candleUnit
        self.chartDatas = chartDatas.reversed()
        super.init(frame: .zero)
        configureUI()
        configureCandleChartView()
        self.setCandleSticks(chartDatas)
        self.setBarSticks(chartDatas)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        [candleChartView, barChartView].forEach {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        configureCandleChartView()
        configureBarChartView()
        
        layoutUI()
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            candleChartView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            candleChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            candleChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
            candleChartView.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 150),
            
            barChartView.topAnchor.constraint(equalTo: candleChartView.bottomAnchor, constant: 10),
            barChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            barChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 8),
            barChartView.heightAnchor.constraint(equalToConstant: 160),
        ])
    }
    
    private func configureCandleChartView() {
        var kstRange = 3...4
        let separator = candleUnit == nil ? ":" : "/"
        
        if let candleUnit = self.candleUnit {
            if candleUnit == .day || candleUnit == .week {
                kstRange = 1...2
            } else if candleUnit == .month {
                kstRange = 0...1
            }
        }
        
        candleChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartDatas
            .map { $0.candleDateTimeKst.candleDateTimeKstToArray[kstRange] }
            .map { d -> String in
                d.compactMap { $0 }.map { String(format: "%02d", Int($0)) }.joined(separator: separator)
            }
        )
        
        candleChartView.leftAxis.enabled = false
        candleChartView.rightAxis.labelFont = .systemFont(ofSize: 6)
        candleChartView.rightAxis.labelTextColor = .white
        candleChartView.legend.enabled = false
        candleChartView.scaleXEnabled = false
        candleChartView.scaleYEnabled = false
        candleChartView.xAxis.labelTextColor = .white
        candleChartView.xAxis.labelPosition = .bottom
        candleChartView.xAxis.labelFont = .systemFont(ofSize: 8)
        candleChartView.autoScaleMinMaxEnabled = true
    }
    
    private func configureBarChartView() {
        var kstRange = 3...4
        let separator = candleUnit == nil ? ":" : "/"
        
        if let candleUnit = self.candleUnit {
            if candleUnit == .day || candleUnit == .week {
                kstRange = 1...2
            } else if candleUnit == .month {
                kstRange = 0...1
            }
        }
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: chartDatas
            .map { $0.candleDateTimeKst.candleDateTimeKstToArray[kstRange] }
            .map { d -> String in
                d.compactMap { $0 }.map { String(format: "%02d", Int($0)) }.joined(separator: separator)
            }
        )

        barChartView.leftAxis.enabled = false
        barChartView.rightAxis.labelFont = .systemFont(ofSize: 6)
        barChartView.rightAxis.labelTextColor = .white
        barChartView.legend.enabled = false
        barChartView.scaleYEnabled = false
        barChartView.xAxis.labelTextColor = .white
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelFont = .systemFont(ofSize: 8)
        barChartView.autoScaleMinMaxEnabled = true
        barChartView.scaleXEnabled = false
    }
    
    func setCandleSticks(_ candleDatas: [CandleData]) {
        var dataEntries: [CandleChartDataEntry] = []
        
        for (i, data) in candleDatas.enumerated() {
            let reversedIndex = candleDatas.count - 1 - i
            let dataEntry = CandleChartDataEntry(x: Double(reversedIndex),
                                                 shadowH: data.highPrice,
                                                 shadowL: data.lowPrice,
                                                 open: data.openingPrice,
                                                 close: data.tradePrice
            )
            dataEntries.append(dataEntry)
        }
        
        let dataSet = CandleChartDataSet(entries: dataEntries)
        dataSet.highlightEnabled = true
        configureCandleChartColor(dataSet)
        let data = CandleChartData(dataSet: dataSet)
        candleChartView.data = data
    }
    
    func setBarSticks(_ candleDatas: [CandleData]) {
        var dataEntries: [BarChartDataEntry] = []
                
        for (i, data) in candleDatas.enumerated() {
            let reversedIndex = candleDatas.count - 1 - i
            let dataEntry = BarChartDataEntry(x: Double(reversedIndex), y: data.candleAccTradePrice)
            dataEntries.append(dataEntry)
        }
        
        let dataSet = BarChartDataSet(entries: dataEntries)
        dataSet.setColor(.gray)
        dataSet.colors = candleDatas.map { $0.openingPrice > $0.tradePrice ? .systemPink : .green }
        let data = BarChartData(dataSet: dataSet)
        barChartView.data = data
    }
    
    private func configureCandleChartColor(_ dataSet: CandleChartDataSet) {
        dataSet.decreasingColor = .systemPink
        dataSet.increasingColor = .green
        dataSet.neutralColor = .gray
        dataSet.shadowWidth = 0.2
        dataSet.shadowColorSameAsCandle = true
        dataSet.increasingFilled = true
        dataSet.decreasingFilled = true
        dataSet.setDrawHighlightIndicators(true)
    }
}
