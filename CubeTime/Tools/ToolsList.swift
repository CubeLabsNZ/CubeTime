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
    Tool(name: "Time Only Mode", iconName: "stopwatch", description: "A timer that doesn't record solves."),
    Tool(name: "Scramble Only Mode", iconName: "cube", description: "Only displays a scramble. Tap to generate the next scramble."),
    Tool(name: "Scramble Generator", iconName: "macstudio", description: "Generate multiple scrambles at once, then share or save them."),
    Tool(name: "Average calculator", iconName: "function", description: "Calculate WPA, BPA, time needed for an average, etc."),
    Tool(name: "Scorecard Generator", iconName: "printer", description: "Export scorecards for use at meetups or comps."),
]

struct ToolOverlay: View {
    let tool: Tool
    var namespace: Namespace.ID
    var body: some View {
        ZStack {
            Color("overlay1").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .matchedGeometryEffect(id: "bg" + tool.name, in: namespace)
                .ignoresSafeArea()
//                    displayingTool.view()
        }
        .zIndex(999)
    }
}

struct ToolsList: View {
    @State var displayingTool: Tool? = nil
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            Color("base")
                .ignoresSafeArea(.all, edges: .bottom)
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(tools) { tool in
                        if displayingTool != tool {
                            VStack(alignment: .leading, spacing: 2) {
                                Label(tool.name, systemImage: tool.iconName)
                                    .font(.headline)
                                Text(tool.description)
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(
                                Color("overlay1").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .matchedGeometryEffect(id: "bg" + tool.name, in: namespace)
                            )
                            .onTapGesture {
                                displayingTool = tool
                            }
                        }
                    }
                }
                .padding()
            }
            .overlay {
                if let displayingTool = displayingTool {
                    ToolOverlay(tool: displayingTool, namespace: namespace)
                }
            }
        }
        .navigationTitle("Tools")
    }
}
