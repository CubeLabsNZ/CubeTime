//
//  TimeTrendDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 1/03/23.
//

import SwiftUI
import FLCharts

struct TimeTrendModal: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let lineChart = FLChart(data: FLChartData(title: "Test", data: ["a": 1.56, "b": 1.67, "c": 1.78], legendKeys: [.init(key: "dfsdf", color: .red)], unitOfMeasure: "CM"), type: .line())
        lineChart.averageLineOverlapsChart = true
        lineChart.showAverageLine = true
        lineChart.showDashedLines = true
        lineChart.shouldScroll = true
        
        return lineChart
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct TimeTrendDetail: View {
    var body: some View {
        TimeTrendModal()
    }
}

struct TimeTrendDetail_Previews: PreviewProvider {
    static var previews: some View {
        TimeTrendDetail()
    }
}
