//
//  EventLogger.swift
//  EventLogger
//
//  Created by Zef Houssney on 4/9/15.
//

import Foundation

struct EventLogger {

    enum EventType: String {
        case Expected = ""
        case Error = "error"
    }

    struct Event {
        let description: String
        var type: EventType?
        let time = NSDate()

        func offsetSince(startTime: NSDate) -> NSTimeInterval {
            return time.timeIntervalSinceDate(startTime)
        }

        func dictionaryValue() -> [String : String] {
            return [
                "message" : description,
                "type" : type?.rawValue ?? "",
                "time" : time.description,
            ]
        }

        func stringValue() -> String {
            let noticeType: String
            if let typeValue = type?.rawValue {
                noticeType = typeValue.isEmpty ? "" : "[\(typeValue)] "
            } else {
                noticeType = ""
            }

            return "\(noticeType)\(description)"
        }
    }

    var name: String
    var events = [Event]()
    let creationTime = NSDate()

    init (name: String) {
        self.name = name
    }

    mutating func addEvent(description: String, type: EventType = .Expected) {
        let event = Event(description: description, type: type)
        events.append(event)
    }

    func stringValue() -> String {
        let strings = events.map { event -> String in
            let time = EventLogger.formatTime(event.offsetSince(self.creationTime))
            return "\(time): \(event.stringValue())"
        }
        return join("\n", strings)
    }

    func jsonValue() -> String {
        let eventList = events.map { event -> [String : String] in
            var dict = event.dictionaryValue()
            dict["offset"] = EventLogger.formatTime(event.offsetSince(self.creationTime))
            return dict
        }

        let data = NSJSONSerialization.dataWithJSONObject(eventList, options: .PrettyPrinted, error: nil)
        return NSString(data: data!, encoding: NSUTF8StringEncoding)! as String
    }

    static func formatTime(totalSeconds: Double) -> String {
        let remainder = totalSeconds % 1
        let seconds = totalSeconds % 60
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / (60 * 60)
        let subSeconds = (round(remainder * 100) / 100) * 100
        let string = String(format: "%1d:%02d:%02d.%02d", Int(hours), Int(minutes), Int(seconds), Int(subSeconds))

        var startIndex = string.startIndex
        var indexOfDesiredChar: String.Index?

        while indexOfDesiredChar == nil {
            let char = string[startIndex]
            if char == "0" || char == ":" {
                startIndex = startIndex.successor()
            } else if char == "." {
                indexOfDesiredChar = startIndex.predecessor()
            } else {
                indexOfDesiredChar = startIndex
            }
        }

        return string.substringFromIndex(indexOfDesiredChar!)
    }

}
