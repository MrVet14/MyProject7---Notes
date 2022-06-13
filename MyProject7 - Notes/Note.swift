//
//  Note.swift
//  MyProject7 - Notes
//
//  Created by Vitali Vyucheiski on 5/18/22.
//

import UIKit

class Note: NSObject, Codable {
    var title: String = ""
    var body: String = ""
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}
