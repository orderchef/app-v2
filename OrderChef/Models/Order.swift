
import Foundation

class Order {
	var id: Int? = nil
	
	var type_id: Int!
	var type: OrderType!
	
	var group_id: Int!
	var group: OrderGroup? = nil
	
	var order_items: [OrderItem] = []
	
	init(){}
	
	init(res: [NSString: AnyObject]) {
		self.parse(res)
	}
	
	func parse(res: [NSString: AnyObject]) {
		self.id = res["id"] as? Int
		self.type_id = res["type_id"] as! Int
		self.group_id = res["group_id"] as! Int
		
		for ot in storage.order_types {
			if ot.id != nil && ot.id! == self.type_id {
				self.type = ot
				break
			}
		}
		
		// self.order_items
		self.getItems({ (err: NSError?) -> Void in
			if err != nil {
				SVProgressHUD.showErrorWithStatus("Err getting items: " + err!.description)
			}
		})
	}
	
	func json() -> [NSString: AnyObject] {
		var json: [NSString: AnyObject] = [:]
		
		if self.id != nil { json["id"] = self.id }
		json["type_id"] = self.type_id
		json["group_id"] = self.group_id
		
		return json
	}
	
	func addItem(item: Item, callback: (err: NSError?, orderItem: OrderItem?) -> Void) {
		doPostRequest(makeRequest("/order/" + String(self.id!) + "/items", "POST"), { (statusCode, data) in
			if statusCode >= 400 {
				return callback(err: makeNetworkError("Cannot add item to order", statusCode), orderItem: nil)
			}
			
			var json: [NSString: AnyObject]? = data as? [NSString: AnyObject]
			var orderItem: OrderItem
			if json == nil {
				return callback(err: NSError(domain: "Unknown Error", code: 440, userInfo: nil), orderItem: nil)
			}
			
			orderItem = OrderItem(res: json!)
			self.order_items.append(orderItem)
			
			callback(err: nil, orderItem: orderItem)
		}, ["order_id": self.id!, "item_id": item.id!])
	}
	
	func getItems(callback: (err: NSError?) -> Void) {
		doRequest(makeRequest("/order/" + String(self.id!) + "/items", nil), { (statusCode, data) in
			if statusCode >= 400 {
				return callback(err: makeNetworkError("Cannot get order items", statusCode))
			}
			
			var json: [[NSString: AnyObject]]? = data as? [[NSString: AnyObject]]
			self.order_items = []
			if json != nil {
				for j in json! {
					self.order_items.append(OrderItem(res: j))
				}
			}
			
			callback(err: nil)
		}, nil)
	}
}
