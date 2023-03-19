//
//  TimerMenu.swift
//  CubeTime
//
//  Created by trainz-are-kul on 28/02/23.
//

import SwiftUI

struct TimerMenu: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Namespace private var namespace
    
    @Binding var expanded: Bool
    
    @State private var showTools: Bool = false
    @State private var showSettings: Bool = false
    
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var barHeight: CGFloat
    
    private let circleWidth: CGFloat = 3.25
    
    var body: some View {
        let color = expanded ? Color("overlay1") : Color("overlay0")
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Material.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(color.opacity(0.92))
                .shadow(color: Color("indent1"),
                        radius: 4,
                        x: 0, y: 1)
            
            
            #warning("TODO: use animatabledata to animate path from circle -> symbol")
            VStack(spacing: 4) {
                if expanded {
                    CTCloseButton {
                        expanded = false
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 2)
                    
                    VStack(spacing: 8) {
                        CTButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
                            withAnimation(.customEaseInOut) {
                                stopwatchManager.currentPadFloatingStage = 1
                                stopwatchManager.zenMode = true
                            }
                        }) {
                            Label(title: {
                                Text("Zen Mode")
                            }, icon: {
                                Image(systemName: "moon.stars")
                                    .matchedGeometryEffect(id: 0, in: namespace)
                                    .zIndex(100)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        ThemedDivider()
                            .padding(.horizontal, 4)
                        
                        CTButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {
                            showTools = true
                        }) {
                            Label(title: {
                                Text("Tools")
                            }, icon: {
                                Image(systemName: "wrench.and.screwdriver")
                                    .matchedGeometryEffect(id: 1, in: namespace)
                                    .zIndex(100)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        CTButton(type: .halfcoloured, size: .large, expandWidth: true, onTapRun: {
                            showSettings = true
                        }) {
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
                    HStack(spacing: 2.85) {
                        ForEach(0..<3, id: \.self) { id in
                            Circle()
                                .fill(Color("accent"))
                                .matchedGeometryEffect(id: id, in: namespace)
                                .frame(width: circleWidth, height: circleWidth)
                        }
                    }
                    .zIndex(100)
                }
            }
            .mask(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .frame(width: expanded ? nil : barHeight, height: expanded ? nil : barHeight)
            )
        }
        .contentShape(Rectangle())
        .frame(width: expanded ? nil : barHeight, height: expanded ? nil : barHeight)
        .animation(Animation.customDampedSpring, value: expanded)
        .fixedSize(horizontal: true, vertical: true)
        
        .onTapGesture {
            expanded = true
        }
        
        .onLongPressGesture {
            expanded = true
        }
        
        .sheet(isPresented: self.$showTools) {
            NavigationView {
                ToolsList()
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            CTDoneButton(onTapRun: {
                                self.showTools = false
                                dismiss()
                            })
                        }
                    }
            }
        }
        
        .sheet(isPresented: self.$showSettings) {
            SettingsView()
        }
    }
}
