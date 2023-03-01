//
//  TimeTrendDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 1/03/23.
//

import SwiftUI
import FLCharts
import UIKit

class TimeTrendViewController: UIViewController {
    var rawData: [MultiPlotable] {
        [MultiPlotable(name: "jan", values: [30, 24, 53]),
         MultiPlotable(name: "feb", values: [55, 44, 24]),
         MultiPlotable(name: "mar", values: [70, 15, 44]),
         MultiPlotable(name: "apr", values: [45, 68, 34]),
         MultiPlotable(name: "may", values: [85, 46, 12]),
         MultiPlotable(name: "jun", values: [46, 73, 32]),
         MultiPlotable(name: "jul", values: [75, 46, 53]),
         MultiPlotable(name: "aug", values: [10, 24, 24]),
         MultiPlotable(name: "set", values: [60, 74, 44]),
         MultiPlotable(name: "oct", values: [75, 72, 34]),
         MultiPlotable(name: "nov", values: [85, 10, 15]),
         MultiPlotable(name: "dec", values: [55, 66, 32])]
    }
    
    let chartKeys: [Key] = [
        Key(key: "a", color: .red),
        Key(key: "b", color: .blue),
        Key(key: "c", color: .blue),
    ]
    
    var lineChart: FLChart!
    
    var someBarButton: UIBarButtonItem?
    var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.label = UILabel()
//        label.backgroundColor = .green
//        label.frame = CGRect(x: 50, y: 10, width: 200, height: 100)
//        label.text = "test label"
//        self.view.addSubview(label)
        
        self.lineChart = FLChart(data: FLChartData(title: "TEST",
                                                   data: self.rawData,
                                                   legendKeys: self.chartKeys,
                                                   unitOfMeasure: "cm"),
                            type: .line())
        lineChart.frame = CGRect(x: 50, y: 10, width: 200, height: 100)

        self.view.addSubview(lineChart)
        
//        NSLayoutConstraint.activate([
//            lineChart.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
//            lineChart.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
//        ])
    }
}



struct TimeTrendModal: UIViewControllerRepresentable {
    @Environment(\.globalGeometrySize) private var globalGeometrySize
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return TimeTrendViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}

struct TimeTrendDetail: View {
    var body: some View {
        TimeTrendModal()
    }
}
