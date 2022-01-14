//
//  Onboarding.swift
//  CubeTime
//
//  Created by Tim Xie on 2/01/22.
//

import SwiftUI
import Foundation

let smallPhone: Bool =  ["iPhone7,2", "iPhone8,1", "iPhone9,1", "iPhone9,3", "iPhone10,1", "iPhone10,4", "iPhone12,8", "iPhone14,4", "iPhone13,1", "x86_64"].contains(UIDevice.modelName)

struct OnboardingView: View {
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var pageIndex: Int
    
    @Namespace var namespaceOB
    
    var body: some View {
        ZStack {
            TabView (selection: $pageIndex) {
                PageOne(pageIndex: $pageIndex).tag(0)
                PageTwo(pageIndex: $pageIndex).tag(1)
                PageThree(pageIndex: $pageIndex).tag(2)
                PageFour(pageIndex: $pageIndex).tag(3)
                PageFive(pageIndex: $pageIndex).tag(4)
                PageSix(pageIndex: $pageIndex).tag(5)
                PageSeven(pageIndex: $pageIndex).tag(6)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                        showOnboarding = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .foregroundStyle(colourScheme == .light ? .black : .white)
                            .padding(.top)
                            .padding(.trailing)
                    }
                }
                
               
                
                Spacer()
            }
            
            if pageIndex == 0 {
                VStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.indigo)
                            .frame(height: 55)
                            .matchedGeometryEffect(id: "button-background", in: namespaceOB)
                            .padding()
                        
                        Text("Take me on a short tour!")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .onTapGesture(perform: {
                        withAnimation(.spring()) {
                            pageIndex += 1
                        }
                    })
                    
                }
            } else if pageIndex == 6 {
                VStack {
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.indigo)
                            .frame(height: 55)
                            .matchedGeometryEffect(id: "button-background", in: namespaceOB)
                            .padding()
                        
                        Text("Get started")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .onTapGesture {
                        dismiss()
                        showOnboarding = false
                    }
                    
                }
            
                } else {
                VStack {
                    Spacer()
                    
                    HStack {
                        HStack (spacing: 10) {
                            ForEach(0..<5, id: \.self) { dot in
                                Circle()
                                    .fill(Color(uiColor: dot == pageIndex-1 ? (colourScheme == .light ? .black : .white) : (colourScheme == .light ? .systemGray : .systemGray3)))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.leading)
                                                
                        Spacer()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.indigo)
                                .frame(width: 55, height: 55)
                                .matchedGeometryEffect(id: "button-background", in: namespaceOB)
                                
                            
                            Image(systemName: "arrow.forward")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .onTapGesture(perform: {
                            withAnimation(.spring()) {
                                pageIndex += 1
                            }
                        })
                    }
                    .padding()
                }
            }
        }
    }
}

struct PageOne: View {
    @Binding var pageIndex: Int
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Welcome")
                    .font(.system(size: 36, weight: .bold))
                    .padding(.top, smallPhone ? 50 : 75)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 0)
                
                HStack {
                    Text("to")
                    Text("CubeTime.")
                        .font(.custom("RecursiveSansLnrSt-Regular", size: 36))
                        .foregroundColor(Color.indigo)
                }
                .font(.system(size: 36, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 0)
                
                Image("PageOne - Icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 110)
                    .padding(.vertical, smallPhone ? 36 : 50)
                    .shadow(color: .black.opacity(0.32), radius: 12, x: 0, y: 2)
                
                
                Text("This app brings your cubing\nutilities together - all in one place.")
                    .font(.system(size: 22, weight: .medium))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct PageTwo: View {
    @Binding var pageIndex: Int
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Timer")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, smallPhone ? 48 : 60)
                    .multilineTextAlignment(.center)
                
                Text("The timer view.")
                    .font(.system(size: 21, weight: .medium))
                    .if(smallPhone) { view in
                        view.padding(.bottom, 18)
                    }
                    .if(!smallPhone) { view in
                        view.padding(.vertical, 24)
                    }
                
                Image("1-timer")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 95)
                
                
                Spacer()
            }
        }
    }
}

struct PageThree: View {
    @Binding var pageIndex: Int
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Gestures")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, smallPhone ? 48 : 60)
                    .multilineTextAlignment(.center)
                
                Text("We feature many intuitive gestures,\nlike the ones shown below:")
                    .font(.system(size: 21, weight: .medium))
                    .multilineTextAlignment(.center)
                    .if(smallPhone) { view in
                        view.padding(.bottom, 18)
                    }
                    .if(!smallPhone) { view in
                        view.padding(.vertical, 24)
                    }
                
                Image("2-gesture")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 50)
                
                
                Spacer()
            }
        }
    }
}

struct PageFour: View {
    @Binding var pageIndex: Int
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Session Times")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, smallPhone ? 48 : 60)
                    .multilineTextAlignment(.center)
                
