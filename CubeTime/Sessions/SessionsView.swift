import SwiftUI
import CoreData
import Combine


/// **Extensions and other views/viewmodifiers**
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct NewStandardSessionViewBlocks: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    func body(content: Content) -> some View {
        content
            .background(colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
            .cornerRadius(10)
        
            .padding(.trailing)
            .padding(.leading)
    }
}

struct ContextMenuButton: View {
    var action: () -> Void
    var title: String
    var systemImage: String? = nil
    var disableButton: Bool? = nil
    
    var body: some View {
        Button(role: title == "Delete Session" ? .destructive : nil, action: delayedAction) {
            HStack {
                Text(title)
                if image != nil {
                    Image(uiImage: image!)
                }
            }
        }.disabled(disableButton ?? false)
    }
    
    private var image: UIImage? {
        if let systemName = systemImage {
            let config = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body), scale: .medium)
            
            return UIImage(systemName: systemName, withConfiguration: config)
        } else {
            return nil
        }
    }
    private func delayedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.action()
        }
    }
}

/// **Customise Sessions **
struct CustomiseStandardSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    let sessionItem: Sessions
    
    @State private var name: String
    
    @State var pinnedSession: Bool
    
    let sessionEventType: Int32
    
    init(sessionItem: Sessions) {
        self.sessionItem = sessionItem
        self._name = State(initialValue: sessionItem.name ?? "")
        self._pinnedSession = State(initialValue: sessionItem.pinned)
        self.sessionEventType = sessionItem.scramble_type
    }
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (alignment: .center, spacing: 0) {
                        Image(puzzle_types[Int(sessionEventType)].name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                        
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                        
                    }
                    .frame(height: 220)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                }
                .ignoresSafeArea(.keyboard)
                .navigationBarTitle("Customise Session", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            sessionItem.name = name
                            sessionItem.pinned = pinnedSession
                            try! managedObjectContext.save()
                            
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                        .disabled(self.name.isEmpty)
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}


