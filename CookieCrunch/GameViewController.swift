//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Gregory Cedarblade on 2/21/17.
//  Copyright © 2017 Gregory Cedarblade. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
  
  var scene: GameScene!
  var level: Level!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Configure the view.
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene.
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    scene.swipeHandler = handleSwipe
    
    // Present the scene.
    skView.presentScene(scene)
    
    level = Level(fileName: "Level_1")
    scene.level = level
    scene.addTiles()
    
    beginGame()
  }
  
  func beginGame() {
  
    // shuffling
    shuffle()
  }
  
  func shuffle() {
    
    let newCookies = level.shuffle()
    scene.addSprites(for: newCookies)
    
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    
    return .portrait
    
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  func handleSwipe(swap: Swap) {
    
    view.isUserInteractionEnabled = false
    
    if level.isPossibleSwap(swap) {
     
      level.performSwap(swap: swap)
      
      scene.animate(swap) {
        
        self.view.isUserInteractionEnabled = true
        
      }
      
    } else {
      
      scene.animateInvalidSwap(swap) {
      
        self.view.isUserInteractionEnabled = true
        
      }
      
    }
    
  }
  
}