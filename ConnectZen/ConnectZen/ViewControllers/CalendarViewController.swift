//
//  CalendarViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/13/20.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {

    
    @IBOutlet weak var noCalendarAccessButton: UIButton!
    @IBOutlet weak var calendarAccessGrantedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
    }
    //To hide navigation bar in a particular view controller
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func setUpButtons(){
        Utilities.styleFilledButton(noCalendarAccessButton, cornerRadius: largeCornerRadius)
        Utilities.styleFilledButton(calendarAccessGrantedButton, cornerRadius: largeCornerRadius)
    }
    
    @IBAction func calendarAccessGranted(_ sender: Any) {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            var startdate = getDate(day: 28, nextMonth: 11, year: 2020, hour: 00, minute:00)
            var enddate = getDate(day: 29, nextMonth: 11, year: 2020, hour: 00, minute:00)
            //insertEvent(store: eventStore)
            loadEvents(store: eventStore, startDate: startdate, endDate: enddate)
            
            //exit(20)
            case .denied:
                print("Access denied")
            case .notDetermined:
                eventStore.requestAccess(to: .event, completion:
                  {[weak self] (granted: Bool, error: Error?) -> Void in
                      if granted {
                        self?.insertEvent(store: eventStore)
                        //self!.loadEvents(store: eventStore)
                      } else {
                            print("Access denied")
                      }
                })
                default:
                    print("Case default")
        }

        navigateToTabBar()
    }
    
    @IBAction func noCalendarAccess(_ sender: Any) {
        NotificationBanner.successShow("Calendar access not given. You can change this later in notification settings.")
        navigateToTabBar()
    }
   
    
    func getHourMinuteOfEvent(date: Date) -> [Int]{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = TimeZone(identifier: "PST")
            
            //print(dateFormatter.string(from: date))
            let pstDate = dateFormatter.date(from: dateFormatter.string(from: date))
            print(pstDate)
            
        let hour = Calendar.current.component(.hour, from: pstDate!)
            let minute = Calendar.current.component(.minute, from: pstDate!)
            print(hour, minute)
            return [hour, minute]
        }
    
    
    func getDate(day: Int, nextMonth: Int, year: Int, hour: Int, minute: Int) -> Date{
            let calendar = Calendar.current

            var components = DateComponents()

            components.day = day
            components.month = nextMonth
            components.year = year
        components.hour = hour
        components.minute = minute
            return calendar.date(from: components)!
            
        }
    
    func loadEvents(store: EKEventStore, startDate: Date, endDate: Date){
        let eventstore:EKEventStore = store
        //let weekFromNow = startDate.addingTimeInterval(7 * 24 * 60 * 60)
        let predicate = eventstore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventstore.events(matching: predicate)
        for event in events{
            getHourMinuteOfEvent(date: event.startDate)
            print("Event: \(String(describing: event.title)) , \(String(describing: event.startDate)), \(String(describing: event.timeZone))")
            
            
        }
        
        print(type(of: events))
    }
    
    func insertEvent(store: EKEventStore) {
        let components = DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "PST"), year: 2020, month: 11, day: 1)
        print(components.date)
          let event:EKEvent = EKEvent(eventStore: store)
        let startDate = components.date
            //Date()
          // 2 hours
        let endDate = startDate!.addingTimeInterval(2 * 60 * 60)
          event.title = "Meeting with friends"
          event.startDate = startDate
          event.endDate = endDate
          event.notes = "This is a note"
          event.calendar = store.defaultCalendarForNewEvents
    
          do {
              try store.save(event, span: .thisEvent)
          } catch let error as NSError {
          print("failed to save event with error : \(error)")
          }
          print("Saved Event")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
