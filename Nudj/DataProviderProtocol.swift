//
//  DataProviderProtocol.swift
//  Nudj
//
//  Copyright (c) 2015 Nudge I.T. Limited. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol DataProviderProtocol {
    func requestData(page:Int, size:Int, listener:(JSON) -> ())
    func didfinishLoading(count:Int)
    func deleteData(id:Int,listener:(JSON) -> ())
}