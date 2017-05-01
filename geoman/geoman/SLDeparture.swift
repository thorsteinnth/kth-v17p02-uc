
import Foundation

struct SLDeparture {
    
    enum TransportMode: String {
        case metro, bus, unknown
    }
    
    enum GroupOfLine: String {
        case red, green, blue, unknown
    }
    
    let transportMode: TransportMode
    let station: String
    let line: GroupOfLine
    let destination: String
    let displayTime: String
    let direction: Int
}

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

// Parses JSON and initializes a SLDeparture object
extension SLDeparture {
    
    init?(json: [String: Any]) throws {
        
        guard let station = json["StopAreaName"] as? String else {
            throw SerializationError.missing("station")
        }
        
        guard let transportMode = json["TransportMode"] as? String else {
            throw SerializationError.missing("transportMode")
        }
        
        guard let groupOfLine = json["GroupOfLine"] as? String else {
            throw SerializationError.missing("groupOfLine")
        }
        
        guard let destination = json["Destination"] as? String else {
            throw SerializationError.missing("destination")
        }
        
        guard let displayTime = json["DisplayTime"] as? String else {
            throw SerializationError.missing("displayTime")
        }
        
        guard let direction = json["JourneyDirection"] as? Int else {
            throw SerializationError.missing("direction")
        }
        
        self.station = station
        
        if transportMode == "METRO" {
            self.transportMode = TransportMode.metro
        }
        else if transportMode == "BUS" {
            self.transportMode = TransportMode.bus
        }
        else {
            self.transportMode = TransportMode.unknown
        }
        
        if groupOfLine == "tunnelbanans blå linje" {
            self.line = GroupOfLine.blue
        }
        else if groupOfLine == "tunnelbanans gröna linje" {
            self.line = GroupOfLine.green
        }
        else if groupOfLine == "Tunnelbanans röda linje" {
            self.line = GroupOfLine.red
        }
        else {
            self.line = GroupOfLine.unknown
        }
        
        self.destination = destination
        self.displayTime = displayTime
        self.direction = direction
    }
}
