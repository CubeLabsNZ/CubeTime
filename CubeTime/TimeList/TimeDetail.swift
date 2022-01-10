//
//  TimeDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 10/01/22.
//

import SwiftUI

struct TimeDetail: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    
    private let titleDateFormat: DateFormatter
    
    var timeListManager: TimeListManager?
    
    @State var offsetValue: CGFloat = -25
    
    
    let solve: Solves
    
    // Copy all items out of solve that are used by the UI
    // This is so that when the item is deleted they don't reset to default values
    let date: Date
    let time: String
    let puzzle_type: PuzzleType
    let puzzle_subtype: String
    let scramble: String
    
//    @Binding var currentSession: Sessions
    
    @Binding var currentSolve: Solves?
    
    @State private var userComment: String
    
    
    init(/*currentSession: Binding<Sessions>*/solve: Solves, currentSolve: Binding<Solves?>?, timeListManager: TimeListManager?){
        
//        self._currentSession = currentSession
        
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.puzzle_subtype = puzzle_type.subtypes[Int(solve.scramble_subtype)]!
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        self.timeListManager = timeListManager
        _userComment = State(initialValue: solve.comment ?? "")
        
        
        self.titleDateFormat = DateFormatter()
        
        titleDateFormat.locale = Locale(identifier: "en_US_POSIX")
        titleDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        titleDateFormat.dateFormat = "h:mm a, MMM d, yyyy"
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 12) {
                        HStack {
                            Text(time)
                                .font(.system(size: 34, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        HStack {
//                            Text(date, format: .dateTime.day().month().year())
                            Text(date, formatter: titleDateFormat)
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                        
                        VStack {
                            HStack {
                                Image(puzzle_type.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    
                                    .padding(.leading, 2)
                                    .padding(.trailing, 4)
                                
                                Text(puzzle_type.name)
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                                Text(puzzle_subtype.uppercased())
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .offset(y: 2)
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            if puzzle_type.name == "Megaminx" {
                                Text(scramble.dropLast())
                                
                                
                                
                                    .font(.system(size: (UIScreen.screenWidth-32) / (42.00) * 1.44, weight: .regular, design: .monospaced))
                                
//                                    .frame(maxWidth: UIScreen.screenWidth - 40)
                                
//                                    .minimumScaleFactor(0.5)
//                                    .fixedSize(horizontal: true, vertical: false)
                                
//                                    .offset(x: 4)
                                
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                    .padding([.bottom, .horizontal], 12)

                                
                            } else {
                                Text(scramble)
                                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                    .padding([.bottom, .horizontal], 12)
                            }
                            
                            
                            /*
                            Divider()
                                .padding(.leading)
                            
                            Image("scramble-placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding([.horizontal, .bottom])
                                .padding(.top, 12)
                            */
                        }
//                        .frame(maxHeight: puzzle_type.name == "Megaminx" ? 220 : nil)
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
                        
                        .padding(.top, -10)
                        .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Image(systemName: "square.text.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                //.padding(.trailing, 8)
                                Text("Comment")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                                
                            }
                            //.padding(.leading)
                            //                            .padding(.trailing)
                            //                            .padding(.top)
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            //                                .padding(.bottom)
                            
                            ZStack {
                                TextEditor(text: $userComment)
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)
                                    .onChange(of: userComment) { newValue in
                                        solve.comment = newValue
                                    }
                                Text(userComment).opacity(0)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                
                            }
                            
                            
                            /*TextField("Notes", text: $userComment)
                            
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                .onChange(of: userComment) { newValue in
                                    solve.comment = newValue
                                }
                             */
                            
                        }
                        //.frame(minHeight: minRowHeight * 10)
                        //.frame(height: 300)
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        Button {
                            UIPasteboard.general.string = "Generated by CubeTime.\n\(time): \(scramble)"
                            withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 20).delay(0.25)) {
                                self.offsetValue = 0
                            }
                        } label: {
                            HStack {
                                Text("Copy Solve")
                                    .padding([.leading, .vertical], 14)
                                
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .clipShape(Rectangle().offset(x: self.offsetValue))
                                
                                Spacer()
                            }
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                            
                        
                        
                        
                        
                        
                    }
                    .offset(y: -6)
                    .navigationBarTitle("", displayMode: .inline)
//                    .navigationTitle(time)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) { // Only show delete if called from timelist and not stats
                            if timeListManager != nil {
                                Button {
                                    withAnimation {
                                        currentSolve = nil
                                    }
                                    managedObjectContext.delete(solve) // Todo read context from environment
                                    timeListManager?.resort()
                                    try! managedObjectContext.save()
                                } label: {
                                    Text("Delete Solve")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color.red)
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                currentSolve = nil
                                
//                                self.presentation.wrappedValue.dismiss()
                                
                                dismiss()
                                
//                                dismiss() // Dismiss in case called from StatsView
                                    
                                if managedObjectContext.hasChanges {
                                    try! managedObjectContext.save()
                                }
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                }
            }
        }
    }
}


