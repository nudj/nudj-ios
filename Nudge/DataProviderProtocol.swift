//
//  DataProviderProtocol.swift
//  Nudge
//
//  Created by Lachezar Todorov on 12.03.15.
//  Copyright (c) 2015 г. Lachezar Todorov. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol DataProviderProtocol {
    func requestData(page:Int, size:Int, listener:(JSON) -> ())
    func didfinishLoading(count:Int)
}