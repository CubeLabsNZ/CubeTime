import SwiftUI
import StoreKit

class CTDonation {
    static let fiveDonationIdentifier = "com.cubetime.cubetime.5donation"
    static let tenDonationIdentifier = "com.cubetime.cubetime.10donation"
    static let fiftyDonationIdentifity = "com.cubetime.cubetime.50donation"
}


enum ProjectLicense: String {
    case cubetime = "CubeTime"
    case tnoodle = "TNoodle"
    case chartview = "ChartView"
    case icons = "WCA Icons (Cubing Icons & Fonts)"
    case recursivefont = "Recursive Font"
    case privacypolicy = "CubeTime Privacy Policy"
}


struct LicensePopUpView: View {
    var projectLicense: ProjectLicense?
    
    init(for projectLicense: ProjectLicense?) {
        self.projectLicense = projectLicense
    }
    
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


struct LicensesView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Licenses") {
                    NavigationLink(ProjectLicense.cubetime.rawValue, destination: LicensePopUpView(for: .cubetime))
                    NavigationLink(ProjectLicense.tnoodle.rawValue, destination: LicensePopUpView(for: .tnoodle))
                    NavigationLink(ProjectLicense.chartview.rawValue, destination: LicensePopUpView(for: .chartview))
                    NavigationLink(ProjectLicense.icons.rawValue, destination: LicensePopUpView(for: .icons))
                    NavigationLink(ProjectLicense.recursivefont.rawValue, destination: LicensePopUpView(for: .recursivefont))
                }
                
                Section("Privacy Policy") {
                    NavigationLink(ProjectLicense.privacypolicy.rawValue, destination: LicensePopUpView(for: .privacypolicy))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Boring stuff")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    CTDoneButton(onTapRun: {
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
    @State private var showUpdates = false
    @ScaledMetric(relativeTo: .largeTitle) var iconSize: CGFloat = 60
    let parentGeo: GeometryProxy
    private let versionString: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack(alignment: .bottom) {
                Image("launchImage")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.trailing, 6)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("CubeTime")
                        .recursiveMono(size: 28)
                        .foregroundColor(Color("dark"))
                    
                    Text("v" + versionString)
                        .recursiveMono(size: 15, weight: .semibold)
                        .foregroundStyle(getGradient(gradientSelected: 0, isStaticGradient: true))
                }
                
                Spacer()
            }
            .frame(height: iconSize)
            .padding(.bottom, 12)
            
            #if DEBUG
            Text("DEBUG BUILD").font(.system(size: 20, weight: .black, design: .monospaced))
            #endif
            
            
            Text("CubeTime is open source and licensed under the GNU GPL v3 license.\n\nWe use many open source projects and libraries, and you can view their respective licenses, along with our privacy policy below:")
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
            CTButton(type: .halfcoloured(nil), size: .medium, onTapRun: {
                showLicenses = true
            }) {
                Label("Open Licenses & Privacy Policy", systemImage: "arrow.up.forward.square")
                    .imageScale(.medium)
            }
            .padding(.top, -6)
            
            Text("\nCubeTime is made possible by [speedcube.co.nz](https://www.speedcube.co.nz/).")
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\nSupport us directly by donating on Ko-Fi:")
                .fixedSize(horizontal: false, vertical: true)
            
            Button {
                guard let kofiLink = URL(string: "https://ko-fi.com/cubetime"), UIApplication.shared.canOpenURL(kofiLink) else { return }
                UIApplication.shared.open(kofiLink, options: [:], completionHandler: nil)
            } label: {
                Image("kofiButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: parentGeo.size.width * 0.618)
                    .frame(maxHeight: 40)
            }
            .padding(.top, -8)
            
            Text("\nIf you run into any issues, please visit our GitHub page and submit an issue. \nhttps://github.com/CubeStuffs/CubeTime/issues")
                .fixedSize(horizontal: false, vertical: true)
            
            CTButton(type: .halfcoloured(nil), size: .medium, onTapRun: {
                self.showUpdates = true
            }) {
                Text("Show Updates List")
            }
            .padding(.top, 6)
            
            
            #if false
            Text("\nIf you need a refresher on the primary features, you can see the welcome page again.")
            Button("Show welcome page") {
                showOnboarding = true
            }
            #endif
            
            Text("© 2021–2024 Tim Xie & Reagan Bohan.")
                .font(.system(size: 13))
                .foregroundColor(Color("grey").opacity(0.36))
                .padding(.top, 32)
        }
        .padding(.horizontal)
        .sheet(isPresented: $showLicenses) {
            LicensesView()
                .tint(Color("accent"))
        }
        .sheet(isPresented: $showUpdates) {
            Updates(showUpdates: .constant(true))
        }
    }
}
