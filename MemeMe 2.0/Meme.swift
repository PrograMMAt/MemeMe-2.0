//
//  Meme.swift
//  MemeMe 1.0
//
//  Created by Ondrej Winter on 29/09/2020.
//  Copyright © 2020 Levit8. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String? = ""
    var bottomText: String? = ""
    var originalImage: UIImage? = nil
    var memedImage: UIImage? = nil
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
