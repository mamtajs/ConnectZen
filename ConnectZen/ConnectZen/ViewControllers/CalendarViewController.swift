//
//  CalendarViewController.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/13/20.
//

import UIKit
import EventKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
    }
    func setUpButtons(){
        Utilities.styleFilledButton(yesButton)
        Utilities.styleFilledButton(noButton)
    }
    
    @IBAction func YesTapped(_ sender: Any) {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .authorized:
            insertEvent(store: eventStore)
            loadEvents(store: eventStore)
            case .denied:
                print("Access denied")
            case .notDetermined:
                eventStore.requestAccess(to: .event, completion:
                  {[weak self] (granted: Bool, error: Error?) -> Void in
                      if granted {
                        self!.insertEvent(store: eventStore)
                        self!.loadEvents(store: eventStore)
                      } else {
                            print("Access denied")
                      }
                })
                default:
                    print("Case default")
        }
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "HomeVC") as? HomeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func NoTapped(_ sender: Any) {
        NotificationBanner.show("We cannot check your availabilty or add scheduled events to your calendar without this permission")
    }
    
    func loadEvents(store: EKEventStore){
        let eventstore:EKEventStore = store
        let startDate = Date()
        let weekFromNow = startDate.addingTimeInterval(7 * 24 * 60 * 60)
        let predicate = eventstore.predicateForEvents(withStart: startDate, end: weekFromNow, calendars: nil)
        let events = eventstore.events(matching: predicate)
        for event in events{
            print("Event: \(String(describing: event.title))")
        }
    }
    
    func insertEvent(store: EKEventStore) {
          let event:EKEvent = EKEvent(eventStore: store)
          let startDate = Date()
          // 2 hours
          let endDate = startDate.addingTimeInterval(2 * 60 * 60)
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
