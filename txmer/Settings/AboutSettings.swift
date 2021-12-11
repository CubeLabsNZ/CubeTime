//
//  AboutSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI


enum ProjectLicense {
    case txmer
    case chaotimer
    case chartview
    case icons
    case recursivefont
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
                CuingIconsLicense()
            case .recursivefont:
                Text("OFL TODO")
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
            VStack{
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
                            .foregroundStyle(.black)
                            
                            .padding(.top)
                            .padding(.trailing)
                    }
                }
                Button("txmer itself") {
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
                Button("Cubing Icons") {
                    projectLicense = .icons
                    showLicense = true
                }
                Button("Recursive Font") {
                    projectLicense = .recursivefont
                    showLicense = true
                }
                NavigationLink("", destination: LicensePopUpView(projectLicense: $projectLicense), isActive: $showLicense)
                Spacer()
            }
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
}

@available(iOS 15.0, *)
struct AboutSettingsView: View {
    
    @State var showLicenses = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("txmer version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)\n")
                Text("txmer is licensed under the GNU GPL v3 license, and uses open source projects and libraries.\n\nClick below for more info.")
                Button("Open source licenes") {
                    showLicenses = true
                }
                
                
            }
        }
        
        
        .sheet(isPresented: $showLicenses) {
            LicensesPopUpView(showLicenses: $showLicenses)
            //NewSessionPopUpView()
        }
    }
}
