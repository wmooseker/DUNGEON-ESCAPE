//
//  LevelSelectViewController.swift
//  DungeonCrawler
//
//  Created by Elliott, Jared Padilla on 12/10/18.
//  Copyright © 2018 Mooseker, William Parker. All rights reserved.
//

import UIKit

class LevelSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "levelOneSegue"  {
                // we want to downcast using as? the destination general UIViewController to a specific subclass SecondViewController
                if let gameVC = segue.destination as? GameViewController {

                    let level = "GameScene"
                    gameVC.level = level
                }
            } else if identifier == "levelTwoSegue" {
                // we want to downcast using as? the destination general UIViewController to a specific subclass SecondViewController
                if let gameVC = segue.destination as? GameViewController {
                    
                    let level = "GameScene2"
                    gameVC.level = level
                }
            } else if identifier == "levelThreeSegue" {
                // we want to downcast using as? the destination general UIViewController to a specific subclass SecondViewController
                if let gameVC = segue.destination as? GameViewController {
                    
                    let level = "GameScene3"
                    gameVC.level = level
                }
            }
        }
    }

}
