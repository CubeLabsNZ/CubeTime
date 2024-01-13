//
//  TimeTrendDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 4/01/24.
//

import Foundation
import SwiftUI
import Charts

struct LegendLabel: View {
    let colour: Color
    let label: String
    let symbol: String?
    
    init(colour: Color, label: String, symbol: String? = nil) {
        self.colour = colour
        self.label = label
        self.symbol = symbol
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let symbol = self.symbol {
                ZStack {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color("indent1"))
                        .frame(width: 32, height: 2, alignment: .leading)
                    
                    Image(systemName: symbol)
                        .foregroundStyle(colour)
                        .font(.caption.bold())
                }
            } else {
                RoundedRectangle(cornerRadius: 1)
                    .fill(colour)
                    .frame(width: 32, height: 2, alignment: .leading)
            }
                    
            Text(label)
                .font(.caption2)
                .foregroundStyle(colour)
        }
        
    }
}

struct TimeTrendDetail: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var gradientManager: GradientManager
    
    @State var selectedLines = [true, false, false, false]
    let labels: [(label: String, type: CTButtonType)] = [
        ("time", .halfcoloured),
        ("ao5", .green),
        ("ao12", .red),
        ("ao100", .orange)
    ]
    
    @State var interval: Int = 30
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("overlay1"))
            
            VStack {
                HStack(spacing: 8) {
                    CTButton(type: .mono, size: .large, square: true, onTapRun: {
                        self.interval = max(10, self.interval - (self.interval / 2))
                    }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    
                    CTButton(type: .mono, size: .large, square: true, onTapRun: {
                        self.interval = min(100, self.interval + (self.interval / 2))
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(Array(zip(self.selectedLines.indices, self.selectedLines)), id: \.0) { index, selected in
                            CTButton(type: selected ? self.labels[index].type : .disabled, size: .large, hasBackground: false, onTapRun: {
                                print("TAPPED \(index)")
                                if (self.selectedLines.lazy.filter({ $0 == true}).count != 1 ||
                                    self.selectedLines.lazy.filter({ $0 == true}).count == 1 && self.selectedLines[index] == false) {
                                    self.selectedLines[index].toggle()
                                }
                            }) {
                                Text(self.labels[index].label)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("overlay0"))
                    )
                    
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 36, maximum: 100), spacing: 16), count: 3), alignment: .leading) {
                    ForEach(self.labels, id: \.0) { label, type in
                        LegendLabel(colour: colourForButtonType(type).colourFg, label: label)
                    }
                    
                    LegendLabel(colour: Color("grey"), label: "DNF", symbol: "xmark")
                }
                .padding(8)
                
                GeometryReader { proxy in
                    DetailTimeTrendBase(stopwatchManager: stopwatchManager,
                                        rawDataPoints: stopwatchManager.solvesByDate,
                                        limits: (stopwatchManager.solvesByDate.min(by: { $0.timeIncPen < $1.timeIncPen })!.timeIncPen, stopwatchManager.solvesByDate.max(by: { $0.timeIncPen < $1.timeIncPen })!.timeIncPen),
                                        averageValue: 5, interval: interval,
                                        proxy: proxy)
                }
                .padding(.top, 8)
            }
            .padding(8)
        }
        .padding()
        .padding(.bottom, 60)
    }
}
