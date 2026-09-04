//
//  ContentView.swift
//  DigioTestAkash
//
//  Created by Akash on 25/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var showUIWrapper = false

        var body: some View {
            NavigationView {
                VStack {
                    if #available(iOS 15.0, *) {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                    }
                    Text("Hello, world!")
                        .onTapGesture {
                            print("Text clicked!")
                            showUIWrapper = true
                        }

                    NavigationLink(isActive: $showUIWrapper) {
                        UIWrapperController(onFinish: { showUIWrapper = false })
//                        UIWrapperController2()
                    } label: {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding()
            }
        }
}

struct UIWrapperController: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyViewController

    var onFinish: () -> Void

    func makeUIViewController(context: Context) -> MyViewController {
        let vc = MyViewController()
        vc.onFinish = onFinish
        return vc
    }

    func updateUIViewController(_ uiViewController: MyViewController, context: Context) {

    }
}

struct UIWrapperController2: UIViewControllerRepresentable {
    typealias UIViewControllerType = DemoWebView
    
    func makeUIViewController(context: Context) -> DemoWebView {
        return DemoWebView()
    }
    
    func updateUIViewController(_ uiViewController: DemoWebView, context: Context) {
        
    }
    
   
    
    
}


