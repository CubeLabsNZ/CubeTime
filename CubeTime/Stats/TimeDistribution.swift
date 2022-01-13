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
            if cnt < 8 {
                return cnt
            } else {
                return 8
            }
        }
        
        let trim: Int = Int(ceil(Double(cnt) * 0.1))
        
        let tc_data: ArraySlice<Double> = data[trim...cnt-trim-1]
        
        var fd: Double = tc_data.first!
        let ld: Double = tc_data.last!
        let ifd: Double = data[trim-1]
        let ild: Double = data.suffix(trim).first!
        
        let div_incr: Double = (ld - fd) / Double(bars)
        
        var increments: [Double: Int] = [:]
        
        for i in 0..<bars {
            let range: Range<Double> = fd..<(fd+div_incr + (i == bars-1 ? (ild-ld)/2 : 0))
            
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

    } else {
        return [(0.00, 0)]
    }
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

func getHeights(occurences: [Int]) -> [Int]? {
    return occurences
}

extension View {
    func inExpandingRectangle() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            self
        }
    }
}

/*
func getMedianPercentage(numbers: Array<(Double, Int)>) -> Double {
    if numbers.count >= 6 {
        let truncated = numbers.dropFirst().dropLast()
        
        return (stats.getNormalMedian - truncated.first) / (truncated.last - truncated.first)
    }
}
 */


struct TimeDistribution: View {
    @AppStorage(asKeys.gradientSelected.rawValue) var gradientSelected: Int = 6
    
    var count: Int
    var data: Array<(Double, Int)>
    var max_height: CGFloat
    
    init(solves: [Double]) {
        self.count = solves.count
        self.data = getDivisions(data: solves)
        self.max_height = CGFloat(220 / Float(getMaxHeight(occurences: data.map { $0.1 })!))
    }
    
    var body: some View {
        /*
        GeometryReader { geometry in
            HStack(alignment: .bottom) {
                ForEach(0..<data.count) { datum in
                    VStack {
                        Capsule()
                            .frame(width: 5, height: CGFloat(data[datum].1) * max_height)
                            .mask {
                                Rectangle()
                                    .fill(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
                                    .frame(width: geometry.size.width, height: 240)
                            }
                        
                        Text((datum == 0 ? "<" : (datum == data.count-1 ? ">" : ""))+formatLegendTime(secs: data[datum].0, dp: 1)+(datum != 0 && datum != data.count-1 ? "+" : ""))
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                }
            }
            .frame(width: geometry.size.width, height: 240)
        }
         */
        
        
        if count >= 4 {
            ZStack {
                GeometryReader { geometry in
                    ForEach(0...4, id: \.self) { height in
                        HStack(spacing: 0) {
    //                        Text("\(formatLegendTime(secs: (Double(getMaxHeight(occurences: data.map { $0.1 })!)/4.00)*Double(4-height), dp: 1))")
    //                            .foregroundColor(Color(uiColor: .systemGray2))
    //                            .position(x: 0, y: 220/4*CGFloat(height))
    //                            .font(.system(size: 10, weight: .medium, design: .monospaced))

                            
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: height < 4 ? 220/4*CGFloat(height) : 226))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: height < 4 ? 220/4*CGFloat(height) : 226))
                            }
                            .stroke(Color(uiColor: .systemGray5), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5, height == 4 ? 0 : 10]))
                        }
                    }
                }
                .padding()
                .offset(y: 27)
                
                
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0..<data.count, id: \.self) { datum in
                            let xloc: CGFloat = (geometry.size.width / (count < 8 ? CGFloat(count+2) : 10)) * CGFloat(datum)
                            ZStack {
                                Rectangle()
                                    .fill(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
                                    .frame(width: geometry.size.width, height: 260)
                                    .mask {
                                        Path { path in
                                            path.move(to: CGPoint(x: xloc, y: 220))
                                            path.addLine(to: CGPoint(x: xloc, y: 220 - max_height * CGFloat(data[datum].1)))
                                        }
                                        .stroke(.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    }
                                
                                Rectangle()
                                    .fill(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
                                    .frame(width: geometry.size.width, height: 260)
                                    .offset(x: -20, y: -20)
                                    .mask {
                                        Text("\(data[datum].1)")
                                            .position(x: xloc, y: (220 - max_height * CGFloat(data[datum].1)) - 10)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    }
                                    .colouredGlow(gradientSelected: gradientSelected)
                                
                                Text((datum == 0 ? "<" : (datum == data.count-1 ? ">" : ""))+formatLegendTime(secs: data[datum].0, dp: 1)+(datum != 0 && datum != data.count-1 ? "+" : ""))
                                    .foregroundColor(Color(uiColor: .systemGray2))
                                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                                    .position(x: xloc, y: 240)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding()
                .offset(y: 23)
                
                
            }

        } else {
            Text("not enough solves to\ndisplay graph")
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(uiColor: .systemGray))
        }
    }
}



struct TimeDistribution_Previews: PreviewProvider {
    static var previews: some View {
        TimeDistribution(solves: [1.234234, 1.34895345, 2.345897345, 3.3459834, 3.34985345])
    }
}
