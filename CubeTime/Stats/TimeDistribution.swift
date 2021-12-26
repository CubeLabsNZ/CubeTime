//
//  TimeDistribution.swift
//  CubeTime
//
//  Created by Tim Xie on 24/12/21.
//

import SwiftUI

var bars: Int = 8

func getDivisions(data: [Double]) -> Array<(Double, Int)> {
    let cnt: Int = data.count
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
}

func getMaxHeight(occurences: [Int]) -> Int? {
    guard let max_height = occurences.max() else {
        return nil
    }
    
    return max_height
}




struct TimeDistribution: View {
    var data: Array<(Double, Int)>
    var max_height: CGFloat
    
    init(solves: [Double]) {
        self.data = getDivisions(data: solves)
        self.max_height = CGFloat(240 / getMaxHeight(occurences: data.map { $0.1 })!)
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom) {
                ForEach(0..<data.count) { datum in
                    VStack {
                        Capsule()
                            .frame(width: 4, height: CGFloat(data[datum].1) * max_height)
                        
                        Text((datum == 0 ? "<" : (datum == data.count-1 ? ">" : ""))+formatLegendTime(secs: data[datum].0, dp: 1)+(datum != 0 && datum != data.count-1 ? "+" : ""))
                            .foregroundColor(Color(uiColor: .systemGray2))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                }
            }
            .frame(width: geometry.size.width, height: 240)
        }
    }
}



struct TimeDistribution_Previews: PreviewProvider {
    static var previews: some View {
        TimeDistribution(solves: [1.234234, 1.34895345, 2.345897345, 3.3459834, 3.34985345])
    }
}
