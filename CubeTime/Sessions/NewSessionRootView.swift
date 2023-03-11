import SwiftUI
import CoreData

struct NewSessionTypeCard: View {
    let name: String
    let icon: SessionTypeIcon
    @Binding var show: Bool
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: icon.iconName)
                    .font(.system(size: icon.size, weight: icon.weight))
                    .padding(.leading, icon.padding.leading)
                    .padding(.trailing, icon.padding.trailing)
                    .padding(.vertical, 8)
                
                Text(name)
                    .font(.body)
            }
            .foregroundColor(Color("dark"))
            
            
            Spacer()
        }
        .background(Color("overlay0"))
        .onTapGesture {
            show = true
        }
    }
}


struct NewSessionTypeCardGroup<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    let title: String
    let content: () -> Content
    
    
    @inlinable init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2.weight(.bold))
                .padding(.bottom, 8)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(Color("overlay0"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .padding(.horizontal)
    }
}

struct NewSessionRootView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showNewStandardSessionView = false
    @State private var showNewAlgTrainerView = false
    @State private var showNewMultiphaseView = false
    @State private var showNewPlaygroundView = false
    @State private var showNewCompsimView = false
    
    @Binding var showNewSessionPopUp: Bool
    
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColour()
                
                VStack {
                    #warning("BUG: ADD NEW SESSION TEXT DOES NOT DISPLAY ON IPOD TOUCH")
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.largeTitle.bold())
                            .padding(.bottom, 8)
                            .padding(.top, globalGeometrySize.height/12)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 48) {
                        NewSessionTypeCardGroup(title: "Normal Sessions") {
                            NewSessionTypeCard(name: "Standard Session", icon: SessionTypeIcon(iconName: "timer.square"), show: $showNewStandardSessionView)
                            
                            ThemedDivider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Multiphase", icon: SessionTypeIcon(size: 24, iconName: "square.stack", padding: (10, 6)), show: $showNewMultiphaseView)
                            
                            ThemedDivider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Playground", icon: SessionTypeIcon(size: 24, iconName: "square.on.square"), show: $showNewPlaygroundView)
                        }
                        
                        
                        NewSessionTypeCardGroup(title: "Other Sessions") {
                            //  NewSessionTypeCard(name: "Algorithm Trainer", icon: "command.square", iconProps: SessionTypeIconProps(), show: $showNewAlgTrainerView)
                            NewSessionTypeCard(name: "Comp Sim", icon: SessionTypeIcon(iconName: "globe.asia.australia", weight: .medium), show: $showNewCompsimView)
                        }
                        
                        
                        NavigationLink("", destination: NewSessionView(sessionType: SessionType.standard, typeName: "Standard", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewStandardSessionView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionType.multiphase, typeName: "Multiphase", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewMultiphaseView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionType.playground, typeName: "Playground", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewPlaygroundView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionType.compsim, typeName: "Comp Sim", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewCompsimView)
                        
                        Spacer()
                        
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        
                        CloseButton {
                            dismiss()
                        }
                        .padding([.top, .trailing])
                    }
                    Spacer()
                }
            )
        }
    }
}
