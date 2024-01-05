//
//  TimeTrendDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 4/01/24.
//

import Foundation
import SwiftUI
import Charts

struct TimeTrendDetail: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var gradientManager: GradientManager
    
    @State var selectedLines = [true, false, false, false]
    let labels = ["time", "ao5", "ao12", "ao100"]
    
    @State var visibleDomain = 10
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("overlay1"))
            
            VStack {
                HStack(spacing: 8) {
                    CTButton(type: .mono, size: .large, square: true, onTapRun: {
                        self.visibleDomain += self.visibleDomain / 2
                    }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    
                    CTButton(type: .mono, size: .large, square: true, onTapRun: {
                        self.visibleDomain = max(10, self.visibleDomain - (self.visibleDomain / 2))
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(Array(zip(self.selectedLines.indices, self.selectedLines)), id: \.0) { index, selected in
                            CTButton(type: selected ? .halfcoloured : .disabled, size: .large, hasBackground: false, onTapRun: {
                                print("TAPPED \(index)")
                                if (self.selectedLines.lazy.filter({ $0 == true}).count != 1 ||
                                    self.selectedLines.lazy.filter({ $0 == true}).count == 1 && self.selectedLines[index] == false) {
                                    self.selectedLines[index].toggle()
                                }
                            }) {
                                Text(self.labels[index])
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("overlay0"))
                    )
                }
                
                GeometryReader { proxy in
                    DetailTimeTrendBase(rawDataPoints: stopwatchManager.solvesByDate, limits: (0.01, 10.0), averageValue: 5, proxy: proxy)
                }
                
                
//                if #available(iOS 17.0, *) {
//                    Chart {
//                        ForEach(Array(zip(stopwatchManager.solvesNoDNFsbyDate.indices, stopwatchManager.solvesNoDNFsbyDate)), id: \.0) { index, solve in
//                            AreaMark(
//                                x: PlottableValue.value("index", index),
//                                y: PlottableValue.value("time", solve.time)
//                            )
//                            .interpolationMethod(.monotone)
//                            .foregroundStyle(
//                                LinearGradient(colors: [staticGradient[0].opacity(0.6), staticGradient[1].opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
//                            )
//                            
//                            LineMark(
//                                x: PlottableValue.value("index", index),
//                                y: PlottableValue.value("time", solve.time)
//                            )
//                            .interpolationMethod(.monotone)
//                            
//                        }
////                        .symbol(BasicChartSymbolShape.circle)
//                    }
//                    .chartYAxis() {
//                        AxisMarks(position: .leading)
//                    }
//                    .chartScrollableAxes(.horizontal)
//                    .chartXVisibleDomain(length: self.visibleDomain)
//                    .padding(.top)
//                } else {
//                    Text("update!")
//                }
            }
            .padding(8)
        }
        .padding()
        .padding(.bottom, 60)
    }
}
