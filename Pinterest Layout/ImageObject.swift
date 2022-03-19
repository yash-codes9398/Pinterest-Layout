//
//  ImageObject.swift
//  Pinterest Layout
//
//  Created by Yash Shah on 13/03/22.
//

import Foundation
import UIKit

public struct ImageObject: Decodable {
    
    public let author: String
    public let width: Int
    public let height: Int
    public let url: String
    public let download_url: String
}
