//
//  ViewController.swift
//  CoinFlip Project
//
//  Created by Travis Young on 2/21/23.
//

import UIKit
import Charts
import TinyConstraints

class ViewController: UIViewController, AxisValueFormatter, UISearchBarDelegate {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let hourFromNow = 168 - value
        let date = Date()
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: Int(-hourFromNow), to: date)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter.string(from: modifiedDate)
    }
    
    let stack = UIStackView()
    let mainView = UIView()
    let chartDisplayView = UIView()
    var coinManager = CoinManager()
    var chartHelper = ChartHelper()
    var pageNumber = 1
    
    var firstCoinView = UIView()
    var secondCoinView = UIView()
    var thirdCoinView = UIView()
    
    var coinsDisplayed: [CoinModel] = []
    
    let prevButton = CustomButton(title: "Previous")
    let nextButton = CustomButton(title: "Next")
    
    let coinGraphLabel = UILabel()
    let coinGraphImage = UIImageView()
    let searchBar = UISearchBar()
    let dismissKeyboardButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        coinManager.delegate = self
        
        view.backgroundColor = UIColor(white: 1, alpha: 0.3)
        
        let margins = view.layoutMarginsGuide
        
        view.addSubview(mainView)
        mainView.edges(to: margins)
        
        mainView.addSubview(dismissKeyboardButton)
        mainView.addSubview(searchBar)
        
        dismissKeyboardButton.width(25)
        dismissKeyboardButton.height(25)
        dismissKeyboardButton.right(to: mainView)
        dismissKeyboardButton.centerY(to: searchBar)
        dismissKeyboardButton.backgroundColor = .clear
        dismissKeyboardButton.addTarget(self, action: #selector(dismissKeyboardPressed), for: .touchUpInside)
        dismissKeyboardButton.layer.cornerRadius = 5
        dismissKeyboardButton.setImage(UIImage(systemName: "chevron.down")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        
        dismissKeyboardButton.isHidden = true
        
        searchBar.backgroundImage = UIImage()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
        searchBar.left(to: mainView)
        searchBar.top(to: mainView)
        searchBar.rightToLeft(of: dismissKeyboardButton, offset: -10)
        searchBar.delegate = self
        
        mainView.addSubview(prevButton)
        prevButton.left(to: mainView, offset: 10)
        prevButton.bottom(to: mainView, offset: -20)
        prevButton.isHidden = true
        prevButton.addTarget(self, action: #selector(prevPressed), for: .touchUpInside)
        
        mainView.addSubview(nextButton)
        nextButton.right(to: mainView, offset: -10)
        nextButton.bottom(to: mainView, offset: -20)
        nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        
        mainView.addSubview(stack)
        stack.top(to: searchBar, offset: 50)
        stack.left(to: mainView)
        stack.right(to: mainView)
        stack.bottomToTop(of: prevButton, offset:5)
        stack.axis = .vertical
        stack.spacing = 20.0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        
        view.addSubview(chartDisplayView)
        chartDisplayView.edges(to: margins)
        
        let closeButton = CustomButton(title: "Close")
        chartDisplayView.addSubview(closeButton)
        closeButton.centerX(to: chartDisplayView)
        closeButton.bottom(to: chartDisplayView, offset: -50)
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        
        coinGraphLabel.textColor = .white
        coinGraphLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        chartDisplayView.addSubview(coinGraphLabel)
        
        coinGraphLabel.centerX(to: chartDisplayView)
        coinGraphLabel.top(to: chartDisplayView, offset: 50)
        
        chartDisplayView.addSubview(coinGraphImage)
        coinGraphImage.center(in: chartDisplayView)
        coinGraphImage.width(to: chartDisplayView)
        coinGraphImage.heightToWidth(of: chartDisplayView)
        
        chartDisplayView.isHidden = true
        
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        
        swipeGestureRecognizerLeft.direction = .left
        swipeGestureRecognizerRight.direction = .right
        
        stack.addGestureRecognizer(swipeGestureRecognizerLeft)
        stack.addGestureRecognizer(swipeGestureRecognizerRight)
        
        coinManager.getCoinData(page: pageNumber)
    }
    
//Mark: - UI Functions
    
    func displayChart() {
        
        dismissKeyboardFromScreen()
        
        mainView.isHidden = true
        
        chartDisplayView.addSubview(chartHelper.lineChartView)
        chartHelper.lineChartView.edges(to: coinGraphImage)
        chartHelper.lineChartView.animate(xAxisDuration: 2.5)
        chartHelper.lineChartView.xAxis.valueFormatter = self
        
        chartDisplayView.isHidden = false
    }
    
    func createCoinView(coin : CoinModel) -> UIView {
        let coinView = UIView()
        
        let coinImage = UIImageView()
        coinImage.load(url: URL(string: coin.coinImage)!)
        coinView.addSubview(coinImage)
        coinImage.left(to: coinView, offset: 10)
        coinImage.centerY(to: coinView)
        coinImage.width(100)
        coinImage.height(100)
        
        let oneHourLabel = UILabel()
        oneHourLabel.textColor = UIColor.white
        oneHourLabel.text = "1h:"
        coinView.addSubview(oneHourLabel)
        oneHourLabel.centerY(to: coinView)
        oneHourLabel.centerX(to: coinView, offset: -30)
        
        let percentage1hourLabel = UILabel()
        percentage1hourLabel.text = "\(String(format: "%.1f", coin.percentage1hour))%"
        if (coin.percentage1hour < 0.0) {
            percentage1hourLabel.textColor = UIColor(named: "negativeColor")
        } else {
            percentage1hourLabel.textColor = UIColor(named: "positiveColor")
        }
        coinView.addSubview(percentage1hourLabel)
        percentage1hourLabel.leftToRight(of: oneHourLabel, offset: 5)
        percentage1hourLabel.top(to: oneHourLabel)
        
        let twentyFourHourLabel = UILabel()
        twentyFourHourLabel.textColor = UIColor.white
        twentyFourHourLabel.text = "24h:"
        coinView.addSubview(twentyFourHourLabel)
        twentyFourHourLabel.topToBottom(of: oneHourLabel, offset: 10)
        twentyFourHourLabel.left(to: oneHourLabel)
        
        let percentage24hourLabel = UILabel()
        percentage24hourLabel.text = "\(String(format: "%.1f", coin.percentage24hours))%"
        if (coin.percentage24hours < 0.0) {
            percentage24hourLabel.textColor = UIColor(named: "negativeColor")
        } else {
            percentage24hourLabel.textColor = UIColor(named: "positiveColor")
        }
        coinView.addSubview(percentage24hourLabel)
        percentage24hourLabel.leftToRight(of: twentyFourHourLabel, offset: 5)
        percentage24hourLabel.top(to: twentyFourHourLabel)
        
        let sevenDayLabel = UILabel()
        sevenDayLabel.textColor = UIColor.white
        sevenDayLabel.text = "7d:"
        coinView.addSubview(sevenDayLabel)
        sevenDayLabel.left(to: twentyFourHourLabel)
        sevenDayLabel.topToBottom(of: twentyFourHourLabel, offset: 10)
        
        let percentage7dayLabel = UILabel()
        percentage7dayLabel.text = "\(String(format: "%.1f", coin.percentage7days))%"
        if (coin.percentage7days < 0.0) {
            percentage7dayLabel.textColor = UIColor(named: "negativeColor")
        } else {
            percentage7dayLabel.textColor = UIColor(named: "positiveColor")
        }
        coinView.addSubview(percentage7dayLabel)
        percentage7dayLabel.leftToRight(of: sevenDayLabel, offset: 5)
        percentage7dayLabel.top(to: sevenDayLabel)
        
        let currencyLabel = UILabel()
        currencyLabel.text = "Price: $\(String(format: "%.2f", coin.currency))"
        currencyLabel.textColor = UIColor.white
        coinView.addSubview(currencyLabel)
        currencyLabel.left(to: oneHourLabel)
        currencyLabel.bottomToTop(of: oneHourLabel, offset: -10)
        
        let coinNameLabel = UILabel()
        coinNameLabel.text = coin.name
        coinNameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        coinNameLabel.textColor = UIColor.white
        coinView.addSubview(coinNameLabel)
        coinNameLabel.left(to: currencyLabel)
        coinNameLabel.bottomToTop(of: currencyLabel, offset: -10)
        
        let coinSymbolLabel = UILabel()
        coinSymbolLabel.text = "- \(coin.symbol)".uppercased()
        coinSymbolLabel.textColor = UIColor.white
        coinView.addSubview(coinSymbolLabel)
        coinSymbolLabel.centerY(to: coinNameLabel)
        coinSymbolLabel.leftToRight(of: coinNameLabel, offset: 5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        coinView.addGestureRecognizer(tap)
        return coinView
    }
    
    func dismissKeyboardFromScreen() {
        searchBar.resignFirstResponder()
        dismissKeyboardButton.isHidden = true
    }
    
//Mark: - UI Actions
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        dismissKeyboardFromScreen()
        if (coinsDisplayed.count == 3) {
            if (sender.direction == .right) {
                if (pageNumber > 1) {
                    prevPressed()
                }
            } else if (sender.direction == .left) {
                nextPressed()
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tag = sender.view?.tag
        let coinSelected = coinsDisplayed[tag!]
        coinGraphLabel.text = "\(coinSelected.name) Price Chart (\(coinSelected.symbol.uppercased()))"
        coinGraphImage.load(url: URL(string: coinSelected.coinImage)!)
        coinGraphImage.layer.opacity = 0.2
        
        chartHelper.setData(coinSelected: coinSelected)
        displayChart()
    }
    
    @objc func nextPressed() {
        pageNumber += 1
        coinManager.getCoinData(page: pageNumber)
        
        prevButton.isHidden = false
    }
    
    @objc func prevPressed() {
        pageNumber -= 1
        coinManager.getCoinData(page: pageNumber)
        
        if (pageNumber <= 1) {
            prevButton.isHidden = true
        }
    }
    
    @objc func closePressed() {
        chartDisplayView.isHidden = true
        mainView.isHidden = false
        
        chartHelper.lineChartView.removeFromSuperview()
    }
    
    @objc func dismissKeyboardPressed() {
        dismissKeyboardFromScreen()
    }
    
//Mark: - Search Bar Functions
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        dismissKeyboardButton.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            coinManager.getCoinData(page: pageNumber)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboardFromScreen()
        
        if let searchedCoin = searchBar.text {
            getSearchResult(searchedCoin: searchedCoin)
        }
        
    }
    
    func getSearchResult (searchedCoin : String) {
        coinManager.getCoinData(searchedCoin: searchedCoin)
    }
}


//Mark: - UIImageViewView

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

//Mark: - CoinManagerDelegate

extension ViewController: CoinManagerDelegate {
    func didUpdateCoinData(_ coinManager: CoinManager, coins: [CoinModel]) {
        DispatchQueue.main.async {
            
            self.coinsDisplayed = coins
            self.stack.removeAllArrangedSubviews()
            
            for (index, coin) in coins.enumerated() {
                if (index == 0) {
                    self.firstCoinView = self.createCoinView(coin : coin)
                    self.firstCoinView.tag = 0;
                    self.stack.addArrangedSubview(self.firstCoinView)
                } else if (index == 1) {
                    self.secondCoinView = self.createCoinView(coin : coin)
                    self.secondCoinView.tag = 1;
                    self.stack.addArrangedSubview(self.secondCoinView)
                } else if (index == 2) {
                    self.thirdCoinView = self.createCoinView(coin : coin)
                    self.thirdCoinView.tag = 2;
                    self.stack.addArrangedSubview(self.thirdCoinView)
                }
            }
            
            if (self.coinsDisplayed.count < 3) {
                self.nextButton.isHidden = true
                self.prevButton.isHidden = true
            } else {
                self.nextButton.isHidden = false
                
                if(self.pageNumber > 1) {
                    self.prevButton.isHidden = false
                }
            }
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}






