import SwiftUI

struct ImportExportSettingsView: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    @FetchRequest(entity: Sessions.entity(), sortDescriptors: []) var sessions: FetchedResults<Sessions>
    
    var body: some View {
         VStack(spacing: 16) {
             VStack {
                 HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(accentColour)
                    Text("Import")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                 
                 VStack {
                     HStack {
                         HStack {
                             // Group needed for padding
                             Group {
                                 Text("Import from \n")
                                     .font(.system(size: 17, weight: .bold))
                                     .foregroundColor(.white) +
                                    Text("CubeTime")
                                        .font(.custom("RecursiveSansLnrSt-Regular", size: 17))
                                        .foregroundColor(.white)
                             }
                             .padding(6)
                             .padding(.bottom, 16)
                             
                             VStack {
                                 Spacer()
                                 Image("about-icon")
                                     .resizable()
                                     .frame(width: 32, height: 32, alignment: .bottomLeading)
                                     .aspectRatio(contentMode: .fit)
                                     .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                     .padding(6)
                             }
                         }
                         .background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius: 8)))
                         
                        
                     }
                     HStack {
                         HStack {
                             // Group needed for padding
                             Group {
                                 Text("Export to \n")
                                     .font(.system(size: 17, weight: .bold))
                                     .foregroundColor(.white) +
                                    Text("CubeTime")
                                        .font(.custom("RecursiveSansLnrSt-Regular", size: 17))
                                        .foregroundColor(.white)
                             }
                             .padding(6)
                             .padding(.bottom, 16)
                             
                             VStack {
                                 Spacer()
                                 Image("about-icon")
                                     .resizable()
                                     .frame(width: 32, height: 32, alignment: .bottomLeading)
                                     .aspectRatio(contentMode: .fit)
                                     .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                     .padding(6)
                             }
                         }
                         .background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius: 8)))
                         .onTapGesture {
                             let dict: [String: Any] = [
                                "file_version": 1,
                                "data": sessions.map { session -> [String: Any] in
                                    let keys = Array(session.entity.attributesByName.keys)
                                    var dict = session.dictionaryWithValues(forKeys: keys)
                                    if let session = session as? CompSimSession {
                                        dict["solvegroups"] = (session.solvegroups!.array as! [CompSimSolveGroup]).map { solvegroup -> [String: Any] in
                                            let keys = Array(solvegroup.entity.attributesByName.keys)
                                            var dict = solvegroup.dictionaryWithValues(forKeys: keys)
                                            dict["solves"] = (solvegroup.solves!.array as! [Solves]).map { solve -> [String: Any] in
                                                let keys = Array(solve.entity.attributesByName.keys)
                                                var dict = solve.dictionaryWithValues(forKeys: keys)
                                                // Someone please tell me if you can use a Date extension instead!
                                                dict["date"] = Int(solve.date!.timeIntervalSince1970 * 1000)
                                                return dict
                                            }
                                            return dict
                                        }
                                    }
                                    dict["solves"] = (session.solves!.allObjects as! [Solves]).map { solve -> [String: Any] in
                                        let keys = Array(solve.entity.attributesByName.keys)
                                        var dict = solve.dictionaryWithValues(forKeys: keys)
                                        // Someone please tell me if you can use a Date extension instead!
                                        dict["date"] = Int(solve.date!.timeIntervalSince1970 * 1000)
                                        return dict
                                    }
                                    return dict
                                }
                             ]
                             
                             let jsondata = try! JSONSerialization.data(withJSONObject: dict, options: [])
                             let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("export")
                             try! jsondata.write(to: path) // TODO handle error
                             
                             let filesToShare = [path]
                             
                             let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                             
                             // completion is delete file
                             NSLog("present!")
                             UIApplication.shared.windows.first!.rootViewController!.present(activityViewController, animated: true, completion: nil)
                         }
                     }
                 }
             }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
         }
         .padding(.horizontal)
    }
}
