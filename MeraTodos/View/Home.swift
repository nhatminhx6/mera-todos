//
//  Home.swift
//  MeraTodos
//
//  Created by NhatMinh on 21/9/24.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers.UTType

struct Home: View {
    @StateObject var taskModel : TaskViewModel = .init()
    @Namespace var tabAnimation
    @State var isShowingSheet = false
    @AppStorage("loginUsernameKey") var loginUsernameKey = ""
    
    
    @Environment(\.self) var env
    
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath:\Task.deadline, ascending: false)], predicate: nil, animation: .easeInOut)
    var tasks: FetchedResults<Task>
    
    var body: some View {
        ScrollView {
            VStack(alignment:.leading,spacing: 8) {
                
                HStack{
                    Image(systemName: "person.fill")
                    
                        .resizable()
                        .frame(width:40, height: 40)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.7)))
                    Text("Hi, \(loginUsernameKey)")
                        .font(.largeTitle.weight(.semibold))
                        .padding()
                    Spacer()
                    
                    
                }
                
                CustomBar()
                    .padding()
                HStack {
                    Text("Tasks")
                        .font(.title.weight(.bold))
                    Spacer()
                    Button {
                        taskModel.resetData()
                        
                        isShowingSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.system(size: 32.0))
                    }
                    .sheet(isPresented: $isShowingSheet) {
                        AddNewTask()
                            .environmentObject(taskModel)
                    }.onAppear{
                        taskModel.editTask = nil
                        taskModel.requestAuthorization()
                    }
                }
                TaskView()
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    @ViewBuilder
    func CustomBar()->some View{
        let tabs = ["Today","Upcoming","Done"]
        HStack(spacing:10){
            ForEach(tabs,id:\.self){  tab in
                Text(tab)
                
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.vertical,8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(taskModel.currentTab == tab ? .yellow : .gray)
                    .background{
                        if taskModel.currentTab == tab {
                            Capsule()
                                .fill(.black)
                                .matchedGeometryEffect(id: "TAB", in: tabAnimation)
                        }
                    }.contentShape(Capsule())
                    .onTapGesture {
                        withAnimation{taskModel.currentTab = tab}
                    }
                
            }
        }
    }
    
    private func deleteItems2(_ item: Task) {
        if let ndx = tasks.firstIndex(of: item) {
            env.managedObjectContext.delete(tasks[ndx])
            do {
                try env.managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    @ViewBuilder
    func TaskView()->some View{
        LazyVGrid(columns:[GridItem(),GridItem()]){
            DynamicFilteredView(currentTab: taskModel.currentTab){
                (task:Task) in
                TaskRowView(task: task)
            }
        }
 
    }
    
    @ViewBuilder
    func TaskRowView(task:Task)->some View{
        VStack(alignment:.leading, spacing: 20){
            HStack{
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical,5)
                    .padding(.horizontal)
                    .background{
                        Capsule().fill(.white.opacity(0.3))
                    }
                Spacer()
                
                Menu {
                    Button("Edit", action: {
                        print("MERALOG ===>    \(tasks[0].title)   ==> \(task.title)")
                        taskModel.openEditTask = true
                        if taskModel.openEditTask{
                            taskModel.editTask = task
                            
                            
                            taskModel.setupTask()
                            isShowingSheet = true
                        }
                    })
                    Button("Delete", action: {deleteItems2(task)})
                    Button("Cancel", action: {})
                } label: {
                    Image(systemName: "ellipsis.circle")
                    
                        .font(.system(size: 26.0, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.vertical,10)
            HStack(alignment:.bottom,spacing: 0){
                VStack(alignment:.leading,spacing: 10){
                    Label{
                        Text((task.deadline ?? Date()).formatted(date: .long, time:.omitted))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    Label{
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time:.shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }.font(.caption)
                }
                .frame(maxWidth:.infinity,alignment: .leading)
                
                if !task.isCompleted{
                    Button{
                        task.isCompleted.toggle()
                        try? env.managedObjectContext.save()
                    }label: {
                        Circle()
                            .strokeBorder(.black,lineWidth: 1.5)
                            .frame(width:25, height:25)
                            .contentShape(Circle())
                    }
                }
            }
        }.padding()
            .frame(maxWidth:.infinity)
            .background{
                RoundedRectangle(cornerRadius: 12,style: .continuous)
                    .fill(Color(task.color ?? "Pink"))
            }
    }
    
}


struct ReorderableForEach<Content: View, Item: Identifiable & Equatable>: View {
    let items: [Item]
    let content: (Item) -> Content
    let moveAction: (IndexSet, Int) -> Void
    
    // A little hack that is needed in order to make view back opaque
    // if the drag and drop hasn't ever changed the position
    // Without this hack the item remains semi-transparent
    @State private var hasChangedLocation: Bool = false

    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        moveAction: @escaping (IndexSet, Int) -> Void
    ) {
        self.items = items
        self.content = content
        self.moveAction = moveAction
    }
    
    @State private var draggingItem: Item?
    
    var body: some View {
        ForEach(items) { item in
            content(item)
                .overlay(draggingItem == item && hasChangedLocation ? Color.white.opacity(0.8) : Color.clear)
                .onDrag {
                    draggingItem = item
                    return NSItemProvider(object: "\(item.id)" as NSString)
                }
                .onDrop(
                    of: [UTType.text],
                    delegate: DragRelocateDelegate(
                        item: item,
                        listData: items,
                        current: $draggingItem,
                        hasChangedLocation: $hasChangedLocation
                    ) { from, to in
                        withAnimation {
                            moveAction(from, to)
                        }
                    }
                )
        }
    }
}

struct DragRelocateDelegate<Item: Equatable>: DropDelegate {
    let item: Item
    var listData: [Item]
    @Binding var current: Item?
    @Binding var hasChangedLocation: Bool

    var moveAction: (IndexSet, Int) -> Void

    func dropEntered(info: DropInfo) {
        guard item != current, let current = current else { return }
        guard let from = listData.firstIndex(of: current), let to = listData.firstIndex(of: item) else { return }
        
        hasChangedLocation = true

        if listData[to] != current {
            moveAction(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        hasChangedLocation = false
        current = nil
        return true
    }
}


//struct Home_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
