
import Foundation

class OrderType {
	var id: Int? = nil
	var name: String = ""
	var description: String = ""
	
	init(){}
	init(res: [NSString: AnyObject]) {
		self.parse(res)
	}
	
	func parse (res: [NSString: AnyObject]) {
		self.id = res["id"] as? Int
		self.name = res["name"] as! String
		self.description = res["description"] as! String
	}
	
	func json() -> [NSObject: AnyObject] {
		var json: [NSObject: AnyObject] = [:]
		
		if self.id != nil { json["id"] = self.id }
		json["name"] = self.name
		json["description"] = self.description
		
		return json
	}
	
	func save(callback: (err: NSError?) -> Void) {
		var url = "/config/order-types"
		if self.id != nil {
			url = "/config/order-type/" + String(self.id!)
		}
		
		doPostRequest(makeRequest(url, self.id == nil ? "POST" : "PUT"), { (statusCode: Int, data: AnyObject?) -> Void in
			if statusCode >= 400 {
				return callback(err: makeNetworkError("cannot save order type", statusCode))
			}
			
			var json: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			if json != nil {
				self.parse(json!)
			}
			
			callback(err: nil)
		}, self.json())
	}
	
	func remove(callback: (statusCode: Int) -> Void) {
		doRequest(makeRequest("/config/order-type/" + String(self.id!), "DELETE"), { (statusCode: Int, data: AnyObject?) -> Void in
			callback(statusCode: statusCode)
		}, nil)
	}
	
	class func getAll(callback: (err: NSError?, list: [OrderType]) -> Void) {
		doRequest(makeRequest("/config/order-types", "GET"), { (statusCode: Int, data: AnyObject?) -> Void in
			if statusCode >= 400 {
				return callback(err: makeNetworkError("Cannot get order types", statusCode), list: [])
			}
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			var lists: [OrderType] = []
			if json != nil {
				for j in json! {
					lists.append(OrderType(res: j))
				}
			}
			
			callback(err: nil, list: lists)
		}, nil)
	}
}
