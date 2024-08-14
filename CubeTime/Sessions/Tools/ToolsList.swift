import SwiftUI

class ToolsViewModel: ObservableObject {
    @Published var currentTool: Tool?
}


enum ToolType: Identifiable {
    case timerOnly, scrambleOnly, scrambleGenerator, calculator
    
    var id: ToolType { self }
}

struct Tool: Identifiable, Equatable {
    var id: ToolType {
        get { return self.toolType }
    }
    
    let name: String
    let toolType: ToolType
    let iconName: String
    let description: String
}

let tools: [Tool] = [
    Tool(name: String(localized: "Timer Only"), toolType: .timerOnly, iconName: "stopwatch", description: String(localized: "Just a timer. No scrambles are shown. Your solves are **not** recorded and are not saved to a session.")),
    Tool(name: String(localized: "Scramble Only"), toolType: .scrambleOnly, iconName: "cube", description: String(localized: "Displays one scramble at a time. A timer is not shown. Tap to generate the next scramble.")),
    Tool(name: String(localized: "Scramble Generator"), toolType: .scrambleGenerator, iconName: "server.rack", description: String(localized: "Generate multiple scrambles at once, to share, save or use.")),
    Tool(name: String(localized: "Calculator"), toolType: .calculator, iconName: "function", description: String(localized: "Simple average and mean calculator.")),
    /*
    Tool(name: "Tracker", iconName: "scope", description: "Track someone's average at a comp. Calculates times needed for a chance for a target, BPA, WPA, and more."),
    Tool(name: "Scorecard Generator", iconName: "printer", description: "Export scorecards for use at meetups (or comps!)."),
     */
]

struct ToolsList: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @StateObject var toolsViewModel = ToolsViewModel()
    @ScaledMetric(wrappedValue: 65, relativeTo: .title3) private var blockHeight: CGFloat

    var body: some View {
        ZStack {
            BackgroundColour()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tools) { tool in
                        Button {
                            withAnimation {
                                toolsViewModel.currentTool = tool
                            }
                            
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(tool.name, systemImage: tool.iconName)
                                    .font(.title3.weight(.semibold))
                                
                                Text(.init(tool.description))
                                    .foregroundColor(Color("grey"))
                                    .font(.callout)
                                    .padding(.top, 2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: blockHeight, alignment: .topLeading)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color("overlay0"))
                            }
                        }
                        .buttonStyle(CTButtonStyle())
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .safeAreaInset(safeArea: .tabBar)
            .fullScreenCover(item: $toolsViewModel.currentTool, content: {_ in
                ZStack {
                    Color("base")
                        .ignoresSafeArea()
                    
                    Group {
                        if let tool = toolsViewModel.currentTool {
                            switch (tool.toolType) {
                            case .timerOnly:
                                TimerOnlyTool()
                                
                            case .scrambleOnly:
                                ScrambleOnlyTool()
                                
                            case .scrambleGenerator:
                                ScrambleGeneratorTool()
                                    
                            case .calculator:
                                CalculatorTool()
                            
                            default:
                                EmptyView()
                            }
                        }

                    }
                    .environmentObject(toolsViewModel)
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Tools")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ToolHeader<V: View>: View {
    @EnvironmentObject private var toolsViewModel: ToolsViewModel
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var height
    
    @Environment(\.globalGeometrySize) var globalGeometrySize
    let name: String
    let image: String
    let onClose: (() -> ())?
    
    let content: V?
    
    init(name: String, image: String, onClose: (() -> ())?=nil, @ViewBuilder content: () -> V?) {
        self.name = name
        self.image = image
        self.onClose = onClose
        self.content = content()
    }
    
    var body: some View {
        HStack {
            HStack {
                Label(name, systemImage: image)
                    .font(.body.weight(.medium))
                    .padding(.leading, 8)
                    .padding(.trailing)
                
                
                if let innerView = content {
                    if #available(iOS 16, *) {
                        innerView
                    } else {
                        innerView
                            .padding(.trailing, 12)
                    }
                }
            }
            .frame(height: height)
            .background(
                Color("overlay1")
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            )
            
            Spacer()
            
            CTCloseButton(hasBackgroundShadow: true) {
                toolsViewModel.currentTool = nil
                if let onClose = self.onClose {
                    onClose()
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}
