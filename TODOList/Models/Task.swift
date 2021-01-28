//
//  Task.swift
//  TODOList
//
//  Created by Anadea Lukačević on 18/01/2021.
//

import Foundation

enum Priority: Int {
    case high
    case medium
    case low
}

struct Task {
    let title: String
    let priority: Priority
}