struct TimeDetailViewOnly: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    
    private let titleDateFormat: DateFormatter
    
    var timeListManager: TimeListManager?
    
    @State var offsetValue: CGFloat = -25
    
    
    let solve: Solves
    
    // Copy all items out of solve that are used by the UI
    // This is so that when the item is deleted they don't reset to default values
    let date: Date
    let time: String
    let puzzle_type: PuzzleType
    let puzzle_subtype: String
    let scramble: String
    
//    @Binding var currentSession: Sessions
    
    @Binding var currentSolve: Solves?
    
    @State private var userComment: String
    
    
    init(/*currentSession: Binding<Sessions>*/solve: Solves, currentSolve: Binding<Solves?>?, timeListManager: TimeListManager?){
        
//        self._currentSession = currentSession
        
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.puzzle_subtype = puzzle_type.subtypes[Int(solve.scramble_subtype)]!
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        self.timeListManager = timeListManager
        _userComment = State(initialValue: solve.comment ?? "")
        
        
        self.titleDateFormat = DateFormatter()
        
        titleDateFormat.locale = Locale(identifier: "en_US_POSIX")
        titleDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        titleDateFormat.dateFormat = "h:mm a, MMM d, yyyy"
        
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView() {
                VStack (spacing: 12) {
                    HStack {
                        Text(time)
                            .font(.system(size: 34, weight: .bold))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    HStack {
//                            Text(date, format: .dateTime.day().month().year())
                        Text(date, formatter: titleDateFormat)
                            .font(.system(size: 22, weight: .semibold, design: .default))
                            .foregroundColor(Color(uiColor: .systemGray))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, -10)
                    
                    VStack {
                        HStack {
                            //Image("sq-1")
                            //  .padding(.trailing, 8)
                            Image(puzzle_type.name)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                
                                .padding(.leading, 2)
                                .padding(.trailing, 4)
                            //.padding(.leading)
                            
                            Text(puzzle_type.name)
                                .font(.system(size: 17, weight: .semibold, design: .default))
                            
                            Spacer()
                            
                            Text(puzzle_subtype.uppercased())
                                .font(.system(size: 13, weight: .semibold, design: .default))
                                .offset(y: 2)
                            
                        }
                        .padding(.leading, 12)
                        .padding(.trailing)
                        .padding(.top, 12)
                        
                        Divider()
                            .padding(.leading)
                        
                        if puzzle_type.name == "Megaminx" {
                            Text(scramble.dropLast())
                            
                            
                            
                                .font(.system(size: (UIScreen.screenWidth-32) / (42.00) * 1.44, weight: .regular, design: .monospaced))
                            
//                                    .frame(maxWidth: UIScreen.screenWidth - 40)
                            
//                                    .minimumScaleFactor(0.5)
//                                    .fixedSize(horizontal: true, vertical: false)
                            
//                                    .offset(x: 4)
                            
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            
                                .padding([.bottom, .horizontal], 12)

                            
                        } else {
                            Text(scramble)
                                .font(.system(size: 16, weight: .regular, design: .monospaced))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .padding([.bottom, .horizontal], 12)
                        }
                        
                        
                        /*
                        Divider()
                            .padding(.leading)
                        
                        Image("scramble-placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding([.horizontal, .bottom])
                            .padding(.top, 12)
                        */
                    }
//                        .frame(maxHeight: puzzle_type.name == "Megaminx" ? 220 : nil)
                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
                    
                    .padding(.trailing)
                    .padding(.leading)
                    
                    VStack {
                        HStack {
                            Image(systemName: "square.text.square.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            //.padding(.trailing, 8)
                            Text("Comment")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            
                            Spacer()
                            
                        }
                        //.padding(.leading)
                        //                            .padding(.trailing)
                        //                            .padding(.top)
                        .padding(.leading, 12)
                        .padding(.trailing)
                        .padding(.top, 12)
                        
                        Divider()
                            .padding(.leading)
                        //                                .padding(.bottom)
                        
                        ZStack {
                            TextEditor(text: $userComment)
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                                .onChange(of: userComment) { newValue in
                                    solve.comment = newValue
                                }
                            Text(userComment).opacity(0)
                                .padding(.horizontal)
                                .padding(.bottom)
                            
                        }
                        
                        
                        /*TextField("Notes", text: $userComment)
                        
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                            .onChange(of: userComment) { newValue in
                                solve.comment = newValue
                            }
                         */
                        
                    }
                    //.frame(minHeight: minRowHeight * 10)
                    //.frame(height: 300)
                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                    //.listStyle(.insetGrouped)
                    .padding(.trailing)
                    .padding(.leading)
                    
                    Button {
                        UIPasteboard.general.string = "Generated by CubeTime.\n\(time): \(scramble)"
                        withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 20).delay(0.25)) {
                            self.offsetValue = 0
                        }
                    } label: {
                        HStack {
                            Text("Copy Solve")
                                .padding([.leading, .vertical], 14)
                            
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .clipShape(Rectangle().offset(x: self.offsetValue))
                            
                            Spacer()
                        }
                    }
                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                    .padding(.horizontal)
                        
                    
                    
                    
                    
                    
                }
                .offset(y: -6)
                .navigationBarTitle("", displayMode: .inline)
                
            }
        }
        
    }
}
