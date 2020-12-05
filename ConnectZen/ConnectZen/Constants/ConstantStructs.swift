//
//  ConstantStructs.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/29/20.
//

import Foundation

struct Person {
    var contactName:String
    var PhoneNumber:String
    //var Email:String
   // var ID:String
}

struct PrefDayTime {
    var Day:String
    var StartTime:String
    var EndTime:String
}

struct Event{
    var TimeStamp:Int
    var Day:String
    var Date:String
    var StartTime:String
    var EndTime:String
    var FriendName:String
    var FriendPhoneNumber:String
    var FriendEmail:String
    var FriendID:String
    var MeetupHappened:Bool
}
