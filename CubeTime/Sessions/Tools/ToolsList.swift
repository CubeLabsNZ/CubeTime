import SwiftUI

class ToolsViewModel: ObservableObject {
    @Published var currentTool: Tool?
}


struct Tool: Identifiable, Equatable {
    var id: String {
        get { return name }
    }
    
    let name: String
    let iconName: String
    let description: String
}

let tools: [Tool] = [
    Tool(name: "Timer Only", iconName: "stopwatch", description: "Just a timer. No scrambles are shown. Your solves are **not** recorded and are not saved to a session."),
    Tool(name: "Scramble Only", iconName: "cube", description: "Displays one scramble at a time. A timer is not shown. Tap to generate the next scramble."),
    Tool(name: "Scramble Generator", iconName: "server.rack", description: "Generate multiple scrambles at once, to share, save or use."),
    Tool(name: "Average Calculator", iconName: "function", description: "Calculates WPA, BPA, and time needed for an average, etc."),
    Tool(name: "Scorecard Generator", iconName: "printer", description: "Export scorecards for use at meetups (or comps!)."),
]

struct ToolsList: View {
    @StateObject var toolsViewModel = ToolsViewModel()

    var body: some View {
        ZStack {
            Color("base")
                .ignoresSafeArea()
            
            
            VStack(spacing: 8) {
                ForEach(tools) { tool in
                    VStack(alignment: .leading, spacing: 4) {
                        Label(tool.name, systemImage: tool.iconName)
                            .font(.headline)
                        
                        Text(.init(tool.description))
                            .foregroundColor(Color("grey"))
                            .font(.caption)
                            .padding(.top, 2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, minHeight: 65, alignment: .topLeading)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("overlay0"))
                    }
                    .onTapGesture {
                        withAnimation {
                            toolsViewModel.currentTool = tool
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .fullScreenCover(item: $toolsViewModel.currentTool, content: {_ in
                ZStack {
                    Color("base")
                        .ignoresSafeArea()
                    
                    Group {
                        if let tool = toolsViewModel.currentTool {
                            switch (tool.name) {
                            case "Timer Only":
                                TimerOnlyTool()
                                
                            case "Scramble Only":
                                EmptyView()
                                
                            case "Scramble Generator":
                                ScrambleGeneratorTool()
                                    
                                
                            case "Average Calculator":
                                EmptyView()
                                
                                
                            case "Scorecard Generator":
                                EmptyView()
                            
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
    
    @Environment(\.globalGeometrySize) var globalGeometrySize
    let name: String
    let image: String
    
    let content: V?
    
    init(name: String, image: String, @ViewBuilder content: () -> V?) {
        self.name = name
        self.image = image
        self.content = content()
    }
    
    var body: some View {
        HStack {
            HStack {
                Label(name, systemImage: image)
                    .font(.system(size: 17, weight: .medium))
                    .padding(.leading, 8)
                    .padding(.trailing)
                
                if let innerView = content {
                    innerView
                }
            }
            .frame(height: 35)
            .background(
                Color("overlay1")
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            )
            
            Spacer()
            
            CloseButton(hasBackgroundShadow: true) {
                toolsViewModel.currentTool = nil
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}
