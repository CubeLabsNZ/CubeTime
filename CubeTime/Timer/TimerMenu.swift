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
    
    #warning("TIM TODO: make the toggles scale")
    
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
            
            VStack {
                if expanded {
                    VStack (alignment: .leading) {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(12)
                            .onTapGesture {
                                expanded = false
                            }
                        
                        VStack {
                            HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {}) {
                                Label(title: {
                                    Text("Zen Mode")
                                }, icon: {
                                    Image(systemName: "blinds.vertical.closed")
                                        .matchedGeometryEffect(id: 0, in: namespace)
                                })
                            }
                            Divider()
                            HierarchialButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {}) {
                                Label(title: {
                                    Text("Tools")
                                }, icon: {
                                    Image(systemName: "wrench.and.screwdriver")
                                        .matchedGeometryEffect(id: 1, in: namespace)
                                })
                            }
                            HierarchialButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {}) {
                                Label(title: {
                                    Text("Settings")
                                }, icon: {
                                    Image(systemName: "gearshape")
                                        .matchedGeometryEffect(id: 2, in: namespace)
                                })
                            }
                        }
                        .padding()
                        .font(.system(size: 18))
//                        .transition(.scale)
                        .transition(.scale(scale: 0, anchor: .topTrailing))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                } else {
                    HStack {
                        Spacer()
                        Circle()
                            .matchedGeometryEffect(id: 0, in: namespace)
                            .frame(width: 2, height: 2)
                        Circle()
                            .matchedGeometryEffect(id: 1, in: namespace)
                            .frame(width: 2, height: 2)
                        Circle()
                            .matchedGeometryEffect(id: 2, in: namespace)
                            .frame(width: 2, height: 2)
                        Spacer()
                    }
                }
            }
        }
        .onTapGesture {
            expanded = true
        }
        .contentShape(Rectangle())
        .frame(width: expanded ? nil : 35, height: expanded ? nil : 35)
        .animation(Animation.customDampedSpring, value: expanded)
        .fixedSize(horizontal: true, vertical: true)
    }
}

struct TimerMenu_Previews: PreviewProvider {
    static var previews: some View {
        TimerMenu()
    }
}
