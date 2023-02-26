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
    Tool(name: "Timer Only", iconName: "stopwatch", description: "Just a timer. No scrambles shown and solves aren't recorded."),
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

struct ToolHeader: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    let name:String
    let image:String
    @Binding var showOverlay: Tool?
    var namespace: Namespace.ID
    var body: some View {
        HStack {
            Label(name, systemImage: image)
                .matchedGeometryEffect(id: name, in: namespace)
                .font(.system(size: 17, weight: .medium))
                .padding(.leading, 8)
                .padding(.trailing)
                .frame(height: 35)
                .background(
                    Color("overlay1")
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .matchedGeometryEffect(id: "bg" + name, in: namespace)
                )
            
            Spacer()
            
            CloseButton(hasBackgroundShadow: true) {
                showOverlay = nil
                tabRouter.hideTabBar = false
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

struct ToolsList: View {
    @EnvironmentObject var tabRouter: TabRouter
    
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
                        .fill(Color("overlay0"))
                        .frame(height: nil)
                        .ignoresSafeArea()
                        .transition(.identity)
                    
                    ScrambleGeneratorTool(showOverlay: $displayingTool, namespace: namespace)
                }
                .zIndex(100)
                
                
            } else {
                VStack(spacing: 8) {
                    ForEach(tools) { tool in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(tool.name, systemImage: tool.iconName)
                                .matchedGeometryEffect(id: tool.name, in: namespace)
                                .font(.headline)
                            
                            Text(tool.description)
                                .foregroundColor(Color("grey"))
                                .font(.caption)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 95, alignment: .topLeading)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("overlay0"))
                                .matchedGeometryEffect(id: "bg" + tool.name, in: namespace)
                                .animation(.easeIn, value: displayingTool)
                        }
                        .transaction { t in
                            t.animation = .none
                        }
                        .onTapGesture {
                            withAnimation {
                                displayingTool = tool
                                tabRouter.hideTabBar = true
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
        .navigationBarHidden(displayingTool != nil)
    }
}
