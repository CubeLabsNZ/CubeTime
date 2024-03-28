//
//  TimeDistribution.swift
//  CubeTime
//
//  Created by Tim Xie on 24/12/21.
//

import SwiftUI

func getDivisions(data: [Double]) -> Array<(Double, Int)> {
    let cnt: Int = data.count
    
    if cnt >= 4 {
        var bars: Int {
            return (cnt < 8 ? cnt : 8)
        }
        
        let trim: Int = Int(ceil(Double(cnt) * 0.1))
        
        let tc_data: ArraySlice<Double> = data[trim ... (cnt-trim - 1)]
        var increments: [Double: Int] = [:]
        
        var fd: Double = tc_data.first!
        let ld: Double = tc_data.last!
        let ifd: Double = data[trim - 1]
        let ild: Double = data.suffix(trim).first!
        
        let div_incr: Double = (ld - fd) / Double(bars)
        
        
        
        for i in 0..<bars {
            let range: Range<Double> = fd ..< (fd + div_incr + (i == bars-1 ? (ild - ld)/2 : 0))
            var tmpocc = 0
            
            for datum in Array(tc_data) {
                if range ~= datum {
                    tmpocc += 1
                }
            }
            increments[fd] = tmpocc
            fd += div_incr
        }
        
        var sorted = increments.sorted(by: { $0.key < $1.key })
        sorted.insert((ifd,trim), at: 0)
        sorted.append((ild,trim))
        
        return sorted
    }
    
    return [(0.00, 0)]
}

func getMaxHeight(occurences: [Int]) -> Int? {
    if occurences.count >= 4 {
        guard let max_height = occurences.max() else {
            return nil
        }
        return max_height
    }
    return 1
}


func getTruncatedMinMax(numbers: Array<(Double, Int)>) -> (Double?, Double?) {
    if numbers.count >= 6 {
        let truncated = numbers.dropFirst().dropLast()
        
        return (truncated.first!.0, truncated.last!.0)
    }
    
    return (nil, nil)
}


struct TimeDistribution: View {
    @Preference(\.graphGlow) private var graphGlow
    @Preference(\.isStaticGradient) private var isStaticGradient


    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var gradientManager: GradientManager
    
    @ScaledMetric(relativeTo: .body) var monospacedFontSizeBody: CGFloat = 17
    
    var count: Int
    var data: Array<(Double, Int)>
    var max_height: CGFloat
    
    init(solves: [Double]) {
        self.count = solves.count
        self.data = getDivisions(data: solves)
        self.max_height = CGFloat(220 / Float(getMaxHeight(occurences: data.map { $0.1 })!))
    }
    
    
    
    
    var body: some View {
        if count >= 4 {
            ZStack {
                GeometryReader { geometry in
                    ForEach(0...4, id: \.self) { height in
                        HStack(spacing: 0) {
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: height < 4 ? 220/4*CGFloat(height) : 226))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: height < 4 ? 220/4*CGFloat(height) : 226))
                            }
                            .stroke(Color("indent0"), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5, height == 4 ? 0 : 10]))
                        }
                    }
                }
                .offset(y: 31)
                .padding(.vertical)
                
                
                GeometryReader { geometry in
                    let divs = (geometry.size.width / (count < 8 ? CGFloat(count+2) : 10))
                    
                    let medianxmax = (divs*CGFloat((count < 8 ? count : 8))+20)
                    let medianxmin = (divs+20)
                    
                    let medianxloc = (medianxmax - medianxmin) * CGFloat(stopwatchManager.normalMedian.1 ?? 0) + medianxmin
                    
                    
                    Path { path in
                        path.move(to: CGPoint(x: medianxloc, y: 225))
                        path.addLine(to: CGPoint(x: medianxloc, y: -11))
                    }
                    .stroke(Color("dark"), style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [5, 10]))
                    
                    ForEach(0..<data.count, id: \.self) { datum in
                        let xloc: CGFloat = (geometry.size.width / (count < 8 ? CGFloat(count+2) : 10)) * CGFloat(datum)
                        ZStack {
                            Rectangle()
                                .fill(GradientManager.getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient))
                                .frame(width: geometry.size.width, height: 260)
                                .mask {
                                    Path { path in
                                        path.move(to: CGPoint(x: xloc, y: 220))
                                        path.addLine(to: CGPoint(x: xloc, y: 220 - max_height * CGFloat(data[datum].1)))
                                    }
                                    .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                }
                            
                            Rectangle()
                                .fill(GradientManager.getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient))
                                .frame(width: geometry.size.width, height: 260)
                                .offset(x: -20, y: -20)
                                .mask {
                                    Text("\(data[datum].1)")
                                        .position(x: xloc, y: (220 - max_height * CGFloat(data[datum].1)) - 10)
                                        .multilineTextAlignment(.center)
                                        .recursiveMono(size: 10, weight: .semibold)
                                }
                                .if(graphGlow) { view in
                                    view.colouredGlow(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient)
                                }
                            
                            Text((datum == 0 ? "<" : (datum == data.count-1 ? ">" : ""))+formatLegendTime(secs: data[datum].0, dp: 1)+(datum != 0 && datum != data.count-1 ? "+" : ""))
                                .foregroundColor(Color("grey"))
                                .recursiveMono(size: 10, weight: .regular)
                                .position(x: xloc, y: 240)
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack (spacing: 0) {
                        Text("MEDIAN: ")
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color("dark"))
                        
                        Text(formatSolveTime(secs: stopwatchManager.normalMedian.0!))
                            .recursiveMono(size: 11, weight: .semibold)
                            .foregroundColor(Color("dark"))
                    }
                    .position(x: medianxloc, y: -16)
                }
                .offset(y: 27)
                .padding(.vertical)
            }
        } else {
            Text("not enough solves to\ndisplay graph")
                .recursiveMono(size: 17, weight: .medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("grey"))
                .offset(y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
