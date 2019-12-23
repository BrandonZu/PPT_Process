//
//  Notebook.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit
import os.log

class Notebook: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String
    var notes: [UIImage]
    
    //MARK: Archiving Paths
    
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let notes = "notes"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(notes, forKey: PropertyKey.notes)
    }

    //MARK: Initializer
    
    init(name: String = "", notes: [UIImage] = []) {
        
        // Initialize all the properties
        self.name = name
        self.notes = notes
    }
    
    required convenience init?(coder: NSCoder) {
        
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Notebook Object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let notes = coder.decodeObject(forKey: PropertyKey.notes) as? [UIImage] else {
            os_log("Unable to decode the name for a Notebook Object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name)
    }

    func isEmpty() -> Bool {
        return name == ""
    }
}
