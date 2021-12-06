//
//  AboutSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI


struct LicensePopUpView: View {
    var body: some View {
        ScrollView {
            GPLLicense()
        }
    }
}


@available(iOS 15.0, *)
struct LicensesPopUpView: View {
    @Environment(\.dismiss) var dismiss
    @State var showLicense = false
    @Binding var showLicenses: Bool
    
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
                    showLicense = true
                }
                Button("ChaoTimer") {
                    showLicense = true
                }
                Button("ChartView") {
                    showLicense = true
                }
                Button("Cubing Icons") {
                    showLicense = true
                }
                Button("Recursive Font") {
                    showLicense = true
                }
                NavigationLink("", destination: LicensePopUpView(), isActive: $showLicense)
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
        Text("txmer version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)\n")
        Text("txmer is licensed under the GPL v3 license, and uses many open soruce projects. Click below for more info\n")
        Button("Open source licenes") {
            showLicenses = true
        }
        .sheet(isPresented: $showLicenses) {
            LicensesPopUpView(showLicenses: $showLicenses)
            //NewSessionPopUpView()
        }
    }
}
