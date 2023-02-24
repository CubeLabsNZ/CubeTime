import SwiftUI
import CoreData
import Combine

struct NewSessionModalView: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
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
        VStack {
            NavigationView {
                VStack {
                    #warning("BUG: ADD NEW SESSION TEXT DOES NOT DISPLAY ON IPOD TOUCH")
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.bottom, 8)
                            .padding(.top, globalGeometrySize.height/12)
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 48) {
                        NewSessionTypeCardGroup(title: "Normal Sessions") {
                            
                            NewSessionTypeCard(name: "Standard Session", icon: "timer.square", iconProps: SessionTypeIconProps(), show: $showNewStandardSessionView)
                        
                            Divider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Multiphase", icon: "square.stack", iconProps: SessionTypeIconProps(size: 24, leaPadding: 10, traPadding: 6), show: $showNewMultiphaseView)
                            
                            Divider()
                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Playground", icon: "square.on.square", iconProps: SessionTypeIconProps(size: 24), show: $showNewPlaygroundView)
                        }
                        
                        
                        NewSessionTypeCardGroup(title: "Other Sessions") {
//                            NewSessionTypeCard(name: "Algorithm Trainer", icon: "command.square", iconProps: SessionTypeIconProps(), show: $showNewAlgTrainerView)
//
//                            Divider()
//                                .padding(.leading, 48)
                            
                            NewSessionTypeCard(name: "Comp Sim", icon: "globe.asia.australia", iconProps: SessionTypeIconProps(weight: .medium), show: $showNewCompsimView)
                        }
                        
                        
                        
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.standard, typeName: "Standard", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewStandardSessionView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.multiphase, typeName: "Multiphase", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewMultiphaseView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.playground, typeName: "Playground", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewPlaygroundView)
                        NavigationLink("", destination: NewSessionView(sessionType: SessionTypes.compsim, typeName: "Comp Sim", showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewCompsimView)
                        
                        Spacer()
                        
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button {
                                dismiss()
                            } label: {
                                CloseButton()
                                    .padding([.trailing, .top])
                            }
                        }
                        Spacer()
                    }
                )
            }
//            .navigationViewStyle(StackNavigationViewStyle())
            .accentColor(accentColour)
        }
    }
}
