//
//  Notebook.swift
//  PPT_Process
//
//  Created by BrandonZu on 2019/12/19.
//  Copyright © 2019 DongjueZu. All rights reserved.
//

import UIKit

class Notebook: NSObject {

    //MARK: Properties
    var name: String
    var photos: [UIImage]
    
    //MARK: Initialization
    init(name: String = "") {
        
        // Initialize all the properties
        self.name = name
        self.photos = [UIImage]()
    }
    
    func isEmpty() -> Bool {
        return name == ""
    }
}
