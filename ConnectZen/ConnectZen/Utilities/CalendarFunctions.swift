//
//  CalenderFuctions.swift
//  ConnectZen
//
//  Created by Mamta Shah on 12/9/20.
//

import Foundation
import EventKit
import EventKitUI
import FirebaseAuth
import Firebase

class CalendarFunctions{
    let db = Firestore.firestore()
    
    func createAndInsertEvent(store: EKEventStore, startDate: Date, durationInMinutes: Int, eventTitle: String, eventNotes: String) -> String? {
        
        // Create Event
        let event:EKEvent = EKEvent(eventStore: store)
        
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(Double(durationInMinutes) * 60)
        event.title =  eventTitle
        event.notes = eventNotes
        event.calendar = store.defaultCalendarForNewEvents
        
        // Store Event
        do {
            let reminder = EKAlarm(relativeOffset: -600)
            event.addAlarm(reminder)
            
            try store.save(event, span: .thisEvent)
            print("Saved Event")
            // Adding an Alert 10 minutes before the startDate
            
            return event.eventIdentifier
        }
        catch let error as NSError {
            print("failed to save event with error : \(error)")
        }
        
        return "Nil"
    }
    
    func removeCalendarEvent(store: EKEventStore, withIdentifier identifier: String){
        let eventToRemove = store.event(withIdentifier: identifier)
            if eventToRemove != nil {
                do {
                    try store.remove(eventToRemove!, span: .thisEvent, commit: true)
                } catch {
                    // Display error to user
                }
            }
    }
    
    func getAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    func getDateTime(Day:Int, Month:Int, Year:Int, Hour:Int, Minute:Int) -> Date{
        //let components = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "PST"), year: Year, month: Month, day: Day, hour: Hour, minute: Minute)
        let components = DateComponents(calendar: Calendar.current, year: Year, month: Month, day: Day, hour: Hour, minute: Minute)
        //print(components.date!)
        
        return components.date!
    }
    
    func createCalendarEvent(store: EKEventStore, date: Date, HourMin: Array<Int>, durationOfMeetup: Int, friendName: String) -> String?{
        let curDate:Int  = Calendar.current.component(.day, from: date)
        let curMonth:Int = Calendar.current.component(.month, from: date)
        let curYear:Int = Calendar.current.component(.year, from: date)
        
        let startDate:Date = self.getDateTime(Day: curDate, Month: curMonth, Year: curYear, Hour: HourMin[0], Minute: HourMin[1])
        
        return self.createAndInsertEvent(store: store, startDate: startDate, durationInMinutes: durationOfMeetup, eventTitle: "Connect with \(friendName)", eventNotes: "")
    }
    
    func getCalendarAccess(eventStore: EKEventStore) -> Bool{
        var status: Bool = false
        eventStore.requestAccess(to: .event, completion:
                                    {[weak self] (granted: Bool, error: Error?) -> Void in
                                        if granted {
                                            status = true
                                        }
                                    })
        return status
    }
    
    func checkCalendarAccess() -> Bool{
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            return true
        default:
            return false
            
        }
        
    }

    func getDateFromString(dateString: String, dateFormat: String) -> Date{
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from:dateString)!
    }
}
