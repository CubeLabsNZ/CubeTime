//
//  TimerMenu.swift
//  CubeTime
//
//  Created by trainz-are-kul on 28/02/23.
//

import SwiftUI

struct TimerMenu: View {
    @Namespace private var namespace
    @State var expanded = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Material.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color("overlay0").opacity(0.92))
                .shadow(color: Color.black.opacity(0.06),
                        radius: 4,
                        x: 0,
                        y: 1)
            
            Group {
                if expanded {
                    VStack (alignment: .leading) {
                        Image(systemName: "xmark")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(12)
                            .onTapGesture {
                                expanded = false
                            }
                        
                        VStack {
                            Toggle(isOn: .constant(false), label: {
                                Label(title: {
                                    Text("Zen Mode")
                                }, icon: {
                                    Image(systemName: "blinds.vertical.closed")
                                        .matchedGeometryEffect(id: 0, in: namespace)
                                })
                            })
                            Toggle(isOn: .constant(false), label: {
                                Label(title: {
                                    Text("Practice Mode")
                                }, icon: {
                                    Image(systemName: "figure.climbing")
                                        .matchedGeometryEffect(id: 1, in: namespace)
                                })
                            })
                            Toggle(isOn: .constant(false), label: {
                                Label(title: {
                                    Text("Inspection")
                                }, icon: {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .matchedGeometryEffect(id: 2, in: namespace)
                                })
                            })
                            Divider()
                            HierarchialButton(type: .coloured, size: .large, onTapRun: {}) {
                                Label("Settings", systemImage: "wrench")
                            }
                        }
                        .padding()
                        .font(.system(size: 18))
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
        .frame(width: expanded ? 400 : 35, height: expanded ? nil : 35)
        .animation(Animation.customDampedSpring, value: expanded)
        .fixedSize(horizontal: true, vertical: true)
    }
}

struct TimerMenu_Previews: PreviewProvider {
    static var previews: some View {
        TimerMenu()
    }
}
