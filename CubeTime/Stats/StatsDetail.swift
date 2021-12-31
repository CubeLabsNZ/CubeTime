import SwiftUI

struct StatsDetail: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    let solves: CalculatedAverage
    let session: Sessions
    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "h:mm a, MM/dd/yyyy"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 10) {
                        HStack {
                            Text(formatSolveTime(secs: solves.average))
                                .font(.system(size: 34, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        HStack (alignment: .center) {
                            Text(session.name ?? "Unknown session name")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
                            Text(puzzle_types[Int(session.scramble_type)].name)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                        .padding(.horizontal)
                        .padding(.top, -8)
                        
                        
                        VStack {
                            HStack {
                                Image(puzzle_types[Int(session.scramble_type)].name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .padding(.leading, 2)
                                    .padding(.trailing, 4)
                                
                                Text(puzzle_types[Int(session.scramble_type)].name)
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                                Text("RANDOM STATE")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .offset(y: 2)
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            VStack(spacing: 0) {
                                ForEach(Array(zip(solves.accountedSolves.indices, solves.accountedSolves)), id: \.0) {index, solve in
                                    VStack(spacing: 0) {
                                        Divider()
                                            .padding(.leading)
                                            
                                        
                                        HStack {
                                            Text("\(index+1).")
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(Color("AccentColor"))
                                            Text(formatSolveTime(secs: solve.time, penType: PenTypes.init(rawValue: solve.penalty)!))
                                                .font(.system(size: 17, weight: .bold))
                                            
                                            Spacer()
                                            
                                            
                                            
//                                            Text(dateFormatter.string(from: solve.date!))
                                            Text(solve.date ?? Date(timeIntervalSince1970: 0), format: .dateTime.hour().minute().second().day().month().year())
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                        .padding(.top, 8)
                                        .padding(.horizontal)
                                        
                                        HStack {
                                            Text(solve.scramble ?? "Failed to load scramble")
                                                .font(.system(size: 17, weight: .medium))
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, (index != solves.accountedSolves.indices.last!) ? 8 : 0)
                                    }
                                }
                            }
                            .padding(.bottom)
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                    }
                    .offset(y: -6)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(solves.id)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Stats")
                                    .padding(.leading, -4)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                print("button pressed")
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                }
            }
        }
        
        
    }
}
