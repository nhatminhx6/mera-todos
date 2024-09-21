//
//  ContentView.swift
//  MeraTodos
//
//  Created by NhatMinh on 21/9/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("loginUsernameKey") var loginUsernameKey = ""
    @AppStorage("isLoggedIn") var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            Home()
        } else {
            GetUsernameView()
        }
        
//            Home()
//            .navigationBarTitle("Task Manager")
//            .navigationBarTitleDisplayMode(.inline)
    }
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
