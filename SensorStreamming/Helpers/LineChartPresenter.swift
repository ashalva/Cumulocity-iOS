//
//  LineChartPresenter.swift
//  SensorStreamming
//
//  Created by Shalva Avanashvili on 11/09/2018.
//  Copyright © 2018 Shalva Avanashvili. All rights reserved.
//

import UIKit
import Charts


class LineChartPresenter {
    let chart: LineChartView!
    
    private var previousX: Double = 0.0
    private var xDelimeter: Double = 1.0
    
    private var xData: [ChartDataEntry] = []
    private var yData: [ChartDataEntry] = []
    private var zData: [ChartDataEntry] = []
    private let chartXLimit: Int
    
    init(chartFrame: CGRect, chartXLimit: Int = 10) {
        self.chart = LineChartView(frame: chartFrame)
        self.chartXLimit = chartXLimit
    }
    
    func set(description: String) {
        chart.chartDescription?.text = description
    }
    
    func append(chartX: Double, chartY: Double, chartZ: Double) {
        let lineData = LineChartData(dataSets: [constructXData(chartX),
                                                constructYData(chartY),
                                                constructZData(chartZ)])
        
        chart.data = lineData
        if previousX > 5 {
            chart.moveViewToX(previousX - 5)
        }
        previousX += 1.0
    }
    
    private func append(_ entry: ChartDataEntry, to entries: [ChartDataEntry]) -> [ChartDataEntry] {
        var newEntries = entries
        newEntries.append(entry)
        
        guard entries.count > chartXLimit else { return newEntries }
        
        newEntries.remove(at: 0)
        return newEntries
    }
    
    private func constructXData(_ x: Double) -> LineChartDataSet {
        xData = append(ChartDataEntry(x: previousX, y: x), to: xData)
        let dataSet = LineChartDataSet(values: xData, label: "X")
        setStyle(for: dataSet)
        
        return dataSet
    }
    
    private func constructYData(_ y: Double) -> LineChartDataSet {
        yData = append(ChartDataEntry(x: previousX, y: y), to: yData)
        let dataSet = LineChartDataSet(values: yData, label: "Y")
        setStyle(for: dataSet, lineColor: .blue)
        
        return dataSet
    }
    
    private func constructZData(_ z: Double) -> LineChartDataSet {
        zData = append(ChartDataEntry(x: previousX, y: z), to: zData)
        let dataSet = LineChartDataSet(values: zData, label: "Z")
        setStyle(for: dataSet, lineColor: .red)
        
        return dataSet
    }
    
    private func setStyle(for dataSet: LineChartDataSet, lineColor: NSUIColor = .green) {
        dataSet.drawCirclesEnabled = false
        dataSet.setColor(lineColor)
    }
}