/// **New sessions**
struct NewSessionPopUpView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showNewStandardSessionView = false
    @State private var showNewAlgTrainerView = false
    @State private var showNewMultiphaseView = false
    @State private var showNewPlaygroundView = false
    @State private var showNewCompsimView = false
    
    //    @State private var showNewCompSimView = false
    
    
    @State private var testBool = false
    
    @Binding var currentSession: Sessions
    @Binding var showNewSessionPopUp: Bool
    
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.bottom, 8)
                            .padding(.top, UIScreen.screenHeight/12)
                        Text("You can choose from four different types of sessions, out of the following: ")
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Group {
                            Text("Normal Sessions")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .padding(.leading, 20)
                                .padding(.bottom, 8)
                            
                            HStack {
                                Image(systemName: "timer.square")
                                    .font(.system(size: 26, weight: .regular))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 4)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                Text("Standard Session")
                                    .font(.system(size: 17, weight: .regular, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //.padding(10)
                                Spacer()
                            }
                            
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                            .onTapGesture {
                                showNewStandardSessionView = true
                            }
                            .cornerRadius(10, corners: .topRight)
                            .cornerRadius(10, corners: .topLeft)
                            .padding(.leading)
                            .padding(.trailing)
                            
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color(uiColor: colourScheme == .dark ? .black : .systemGray6))
                                    .frame(height: 1)
                                    .padding(.leading)
                                    .padding(.trailing)
                                
                                Divider()
                                    .padding(.leading, 64)
                                    .padding(.trailing)
                            }
                            
                            
                            
                            HStack {
                                Image(systemName: "command.square")
                                    .font(.system(size: 26, weight: .regular))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //                                    .symbolRenderingMode(.hierarchical)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 4)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                Text("Algorithm Trainer") // wip
                                    .font(.system(size: 17, weight: .regular, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                            }
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                                            .clipShape(Rectangle()))
                            .onTapGesture {
                                showNewAlgTrainerView = true
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color(uiColor: colourScheme == .dark ? .black : .systemGray6))
                                    .frame(height: 1)
                                    .padding(.leading)
                                    .padding(.trailing)
                                Divider()
                                    .padding(.leading, 64)
                                    .padding(.trailing)
                            }
                        }
                        
                        
                        Group {
                            HStack {
                                Image(systemName: "square.stack")
                                    .font(.system(size: 24, weight: .regular))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //                                .symbolRenderingMode(.hierarchical)
                                    .padding(.leading, 10)
                                    .padding(.trailing, 6)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                Text("Multiphase") // wip
                                    .font(.system(size: 17, weight: .regular, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                            }
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                                            .clipShape(Rectangle()))
                            .onTapGesture {
                                showNewMultiphaseView = true
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color(uiColor: colourScheme == .dark ? .black : .systemGray6))
                                    .frame(height: 1)
                                    .padding(.leading)
                                    .padding(.trailing)
                                
                                Divider()
                                    .padding(.leading, 64)
                                    .padding(.trailing)
                            }
                            
                            
                            
                            
                            
                            HStack {
                                Image(systemName: "square.on.square")
                                    .font(.system(size: 24, weight: .regular))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //                                .symbolRenderingMode(.hierarchical)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 4)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                Text("Playground") // wip
                                    .font(.system(size: 17, weight: .regular, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                            }
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                            .onTapGesture {
                                showNewPlaygroundView = true
                            }
                            .cornerRadius(10, corners: .bottomRight)
                            .cornerRadius(10, corners: .bottomLeft)
                            .padding(.horizontal)
                            
                            
                            
                            
                            Text("Other Sessions")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .padding(.top, 48)
                                .padding(.leading, 20)
                                .padding(.bottom, 8)
                             
                             
                             
                            HStack {
                                Image(systemName: "globe.asia.australia")
                                    .font(.system(size: 26, weight: .medium))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //                                .symbolRenderingMode(.hierarchical)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 4)
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                Text("Comp Sim") // wip
                                    .font(.system(size: 17, weight: .regular, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                            }
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                                            .clipShape(RoundedRectangle(cornerRadius: 10)))
                            .onTapGesture {
                                showNewCompsimView = true
                            }
                            .padding(.leading)
                            .padding(.trailing)
                        }
                        
                        
                        
                        NavigationLink("", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession, pinnedSession: false), isActive: $showNewStandardSessionView)
                        
                        NavigationLink("", destination: NewAlgTrainerView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession, pinnedSession: false), isActive: $showNewAlgTrainerView)
                        
                        NavigationLink("", destination: NewMultiphaseView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession, pinnedSession: false), isActive: $showNewMultiphaseView)
                        
                        NavigationLink("", destination: NewPlaygroundView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession, pinnedSession: false), isActive: $showNewPlaygroundView)
                        
                        NavigationLink("", destination: NewCompsimView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession, pinnedSession: false), isActive: $showNewCompsimView)
                        
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
                                print("new session view closed")
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                                    .foregroundStyle(colourScheme == .light ? .black : .white)
                                    .padding(.top)
                                    .padding(.trailing)
                            }
                        }
                        Spacer()
                    }
                )
            }
        }
    }
}

