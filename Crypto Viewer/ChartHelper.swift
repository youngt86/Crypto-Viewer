//
//  ChartHelper.swift
//  CoinFlip Project
//
//  Created by Travis Young on 3/2/23.
//

import Foundation
import Charts

struct ChartHelper {
    
    lazy var lineChartView: LineChartView = {
       let chartView = LineChartView()
        
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisLineColor = .white
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.legend.enabled = false
        return chartView
    }()
    
    mutating func setData(coinSelected: CoinModel) {
                
        var yValues: [ChartDataEntry] = []

        for (index, element) in coinSelected.prices.enumerated() {
            yValues.append(ChartDataEntry(x: Double(index), y: element))
        }
        
        let dataSet = LineChartDataSet(entries: yValues)
        
        dataSet.drawCirclesEnabled = false
        
        var dataColor : String
        if (coinSelected.percentage7days < 0.0) {
            dataColor = "negativeColor"
        } else {
            dataColor = "positiveColor"
        }
                
        dataSet.setColor(UIColor(named: dataColor)!)
        dataSet.fill = ColorFill(color: UIColor(named: dataColor)!)
        dataSet.fillAlpha = 0.2
        dataSet.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: dataSet)
        
        lineChartView.drawMarkers = true
        data.setDrawValues(false)
        lineChartView.data = data
        
        let marker = CustomMarkerView()
        marker.chartView = lineChartView
        lineChartView.marker = marker
    }
}

