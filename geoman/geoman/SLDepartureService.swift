
import Foundation

class SLDepartureService {
    
    static func getSLDepartures(stationCode: String, completion: @escaping ([SLDeparture]) -> Void) {
        
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
