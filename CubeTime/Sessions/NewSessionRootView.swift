import SwiftUI
import CoreData

struct NewSessionTypeCard: View {
    let name: String
    let icon: SessionTypeIcon
    
    var body: some View {
        HStack {
            Group {
                Image(systemName: icon.iconName)
                    .font(.system(size: icon.size))
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
    }
}


struct NewSessionTypeCardGroup<Content: View>: View {
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
    
    @Binding var showNewSessionPopUp: Bool
    
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColour()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        CTCloseButton {
                            dismiss()
                        }
                        .padding([.top, .trailing])
                    }
                    
                    Text("Add New Session")
                        .font(.largeTitle.bold())
                        .padding(.bottom, 8)
                        .padding(.top)
                    
                    
                    VStack(alignment: .leading, spacing: 48) {
                        NewSessionTypeCardGroup(title: String(localized: "Normal Sessions")) {
                            NavigationLink(destination: NewSessionView(sessionType: SessionType.standard, typeName: "Standard", showNewSessionPopUp: $showNewSessionPopUp)) {
                                NewSessionTypeCard(name: String(localized: "Standard Session"), icon: SessionTypeIcon(iconName: "timer.square"))
                            }
                            
                            CTDivider()
                                .padding(.leading, 48)
                            
                            NavigationLink(destination: NewSessionView(sessionType: SessionType.multiphase, typeName: "Multiphase", showNewSessionPopUp: $showNewSessionPopUp)) {
                                NewSessionTypeCard(name: String(localized: "Multiphase"), icon: SessionTypeIcon(size: 24, iconName: "square.stack", padding: (10, 6)))
                            }
                            
                            CTDivider()
                                .padding(.leading, 48)
                            
                            NavigationLink(destination: NewSessionView(sessionType: SessionType.playground, typeName: "Playground", showNewSessionPopUp: $showNewSessionPopUp)) {
                                NewSessionTypeCard(name: String(localized: "Playground"), icon: SessionTypeIcon(size: 24, iconName: "square.on.square"))
                            }
                        }
                        
                        NewSessionTypeCardGroup(title: String(localized: "Other Sessions")) {
                            NavigationLink(destination: NewSessionView(sessionType: SessionType.compsim, typeName: "Compsim", showNewSessionPopUp: $showNewSessionPopUp)) {
                                NewSessionTypeCard(name: String(localized: "Compsim"), icon: SessionTypeIcon(size: 24, iconName: "globe.asia.australia"))
                            }
                            
                            CTDivider()
                                .padding(.leading, 48)
                            
                            NavigationLink(destination: NewSessionView(sessionType: SessionType.timerOnly, typeName: "Timer Only", showNewSessionPopUp: $showNewSessionPopUp)) {
                                NewSessionTypeCard(name: String(localized: "Timer Only"), icon: SessionTypeIcon(size: 24, iconName: "timer"))
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
        }
        .accentColor(Color("accent"))
        .tint(Color("accent"))
    }
}
