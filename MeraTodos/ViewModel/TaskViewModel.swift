//
//  TaskViewModel.swift
//  MeraTodos
//
//  Created by NhatMinh on 21/9/24.
//



import CoreData
import SwiftUI
import UserNotifications


class TaskViewModel : ObservableObject {
    @Published var currentTab : String = "Today"
    
    @Published var openEditTask: Bool = false
    @Published var taskTitle: String = ""
    @Published var taskColor: String = ""
    @Published var taskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
    @Published var showDatePicker: Bool = false
    
    @Published var editTask : Task?
    
    @Published var toggleCardMenu = false
    
    
    func addTask(context:NSManagedObjectContext) -> Bool{
        
        var task:Task!
        if editTask != nil && openEditTask == true {
            task = editTask
        } else {
            task = Task(context: context)
        }
      
        task.title = taskTitle
        task.color = taskColor
        task.deadline = taskDeadline
        task.type = taskType
        task.isCompleted = false
        
        if let _ = try? context.save(){
            return true
        }
        return false
    }
    
    func resetData(){
        taskType = "Basic"
        taskColor = "Purple"
        taskTitle = ""
        taskDeadline = Date()
        openEditTask = false
    }
    
    func setupTask(){
       
            if let editTask = editTask {
                taskType = editTask.type ?? "Basic"
                taskColor = editTask.color ?? "Pink"
                taskTitle = editTask.title ?? ""
                taskDeadline = editTask.deadline ?? Date()
            }
        


    }
    //----------------------------- NOTIFICATION------------------------
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func reloadAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func createLocalNotification(title: String,day:Int, hour: Int, minute: Int, completion: @escaping (Error?) -> Void) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.day = day
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Task Manager"
        notificationContent.sound = .default
        notificationContent.body = title
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
    }
    
    func deleteLocalNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    //--------------------------- NOTIFICATION------------------------

}
