//
//  SelectionModeViewController.swift
//  Vocable
//
//  Created by Thomas Shealy on 3/19/20.
//  Copyright © 2020 WillowTree. All rights reserved.
//

import UIKit

class SelectionModeViewController: UIViewController {
    @IBOutlet var backButton: GazeableButton!
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
     }
    
}
