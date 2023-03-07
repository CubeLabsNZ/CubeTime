//
//  AveragePhases.swift
//  CubeTime
//
//  Created by Tim Xie on 14/01/22.
//

import SwiftUI

let phaseColours: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, Color("accent")]

/// source: https://stackoverflow.com/a/46729248/17569741
extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 100), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
                           green: CGFloat(g1 + (g2 - g1) * percentage),
                           blue: CGFloat(b1 + (b2 - b1) * percentage),
                           alpha: CGFloat(a1 + (a2 - a1) * percentage))
        }
    }
}


struct AveragePhases: View {
    @Environment(\.colorScheme) private var colourScheme
    
    @EnvironmentObject var gradientManager: GradientManager
    
    var phaseTimes: [Double]
    
    
    var body: some View {
        let selectedGradient = getGradientColours(gradientSelected: gradientManager.appGradient)
        
        let gradientStart: UIColor = UIColor(selectedGradient[0])
        let gradientEnd: UIColor = UIColor(selectedGradient[1])
        
        let phaseCount: Int = phaseTimes.count - 1
        VStack (spacing: 0) {
            GeometryReader { geometry in
                
                let maxWidth: CGFloat = geometry.size.width - 2*CGFloat(phaseCount)
                
                HStack(spacing: 2) {
                    ForEach(Array(zip(phaseTimes.indices, phaseTimes)), id: \.0) { index, phase in
                        Rectangle()
                            .fill(Color(gradientStart.toColor(gradientEnd, percentage: CGFloat(index)/CGFloat(phaseCount))))
                            .frame(width: maxWidth * CGFloat(phase / phaseTimes.reduce(0, +)), height: 10)
                            .cornerRadius(index == 0 ? 10 : 0, corners: [.topLeft, .bottomLeft])
                            .cornerRadius(index == phaseCount ? 10 : 0, corners: [.topRight, .bottomRight])
                    }
                }
            }
            
            VStack(spacing: 8) {
                ForEach(Array(zip(phaseTimes.indices, phaseTimes)), id: \.0) { index, phase in
                    HStack (spacing: 8) {
                        
                        Image(systemName: "\(index+1).circle")
                            .foregroundColor(Color(gradientStart.toColor(gradientEnd, percentage: CGFloat(index)/CGFloat(phaseCount))))
                            .font(.system(size: 15, weight: .bold))
                        
                        Text(formatSolveTime(secs: phase))
                            .font(.system(size: 17))
                        
                        
                        Text("("+String(format: "%.1f", (phase / phaseTimes.reduce(0, +))*100)+"%)")
                            .foregroundColor(Color("grey"))
                            .font(.system(size: 17))
                        
                        Spacer()
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
