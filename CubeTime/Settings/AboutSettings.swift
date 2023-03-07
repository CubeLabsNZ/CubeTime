import SwiftUI


enum ProjectLicense: String {
    case cubetime = "CubeTime"
    case tnoodle = "TNoodle"
    case chartview = "ChartView"
    case icons = "WCA Icons (Cubing Icons & Fonts)"
    case recursivefont = "Recursive Font"
    case privacypolicy = "CubeTime Privacy Policy"
}


struct LicensePopUpView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var projectLicense: ProjectLicense?
    
    var body: some View {
        ScrollView {
            switch projectLicense {
            case .cubetime:
                CubeTimeLicense()
            case .tnoodle:
                tnoodleLicense()
            case .chartview:
                ChartViewLicense()
            case .icons:
                CubingIconsLicense()
            case .recursivefont:
                RecursiveLicense()
            case .privacypolicy:
                PrivacyPolicy()
            default:
                Text("Could not get license for project")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(projectLicense?.rawValue ?? "")
    }
}


struct LicensesPopUpView: View {
    @Environment(\.dismiss) var dismiss
    @State var showLicense = false
    @Binding var showLicenses: Bool
    @State var projectLicense: ProjectLicense?
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", destination: LicensePopUpView(projectLicense: $projectLicense), isActive: $showLicense)
                
                List {
                    Button(ProjectLicense.cubetime.rawValue) {
                        projectLicense = .cubetime
                        showLicense = true
                    }
                    Button(ProjectLicense.tnoodle.rawValue) {
                        projectLicense = .tnoodle
                        showLicense = true
                    }
                    Button(ProjectLicense.chartview.rawValue) {
                        projectLicense = .chartview
                        showLicense = true
                    }
                    Button(ProjectLicense.icons.rawValue) {
                        projectLicense = .icons
                        showLicense = true
                    }
                    Button(ProjectLicense.recursivefont.rawValue) {
                        projectLicense = .recursivefont
                        showLicense = true
                    }
                    Button(ProjectLicense.privacypolicy.rawValue) {
                        projectLicense = .privacypolicy
                        showLicense = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Licenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneButton(onTapRun: {
                        dismiss()
                    })
                }
            }
        }
    }
}

struct AboutSettingsView: View {
    @AppStorage("onboarding") var showOnboarding = false
    @State var showLicenses = false
    @ScaledMetric(relativeTo: .largeTitle) var iconSize: CGFloat = 60
    let parentGeo: GeometryProxy
    private let versionString: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 2) {
            HStack(alignment: .bottom) {
                Image("about-icon")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.trailing, 6)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("CubeTime.")
                        .font(.custom("RecursiveSansLnrSt-Regular", size: 30))
                    
                    Text("v" + versionString)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("grey"))
                }
            }
            .frame(height: iconSize)
            .padding(.bottom, 12)
            
            #if DEBUG
            Text("DEBUG BUILD").font(.system(size: 20, weight: .black, design: .monospaced))
            #endif
            
            
            Text("CubeTime is licensed under the GNU GPL v3 license, and uses open source projects and libraries.\n\nClick below for more info on source licenses and our privacy policy:")
                .multilineTextAlignment(.leading)
                            
            Button("Open licenses") {
                showLicenses = true
            }
            
            Text("\nThis project is made possible by [speedcube.co.nz](https://www.speedcube.co.nz/).\nShow some support by buying your cubes from them!\n")
            
            Text("or support us directly by donating on Ko-Fi:")
            
            Button {
                guard let kofiLink = URL(string: "https://ko-fi.com/cubetime"),
                      UIApplication.shared.canOpenURL(kofiLink) else {
                          return
                      }
                UIApplication.shared.open(kofiLink,
                                          options: [:],
                completionHandler: nil)
            } label: {
                HStack {
                    Spacer()
                    
                    Image("kofiButton")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: parentGeo.size.width * 0.618)
                        .frame(maxHeight: 40)
                    
                    Spacer()
                }
            }
            
            Text("\nIf you run into any issues, please visit our GitHub page and submit an issue. \nhttps://github.com/CubeStuffs/CubeTime/issues")
            
            Text("\nIf you need a refresher on the primary features, you can see the welcome page again.")
            Button("Show welcome page") {
                showOnboarding = true
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showLicenses) {
            LicensesPopUpView(showLicenses: $showLicenses)
                .tint(Color("accent"))
        }
    }
}
