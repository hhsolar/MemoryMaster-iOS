//
//  AvatarFunction.swift
//  MemoryMaster
//
//  Created by apple on 28/10/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()