struct NewStandardSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    @State private var sessionEventType: Int32 = 0
    @State var pinnedSession: Bool
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        Image(puzzle_types[Int(sessionEventType)].name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                        
                        
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                        
                    }
                    .frame(height: 212)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()
                            
                            Picker("", selection: $sessionEventType) {
                                ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(accentColour)
                            .font(.system(size: 17, weight: .regular))
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
                            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                Button {
                                    sessionEventType = Int32(index)
                                } label: {
                                    ZStack {
                                        Image("circular-" + element.name)
                                        
                                        Circle()
                                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                                            .frame(width: 54, height: 54)
                                            .offset(x: -0.2)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 180)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Standard Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct NewAlgTrainerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    @State private var sessionEventType: Int32 = 0
    @State var pinnedSession: Bool
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                            .padding(.top)
                        
                        Text("A simple alg trainer to train you on a certain algset. Select the algset to train using the picker below.")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .padding(.bottom)
                    }
                    .frame(minHeight: 80)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Algorithm Subset")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()
                            
                            Picker("", selection: $sessionEventType) {
                                ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(accentColour)
                            .font(.system(size: 17, weight: .regular))
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Algorithm Trainer", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        
                        sessionItem.session_type = 1
                        
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct NewMultiphaseView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    @State private var sessionEventType: Int32 = 0
    @State var pinnedSession: Bool
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        Image(puzzle_types[Int(sessionEventType)].name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                        
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                        
                        Text("A multiphase session gives you the ability to breakdown your solves into sections, such as blindfolded solves or 3x3 stages.\n\nTo use, tap anywhere on the timer during a solve to record a phase lap. You can access your breakdown statistics in each time card.")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }
                    .frame(minHeight: 80)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Phases")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Text("Stepper")
                            
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()
                            
                            Picker("", selection: $sessionEventType) {
                                ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(accentColour)
                            .font(.system(size: 17, weight: .regular))
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
                            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                Button {
                                    sessionEventType = Int32(index)
                                } label: {
                                    ZStack {
                                        Image("circular-" + element.name)
                                        
                                        Circle()
                                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                                            .frame(width: 54, height: 54)
                                            .offset(x: -0.2)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 180)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Multiphase Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        
                        sessionItem.session_type = 2
                        
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct NewPlaygroundView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    @State private var sessionEventType: Int32 = 0
    @State var pinnedSession: Bool
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding()
                        
                        Text("A playground session allows you to quickly change the scramble type within a session without having to specify a scramble type for the whole session.")
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .padding([.horizontal, .bottom])
                    }
                    .frame(minHeight: 80)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Playground Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        
                        sessionItem.session_type = 3
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                        
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct NewCompsimView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    @State private var targetStr: String = ""
    @State private var sessionEventType: Int32 = 0
    @State var pinnedSession: Bool
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        Image(puzzle_types[Int(sessionEventType)].name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                        
                        
                        TextField("Session Name", text: $name)
                            .padding(12)
                            .font(.system(size: 22, weight: .semibold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                        
                        Text("A comp sim (Competition Simulation) session mimics a competition scenario better by recording a non-rolling session. Your solves will be split up into averages of 5 that can be accessed in your times and statistics view.\n\nStart by choosing a target to reach.")
                        /// todo: add ability to target your wca pb/some ranking/some official record
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                    }
                    .frame(minHeight: 80)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Target")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            TextField("0.00", text: $targetStr)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onReceive(Just(targetStr)) { newValue in
                                    // TODO make this accept dots from the user
                                    var filtered: String = newValue.filter { $0.isNumber }.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
                                    if filtered.count > 2 {
                                        filtered.insert(".", at: filtered.index(filtered.endIndex, offsetBy: -2))
                                    } else if filtered.count > 0 {
                                        filtered = "0." + repeatElement("0", count: 2 - filtered.count) + filtered
                                    }
                                    if filtered.count > 5 {
                                        filtered.insert(":", at: filtered.index(filtered.endIndex, offsetBy: -5))
                                    }
                                    if filtered != newValue {
                                        self.targetStr = filtered
                                    }
                                }
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()
                            
                            Picker("", selection: $sessionEventType) {
                                ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(accentColour)
                            .font(.system(size: 17, weight: .regular))
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
                            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                Button {
                                    sessionEventType = Int32(index)
                                } label: {
                                    ZStack {
                                        Image("circular-" + element.name)
                                        
                                        Circle()
                                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                                            .frame(width: 54, height: 54)
                                            .offset(x: -0.2)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 180)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    Spacer()
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Comp Sim Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        
                        sessionItem.session_type = 4
                        
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}



/// **Main session views**
struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var currentSession: Sessions
    @State private var isShowingDeleteDialog = false
    @State var customizing = false
    var item: Sessions
    var numSessions: Int
    
    @Namespace var namespace
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: item.pinned ? 110 : 65)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 16)
                .fill(colourScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .frame(width: currentSession == item ? 16 : UIScreen.screenWidth - 32, height: item.pinned ? 110 : 65)
            
                .offset(x: currentSession == item ? -((UIScreen.screenWidth - 16)/2) + 16 : 0)
            
                .zIndex(1)
            
            
            VStack {
                HStack {
                    
                    
                    
                    VStack(alignment: .leading) {
                        
                        HStack(alignment: .center, spacing: 0) {
                            ZStack {
                                if SessionTypes(rawValue: item.session_type)! != .standard {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(accentColour.opacity(0.33))
                                        .frame(width: 40, height: 40)
                                        .padding(.trailing, 12)
                                }
                                switch SessionTypes(rawValue: item.session_type)! {
                                case .algtrainer:
                                    Image(systemName: "command.square")
                                        .font(.system(size: 26, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .playground:
                                    Image(systemName: "square.on.square")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .multiphase:
                                    Image(systemName: "square.stack")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .compsim:
                                    Image(systemName: "globe.asia.australia")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                default:
                                    EmptyView()
                                }
                            }
                            
                            
                            if item.pinned {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unkown session name")
                                        .font(.system(size: 22, weight: .bold, design: .default))
                                        .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                    Text(SessionTypes(rawValue: item.session_type)! != .playground ? puzzle_types[Int(item.scramble_type)].name : "Playground")
                                        .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unkown session name")
                                        .font(.system(size: 22, weight: .bold, design: .default))
                                        .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                    Text(SessionTypes(rawValue: item.session_type)! != .playground ? puzzle_types[Int(item.scramble_type)].name : "Playground")
                                        .font(.system(size: 15, weight: .medium, design: .default))
                                        .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                }
                            }
                        }
                        
                        if item.pinned {
                            Spacer()
                            Text("\(item.solves?.count ?? -1) Solves")
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                                .padding(.bottom, 4)
                        }
                    }
                    .offset(x: currentSession == item ? 10 : 0)
                    
                    Spacer()
                    
                    if item.session_type != 3 {
                        if item.pinned {
                            Image(puzzle_types[Int(item.scramble_type)].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[Int(item.scramble_type)].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.trailing, 6)
                        }
                    }
                    
                    
                }
                .padding(.leading)
                .padding(.trailing, item.pinned ? 6 : 4)
                .padding(.top, item.pinned ? 12 : 8)
                .padding(.bottom, item.pinned ? 12 : 8)
            }
            
            .frame(height: item.pinned ? 110 : 65)
            
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .zIndex(2)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                currentSession = item
            }
        }
        
        .sheet(isPresented: $customizing) {
            CustomiseStandardSessionView(sessionItem: item)
        }
        
        .contextMenu(menuItems: {
            ContextMenuButton(action: {
                customizing = true
            },
                              title: "Customise",
                              systemImage: "pencil");
            ContextMenuButton(action: {
                withAnimation(.spring()) {
                    item.pinned.toggle()
                    try! managedObjectContext.save()
                }
            },
                              title: item.pinned ? "Unpin" : "Pin",
                              systemImage: item.pinned ? "pin.slash" : "pin");
            Divider()
            
            ContextMenuButton(action: {
                isShowingDeleteDialog = true
            },
                              title: "Delete Session",
                              systemImage: "trash",
                              disableButton: numSessions <= 1 || item == currentSession)
                .foregroundColor(Color.red)
        })
        .padding(.trailing)
        .padding(.leading)
        
        
        .confirmationDialog(String("Are you sure you want to delete \"\(item.name ?? "Unknown session name")\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                withAnimation(.spring()) {
                    managedObjectContext.delete(item)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}

struct SessionsView: View {
    @Binding var currentSession: Sessions
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    
    
    
    @State var showNewSessionPopUp = false
    
    
    var solveCount: Int = 1603
    
    
    
    // I know that this is bad
    // I tried to use SectionedFetchRequest to no avail
    // send a PR if you can make this good :)
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ],
        predicate: NSPredicate(format: "pinned == YES")
    ) var pinnedSessions: FetchedResults<Sessions>
    
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ],
        predicate: NSPredicate(format: "pinned == NO")
    ) var unPinnedSessions: FetchedResults<Sessions>
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 10) {
                        ForEach(pinnedSessions) { item in
                            SessionCard(currentSession: $currentSession, item: item, numSessions: pinnedSessions.count + unPinnedSessions.count)
                                .environment(\.managedObjectContext, managedObjectContext)
                            
                        }
                        ForEach(unPinnedSessions) { item in
                            SessionCard(currentSession: $currentSession, item: item, numSessions: pinnedSessions.count + unPinnedSessions.count)
                                .environment(\.managedObjectContext, managedObjectContext)
                            
                        }
                    }
                }
                .navigationTitle("Your Sessions")
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top, 64).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            showNewSessionPopUp = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .padding(.leading, -4)
                            Text("New Session")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
                        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .background(.ultraThinMaterial, in: Capsule())
                        .sheet(isPresented: $showNewSessionPopUp) {
                            NewSessionPopUpView(currentSession: $currentSession, showNewSessionPopUp: $showNewSessionPopUp)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                        .padding(.leading)
                        .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
            }
        }
    }
}
