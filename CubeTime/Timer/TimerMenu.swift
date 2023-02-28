//
//  TimerMenu.swift
//  CubeTime
//
//  Created by trainz-are-kul on 28/02/23.
//

import SwiftUI

struct TimerMenu: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Namespace private var namespace
    
    @State var expanded = false
    
    private let circleWidth: CGFloat = 2.5
    
    var body: some View {
        let color = expanded ? Color("overlay1") : Color.white
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Material.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(color.opacity(0.92))
                .shadow(color: Color.black.opacity(0.06),
                        radius: 4,
                        x: 0,
                        y: 1)
            
            
            #warning("TODO: use animatabledata to animate path from circle -> symbol")
            #warning("TODO: make and use custom divider")
            
            VStack {
                if expanded {
                    CloseButton {
                        expanded = false
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    VStack {
                        HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {}) {
                            Label(title: {
                                Text("Zen Mode")
                            }, icon: {
                                Image(systemName: "moon.stars")
                                    .matchedGeometryEffect(id: 0, in: namespace)
                                    .zIndex(100)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Divider()
                        HierarchialButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {}) {
                            Label(title: {
                                Text("Tools")
                            }, icon: {
                                Image(systemName: "wrench.and.screwdriver")
                                    .matchedGeometryEffect(id: 1, in: namespace)
                                    .zIndex(100)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HierarchialButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {}) {
                            Label(title: {
                                Text("Settings")
                            }, icon: {
                                Image(systemName: "gearshape")
                                    .matchedGeometryEffect(id: 2, in: namespace)
                                    .zIndex(100)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(8)
                } else {
                    HStack(spacing: 2.75) {
                        ForEach(0..<3, id: \.self) { id in
                            Circle()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: id, in: namespace)
                                .frame(width: circleWidth, height: circleWidth)
                        }
                    }
                    .zIndex(100)
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .frame(width: expanded ? nil : 35, height: expanded ? nil : 35)
            )
            
            
            
        }
        .contentShape(Rectangle())
        .frame(width: expanded ? nil : 35, height: expanded ? nil : 35)
        .animation(Animation.customDampedSpring, value: expanded)
        .fixedSize(horizontal: true, vertical: true)
        
        .onTapGesture {
            expanded = true
        }
    }
}

struct TimerMenu_Previews: PreviewProvider {
    static var previews: some View {
        TimerMenu()
    }
}
