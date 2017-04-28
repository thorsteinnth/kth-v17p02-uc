
import Foundation

struct SLDeparture {
    
    enum TransportMode: String {
        case metro, bus
    }
    
    enum GroupOfLine: String {
        case green, blue
    }
    
    let transportMode: TransportMode
    let station: String
    let line: GroupOfLine
    let destination: String
    let displayTime: String
    let direction: Int
}

// Parses JSON
extension SLDeparture {
    
    init?(json: [String: Any]) {
        
        
        
        
        self.transportMode = TransportMode.metro
        self.station = "Kista"
        self.line = GroupOfLine.blue
        self.destination = "Kungsträdgården"
        self.displayTime = "2 min"
        self.direction = 2
    }
}

// Send SL API Request and returns list of departures
extension SLDeparture {
    
    static func getDepartures(station: String, completion: ([SLDeparture]) -> Void) {
        
        let urlEndpoint = "https://api.sl.se/api2/realtimedeparturesV4.json?key=9359c8fdf04d4954943cba911ed09428&siteid=9302&timewindow=20"
        
        guard let url = URL(string: urlEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest){
            (data, response, error) in
            
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

                print("The JSON is: " + json.description)
                
                guard let statusCode = json["StatusCode"] as? String else {
                    print("Could not get StatusCode from JSON")
                    return
                }
                print("The StatusCode is: " + statusCode)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            
        }
        task.resume()
        
        
        /*
        session.dataTask(url: searchURL, completion: { (_, _, data, _)
            
            var departures: [SLDeparture] = []
            
            if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                //TODO : loop through "ResponseData" -> then loop through "Metros" and "Buses"
                
                for case let result in json["Metros"] {
                    if let departure = SLDeparture(json: result) {
                        departures.append(departure)
                    }
                }
            }
            
            completion(departures)
        }).resume()
        */
    }
}

