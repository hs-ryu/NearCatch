//
//  HomeView.swift
//  NearCatch
//
//  Created by Wonhyuk Choi on 2022/06/09.
//

import SwiftUI

struct HomeView: View {
    let localNetAuth = LocalNetworkAuthorization()
    @StateObject var niObject = NISessionManager()
    @State var isLocalNetworkPermissionDenied = false
    @Environment(\.scenePhase) var scenePhase
    
    @State var isLaunched = true
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationView{
            ZStack {
                Image("img_background")
                    .resizable()
                    .ignoresSafeArea()
                
                LottieView(jsonName: "Background")
                    .ignoresSafeArea(.all)
                
                if isLocalNetworkPermissionDenied || niObject.isPermissionDenied {
                    PermissionCheckView()
                } else {
                    ZStack {
                        VStack {
                            Spacer()
                                .frame(height:475)
                            ZStack {
                                if niObject.gameState != .ready {
                                    TipChange()
                                        .transition(.move(edge: .bottom))
                                }
                            }
                        }
                        
                        VStack {
                            Spacer()
                                .frame(height: 120 + 54)
                            
                            switch niObject.gameState {
                            case .ready:
                                Text("니어캣을 눌러서\n새로운 인연을 찾아보세요!")
                                    .font(.custom("온글잎 의연체", size: 28))
                                    .multilineTextAlignment(.center)
                            case .finding:
                                StarBubble(count: niObject.peersCnt)
                            case .found:
                                HeartBubble()
                            }
                        }
                    }
                }
                
                HomeMainButton(state: $niObject.gameState) {
                    withAnimation {
                        switch niObject.gameState {
                        case .ready:
                            niObject.start()
                            niObject.gameState = .finding
                            if isLaunched {
                                localNetAuth.requestAuthorization { auth in
                                    isLocalNetworkPermissionDenied = !auth
                                }
                                isLaunched = false
                            }
                        case .finding:
                            niObject.stop()
                            niObject.gameState = .ready
                        case .found:
                            niObject.stop()
                            niObject.gameState = .ready
                        }
                    }
                }
            }
            .toolbar{
                ToolbarItemGroup(placement:.navigationBarTrailing) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image("icn_person")
                            .resizable()
                            .frame(width:35*1.2, height:35*1.2)
                    }
                    .offset(
                        x : niObject.gameState == .ready ? 0 : 100,
                        y : niObject.gameState == .ready ? 0 : -100
                    )
                }
            }
        }
        .onChange(of: scenePhase) { newValue in
            if !isLaunched {
                localNetAuth.requestAuthorization { auth in
                    isLocalNetworkPermissionDenied = !auth
                }
            }
        }
        .customSheet(isPresented: $niObject.isBumped, dismiss: {
            niObject.gameState = .ready
            niObject.stop()
        }) {
            Match(imageData: niObject.bumpedImage, nickName: niObject.bumpedName, keywords: niObject.bumpedKeywords)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
