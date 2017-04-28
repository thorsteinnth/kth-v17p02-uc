
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

// Parses JSON
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

// Sends SL API Real Time Departures Request and returns list of departures
extension SLDeparture {
    
    static func getDepartures(stationCode: String, completion: @escaping ([SLDeparture]) -> Void) {
        
        let urlEndpoint = "https://api.sl.se/api2/realtimedeparturesV4.json?key=9359c8fdf04d4954943cba911ed09428&siteid=" + stationCode + "&timewindow=20"
        
        guard let url = URL(string: urlEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        var departures: [SLDeparture] = []
        
        let task = session.dataTask(with: urlRequest)
            {(data, response, error) in
            
            guard error == nil else {
                print("error getting data from SL")
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data from SL")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }

                //print("The JSON is: " + json.description)
                
                guard let statusCode = json["StatusCode"] as? Int else {
                    print("Could not get StatusCode from JSON")
                    return
                }
                
                if(statusCode == 0) {
                    
                    guard let responseData = json["ResponseData"] as? [String: Any] else {
                        print("Could not get response data")
                        return
                    }
                    
                    
                    guard let metros = responseData["Metros"] as? [[String: Any]] else {
                        print("error")
                        return
                    }
                    
                    for metro in metros {
                        
                        do {
                            if let departure = try SLDeparture(json: metro) {
                                departures.append(departure)
                            }
                        } catch {
                            print("Error parsing departure")
                        }
                    }
                }
                
                completion(departures)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
}

