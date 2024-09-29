//
//  FilteredCustomBarView.swift
//  MeraTodos
//
//  Created by NhatMinh on 21/9/24.
//


import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    
    //MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    //MARK: Building Custom ForEach which will give Coredata object to build View
    init(currentTab: String, @ViewBuilder content: @escaping (T)->Content) {
        
        //MARK: Predicate to Filter current date Tasks
        let calendar = Calendar.current
        var predicate: NSPredicate!
        
        if currentTab == "Today" {
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            let filterKey = "deadline"
        
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else if currentTab == "Upcoming" {
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let tomorrow = Date.distantFuture
            
            let filterKey = "deadline"

            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        }
        else if currentTab == "Done"{
            
            let past = Date.distantPast
            let tomorrow = Date.distantFuture
            let filterKey = "deadline"

            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past, tomorrow, 1])

        }
        else {

            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
            
        }
        
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: predicate)
        self.content = content
        
    }
    
    var body: some View {
        
        Group{
            if request.isEmpty {
                Text("No tasks found!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(x: 90)
                
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                    let _ = print("MERALOG  =======>   \(request.count)")
                }
            }
            
        }
        
    }
}

