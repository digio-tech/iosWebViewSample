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
            }
            .padding()
            .sheet(isPresented: $showUIWrapper) {
//                UIWrapperController()
                UIWrapperController2()
            }
        }
}

struct UIWrapperController: UIViewControllerRepresentable {
    typealias UIViewControllerType = MyViewController
    
    func makeUIViewController(context: Context) -> MyViewController {
        return MyViewController()
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


