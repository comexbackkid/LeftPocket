//
//  ImageHandler.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 1/24/25.
//

import Foundation
import SwiftUI

struct ImageLoader {
    static func loadImage(from path: String) -> UIImage? {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("LocationImages").appendingPathComponent(path)
        return UIImage(contentsOfFile: fileURL.path)
    }
}
