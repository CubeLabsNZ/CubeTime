import SwiftUI

struct StatsDetail: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    var solves = [1.78, 1.56, 2.09, 0.98, 3.81]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    
                    
                    VStack (spacing: 10) {
                        HStack {
                            Text("The value of the statistic")
                                .font(.system(size: 34, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        HStack (alignment: .center) {
//                            Text(currentSession.name!)
                            Text("Session Name")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
//                            Text(puzzle_types[Int(currentSession.scramble_type)].name)
                            Text("EVENT")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                        .padding(.horizontal)
                        
                        
                        ForEach(solves, id: \.self) {solve in
                            VStack {
                                HStack {
                                    Text("1.")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("AccentColor"))
                                    Text(String(format: "%.2f", solve))
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Text("The date")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                                .padding([.horizontal, .top], 10)
                                
                                HStack {
                                    Text("Scramble")
                                        .font(.system(size: 17, weight: .medium))
                                    
                                    Spacer()
                                }
                                .padding([.horizontal, .bottom], 10)
                                
                            }
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)))
                            .padding(.horizontal)
                        }
                        
                        
                        
                        Text("\nRemember to gray out the worst and best times along with addding brackets <3")
                        
                        
                    }
                    .offset(y: -6)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Statistic Type")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                print("go back")
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
                                share()
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
    
    func share() {
        guard let url = URL(string: "https://www.apple.com") else { return }
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityView, animated: true, completion: nil)
        /// todo actually make the buttons work
    }
}
