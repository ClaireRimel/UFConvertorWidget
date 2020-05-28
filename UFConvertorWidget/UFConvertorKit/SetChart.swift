//
//  SetChart.swift
//  UFConvertorKit
//
//  Created by Claire on 28/05/2020.
//  Copyright © 2020 Claire Sivadier. All rights reserved.
//

import Foundation
import Charts

public struct SetChart {
    public let series: [Serie]
    
    public init(series: [Serie]) {
        self.series = series.reversed()
    }
    
    public func chartData() -> [ChartDataEntry] {
        var entries: [ChartDataEntry] = []
        
        for i in 0..<series.count-1 {
            entries.append( ChartDataEntry(x: Double(i), y: self.series[i].value))
        }
        return entries
    }
}
