import SwiftUI

struct Tool: Identifiable, Equatable {
//    static func == (lhs: Tool, rhs: Tool) -> Bool {
//        lhs.name == rhs.name
//    }
    
    var id: String {
        get {
            return name
        }
    }
    
    let name: String
    let iconName: String
    let description: String
//    let view: some View
//    let view: Any
}

let tools = [
    Tool(name: "Time Only Mode", iconName: "stopwatch", description: "Just a timer. No scrambles shown and solves aren't recorded."),
    Tool(name: "Scramble Only Mode", iconName: "cube", description: "Displays one scramble at a time. No timer shown. Tap to generate the next scramble."),
    Tool(name: "Scramble Generator", iconName: "macstudio", description: "Generate multiple scrambles at once, to share, save or use."),
    Tool(name: "Average calculator", iconName: "function", description: "Calculates WPA, BPA, and time needed for an average, etc."),
    Tool(name: "Scorecard Generator", iconName: "printer", description: "Export scorecards for use at meetups (or comps!)."),
]

struct ToolOverlay: View {
    let tool: Tool
    var namespace: Namespace.ID
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("overlay0"))
                .matchedGeometryEffect(id: "bg" + tool.name, in: namespace)
                .frame(height: 400)
        }
    }
}

struct ToolsList: View {
    @State var displayingTool: Tool? = nil
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            Color("base")
                .ignoresSafeArea()
                .zIndex(0)
                .transition(.identity)
//                .overlay {
//                    if let displayingTool = displayingTool {
//                        ToolOverlay(tool: displayingTool, namespace: namespace)
//                            .zIndex(999)
//                    }
//                }
            
            if let displayingTool = displayingTool {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
//                        .fill(Color("overlay0"))
                        .fill(Color.red)
                        .matchedGeometryEffect(id: "bg" + displayingTool.name, in: namespace)
                        .frame(height: nil)
                        .ignoresSafeArea()
                        .transition(.identity)
                    
                    Text(displayingTool.name)
                }
                .zIndex(100)
                
                
            } else {
                VStack(spacing: 8) {
                    ForEach(tools) { tool in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("overlay0"))
                                .matchedGeometryEffect(id: "bg" + tool.name, in: namespace)
                                .frame(height: 95)
                                .transition(.identity)
                                .animation(.easeIn, value: displayingTool)
                                .zIndex(displayingTool == nil ? 0 : 100)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Label(tool.name, systemImage: tool.iconName)
                                    .font(.headline)
                                
                                Text(tool.description)
                                    .foregroundColor(Color("grey"))
                                    .font(.caption)
                            }
                            .padding(12)
                            .zIndex(1)
                            .transaction { t in
                                t.animation = .none
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 95)
                        .onTapGesture {
                            withAnimation {
                                displayingTool = tool
                            }
                        }
                    }
                    
                    Spacer()
                }
                .zIndex(1)
                .padding()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Tools")
        .navigationBarTitleDisplayMode(.inline)
    }
}
