//
//  MemeDetailViewController.swift
//  MemeMe 1.0
//
//  Created by Ondrej Winter on 01/10/2020.
//  Copyright © 2020 Levit8. All rights reserved.
//

import Foundation
import UIKit

class MemeDetailViewController: UIViewController {
    
    var memes: Meme!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        detailImageView.image = memes.memedImage
        detailImageView.contentMode = .scaleAspectFit
    }
    
    
}
