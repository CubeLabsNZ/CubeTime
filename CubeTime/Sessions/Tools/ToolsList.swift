import SwiftUI

struct Tool: Identifiable, Equatable {
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

struct ToolHeader: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    
    let name: String
    let image: String
    @Binding var showingSheet: Bool
    
    var body: some View {
        HStack {
            Label(name, systemImage: image)
                .font(.system(size: 17, weight: .medium))
                .padding(.leading, 8)
                .padding(.trailing)
                .frame(height: 35)
                .background(
                    Color("overlay1")
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                )
            
            Spacer()
            
            CloseButton(hasBackgroundShadow: true) {
                tabRouter.hideTabBar = false
                self.showingSheet = false
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

struct ToolsList: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    @State private var showingSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color("base")
                .ignoresSafeArea()
            
            
            VStack(spacing: 8) {
                ForEach(tools) { tool in
                    VStack(alignment: .leading, spacing: 4) {
                        Label(tool.name, systemImage: tool.iconName)
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
                    }
                    .onTapGesture {
                        withAnimation {
                            tabRouter.hideTabBar = true
                            self.showingSheet = true
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .fullScreenCover(isPresented: self.$showingSheet) {
                ZStack(alignment: .top) {
                    Color("base")
                        .ignoresSafeArea()
                    
                    VStack {
                        ToolHeader(name: "Scramble Generator", image: "macstudio", showingSheet: self.$showingSheet)
                        
                        ScrambleGeneratorTool()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarTitle("Tools")
        .navigationBarTitleDisplayMode(.inline)
    }
}