                Text("All your solves will be shown\nin the solves tab for each session.")
                    .font(.system(size: 21, weight: .medium))
                    .multilineTextAlignment(.center)
                    .if(smallPhone) { view in
                        view.padding(.bottom, 18)
                    }
                    .if(!smallPhone) { view in
                        view.padding(.vertical, 24)
                    }
                
                Image("3-timeslist")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 50)
                
                
                Spacer()
            }
        }
    }
}

struct PageFive: View {
    @Binding var pageIndex: Int
    @Environment(\.colorScheme) var colourScheme
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Statistics")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, smallPhone ? 48 : 60)
                    .multilineTextAlignment(.center)
                
                Text("All your solve statistics are shown\nboth numerically and graphically.")
                    .font(.system(size: 21, weight: .medium))
                    .multilineTextAlignment(.center)
                    .if(smallPhone) { view in
                        view.padding(.bottom, 18)
                    }
                    .if(!smallPhone) { view in
                        view.padding(.vertical, 24)
                    }
                
                Image("4-stats")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 50)
                
                
                Spacer()
            }
        }
    }
}

struct PageSix: View {
    @Binding var pageIndex: Int
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Sessions")
                    .font(.system(size: 32, weight: .bold))
                    .padding(.top, smallPhone ? 48 : 60)
                    .multilineTextAlignment(.center)
                
                Text("We have a variety of session types.\nHere’s a brief overview:")
                    .font(.system(size: 21, weight: .medium))
                    .multilineTextAlignment(.center)
                    .if(!smallPhone) { view in
                        view.padding(.top, 18).padding(.bottom, 8)
                    }
                
                VStack (alignment: .leading, spacing: 28) {
                    HStack {
                        Image(systemName: "timer.square")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(Color.indigo)
                            .frame(width: 50)
                        
                        VStack (alignment: .leading) {
                            Text("Standard")
                                .font(.system(size: 17, weight: .medium))
                            
                            Text("The default normal session. Set to a chosen puzzle type.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                    
                    /*
                    HStack {
                        Image(systemName: "command.square")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(Color.indigo)
                            .frame(width: 50)
                        
                        VStack (alignment: .leading) {
                            Text("Algorithm Trainer")
                                .font(.system(size: 17, weight: .medium))
                            
                            Text("Train yourself on a set of algorithms.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                     */
                    
                    HStack {
                        Image(systemName: "square.stack")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(Color.indigo)
                            .frame(width: 50)
                        
                        VStack (alignment: .leading) {
                            Text("Multiphase")
                                .font(.system(size: 17, weight: .medium))
                            
                            Text("Be able to time phases during a solve. Tap during a solve to record phases.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                    
                    HStack {
                        Image(systemName: "square.on.square")
                            .font(.system(size: 36, weight: .regular))
                            .foregroundColor(Color.indigo)
                            .frame(width: 50)
                        
                        VStack (alignment: .leading) {
                            Text("Playground")
                                .font(.system(size: 17, weight: .medium))
                            
                            Text("A versatile session. You can change the scramble type within the session.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                    
                    HStack {
                        Image(systemName: "globe.asia.australia")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(Color.indigo)
                            .frame(width: 50)
                        
                        VStack (alignment: .leading) {
                            Text("Comp Sim")
                                .font(.system(size: 17, weight: .medium))
                            
                            Text("Record non-rolling averages of 5. Simulates a competition.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                    }
                }
                .frame(maxWidth: UIScreen.screenWidth - 32)
                .padding(.horizontal, 32)
                .padding(.top, 18)
                
                
                
                
                Spacer()
            }
            .safeAreaInset(edge: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 60)
                
            }
        }
    }
}

struct PageSeven: View {
    @Binding var pageIndex: Int
    var body: some View {
        VStack(spacing: 0) {
            Text("Thanks!")
                .font(.system(size: 36, weight: .bold))
                .padding(.top, smallPhone ? 50 : 72)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            

            Text("We hope you enjoy using this app.")
                .font(.system(size: 17, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 36)
            
            Text("This app is brought to you by")
                .font(.system(size: 21, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("[speedcube.co.nz](https://www.speedcube.co.nz/)")
                .font(.system(size: 21, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 48)
            
            Image("speedcube")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180)
            
            Spacer()
            
            
            Text("CubeTime is open-source and GPLv3 licensed.\n")
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(uiColor: .systemGray))
                .padding(.horizontal)
        
            Text("You can view our source code at\nhttps://github.com/CubeStuffs/CubeTime")
                .font(.system(size: 15, weight: .light))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(uiColor: .systemGray))
                .padding(.horizontal)
                .padding(.bottom)
        }
        .safeAreaInset(edge: .bottom) {
            Rectangle()
                .fill(.clear)
                .frame(height: 55)
                .padding(.bottom)
        }
    }
}
