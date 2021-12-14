import SwiftUI


enum ProjectLicense {
    case txmer
    case chaotimer
    case chartview
    case icons
    case recursivefont
    case privacypolicy
}


struct LicensePopUpView: View {
    @Binding var projectLicense: ProjectLicense?
    var body: some View {
        ScrollView {
            switch projectLicense {
            case .txmer:
                TxmerLicense()
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


@available(iOS 15.0, *)
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
                    Button("txmer") {
                        projectLicense = .txmer
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
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.leading, -8)
                        Text("Back")
//                            .padding(.leading, -8)
                    }
                }
            }
        }
        
    }
}

@available(iOS 15.0, *)
struct AboutSettingsView: View {
    
    @State var showLicenses = false
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack(alignment: .center) {
                Image("about-icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.trailing, 6)
                
                VStack(alignment: .leading) {
                    Spacer()
                    Text("txmer.")
                        .font(Font.custom("recursive", fixedSize: 30))
                    Text("VERSION \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)\n")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(uiColor: .systemGray))
                }
            }
            
            
            Text("txmer is licensed under the GNU GPL v3 license, and uses open source projects and libraries.\n\nClick below for more info.")
            Button {
                showLicenses = true
            } label: {
                Text("Open source licenes and privacy policy")
            }
            
            Text("\n\nOur Github project:\nhttps://github.com/pdtcubing/txmer")
            
            if Locale.current.regionCode == "NZ" {
                Text("\n\nBuy your cubes from\nhttps://www.speedcube.co.nz/ ❤️")
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showLicenses) {
            LicensesPopUpView(showLicenses: $showLicenses)
        }
    }
}
