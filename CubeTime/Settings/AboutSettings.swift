import SwiftUI


enum ProjectLicense {
    case cubetime
    case chaotimer
    case chartview
    case icons
    case recursivefont
    case privacypolicy
}


struct LicensePopUpView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var projectLicense: ProjectLicense?
    var body: some View {
        ScrollView {
            switch projectLicense {
            case .cubetime:
                CubeTimeLicense()
            case .chaotimer:
                ChaoTimerLicense()
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
    }
}


struct LicensesPopUpView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @State var showLicense = false
    @Binding var showLicenses: Bool
    @State var projectLicense: ProjectLicense?
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", destination: LicensePopUpView(projectLicense: $projectLicense), isActive: $showLicense)
                
                List {
                    Button("CubeTime") {
                        projectLicense = .cubetime
                        showLicense = true
                    }
                    Button("ChaoTimer") {
                        projectLicense = .chaotimer
                        showLicense = true
                    }
                    Button("ChartView") {
                        projectLicense = .chartview
                        showLicense = true
                    }
                    Button("WCA Icons (Cubing Icons and Fonts)") {
                        projectLicense = .icons
                        showLicense = true
                    }
                    Button("Recursive Font") {
                        projectLicense = .recursivefont
                        showLicense = true
                    }
                    Button("Privacy Policy") {
                        projectLicense = .privacypolicy
                        showLicense = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Licenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
        .accentColor(accentColour)
    }
}

struct AboutSettingsView: View {
    @AppStorage("onboarding") var showOnboarding = false
    @State var showLicenses = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image("about-icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.trailing, 6)
                
                VStack(alignment: .leading) {
                    Text("CubeTime.")
                        .font(Font.custom("recursive", fixedSize: 30))
                        .padding(.top, 20)
                    Text("VERSION \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)\n")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(uiColor: .systemGray))
                }
                .padding(.bottom, 4)
            }
            
            VStack (alignment: .leading, spacing: 0) {
                Text("CubeTime is licensed under the GNU GPL v3 license, and uses open source projects and libraries.\nClick below for more info on source licenses and our privacy policy:")
                    .multilineTextAlignment(.leading)
                                
                Button("Open licenses") {
                    showLicenses = true
                }
                            
                Text("\nThis project is kindly sponsored by speedcube.co.nz!\nGo support our local businesses and Buy your cubes from https://www.speedcube.co.nz/   \n")
                
                
                Text("If you need help, you can view the tutorial again:")
                Button("Tutorial") { showOnboarding = true }
                    
                    
                
                

                
                Text("or view our github page!\nhttps://github.com/CubeStuffs/CubeTime")
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showLicenses) {
            LicensesPopUpView(showLicenses: $showLicenses)
        }
    }
}
