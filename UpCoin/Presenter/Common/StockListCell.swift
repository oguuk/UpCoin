//
//  StockListCell.swift
//  UpCoin
//
//  Created by oguuk on 2023/09/06.
//

import UIKit

final class StockListCell: UITableViewCell, Identifiable {
    
    lazy var change: UIImageView = {
        let view = UIImageView()
        view.sizeToFit()
        return view
    }()
    
    lazy var coinName: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    lazy var market: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.font = .systemFont(ofSize: 8, weight: .light)
        return label
    }()
    
    lazy var price: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    lazy var priceFluctuation: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    lazy var tradingVolume: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 8, weight: .light)
        return label
    }()
    
    lazy var fluctuationRate: UILabel = {
        let label = UILabel()
        label.textColor = .green
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        change.image = nil
        coinName.text = nil
        change.image = nil
    }
    
    func configureUI() {
        backgroundColor = .black
        selectionStyle = .none
        [change, coinName, market,
         price, priceFluctuation, tradingVolume,
         fluctuationRate].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        [coinName, market].forEach {
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 0.5 // Adjust as needed
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }
    }
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            change.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            change.centerYAnchor.constraint(equalTo: centerYAnchor),
            change.widthAnchor.constraint(equalToConstant: 10),
            change.heightAnchor.constraint(equalToConstant: 20),
            
            coinName.bottomAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            coinName.leftAnchor.constraint(equalTo: change.rightAnchor, constant: 4),
            
            market.topAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            market.leftAnchor.constraint(equalTo: change.rightAnchor, constant: 4),
            
            fluctuationRate.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            fluctuationRate.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            priceFluctuation.rightAnchor.constraint(equalTo: rightAnchor, constant: -65),
            priceFluctuation.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            tradingVolume.topAnchor.constraint(equalTo: centerYAnchor),
            tradingVolume.trailingAnchor.constraint(equalTo: priceFluctuation.trailingAnchor),
            
            price.centerXAnchor.constraint(equalTo: centerXAnchor),
            price.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(ticker: TickerResponse) {
        coinName.text = CoreDataManager.default.fetch(type: KRW.self)?.filter { $0.market == ticker.market }.first?.koreanName ?? ""
        if ticker.change == "RISE" {
            change.tintColor = .green
            priceFluctuation.textColor = .green
            fluctuationRate.textColor = .green
        } else if ticker.change == "FALL" {
            change.tintColor = .systemPink
            priceFluctuation.textColor = .systemPink
            fluctuationRate.textColor = .systemPink
        } else {
            change.tintColor = .gray
            priceFluctuation.textColor = .gray
            fluctuationRate.textColor = .gray
        }
        market.text = ticker.market
        price.text = ticker.tradePrice.formattedWithSeparator
        priceFluctuation.text = ticker.signedChangePrice.formattedWithSeparator
        tradingVolume.text = "\(ticker.accTradePrice24H.toPercentage(3))"
        fluctuationRate.text = "\(ticker.signedChangeRate.toPercentage(2, 100))%"
    }
    
    func configureCandleImage(ticker data: TickerResponse) {
        let curr = data.tradePrice, open = data.openingPrice, high = data.highPrice, low = data.lowPrice
        
        if curr > open {
            if high == curr {
                if open == low { change.image = UIImage(named: "bigRise.png") }
                else { change.image = UIImage(named: "rise1.png") }
            } else {
                if  open == low { change.image = UIImage(named: "rise3.png") }
                else { change.image = UIImage(named: "rise2.png") }
            }
        } else if curr < open {
            if low == curr {
                if open == high { change.image = UIImage(named: "bigFall.png") }
                else { change.image = UIImage(named: "fall3.png") }
            } else {
                if  open == high { change.image = UIImage(named: "fall1.png") }
                else { change.image = UIImage(named: "fall2.png") }
            }
        } else {
            if high == curr {
                if open == low { change.image = UIImage(named: "even.png") }
                else { change.image = UIImage(named: "even1.png") }
            } else {
                if  open == low { change.image = UIImage(named: "even3.png") }
                else { change.image = UIImage(named: "even2.png") }
            }
        }
    }
    
    func highlightPrice(isRising: Bool) {
        if isRising {
            flashBorder(of: price, cgColor: UIColor.green.cgColor)
        } else {
            flashBorder(of: price, cgColor: UIColor.systemPink.cgColor)
        }
    }
    
    private func flashBorder(of label: UILabel, cgColor: CGColor) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = UIColor.clear.cgColor
        animation.toValue = cgColor
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.autoreverses = true

        label.layer.borderWidth = 1.0
        label.layer.add(animation, forKey: "borderColor")
    }
}
