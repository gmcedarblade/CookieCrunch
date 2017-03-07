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
  
  @IBOutlet weak var targetLabel: UILabel!
  
  @IBOutlet weak var movesLabel: UILabel!
  
  @IBOutlet weak var scoreLabel: UILabel!
  
  
  var movesLeft = 0
  var score = 0
  
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
  
    movesLeft = level.maximumMoves
    score = 0
    updateLabels()
    
    level.resetComboMultiplier()
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
      
      scene.animate(swap, completion: handleMatches)
      
    } else {
      
      scene.animateInvalidSwap(swap) {
      
        self.view.isUserInteractionEnabled = true
        
      }
      
    }
    
  }
  
  func handleMatches() {
    
    let chains = level.removeMatches()
    
    if chains.count == 0 {
      
      beginNextTurn()
      
      return
      
    }
    
    scene.animateMatchedCookies(for: chains) {
      
      for chain in chains {
        
        self.score += chain.score
        
      }
      
      self.updateLabels()
      
      let columns = self.level.fillCookies()
      
      self.scene.animateFallingCookies(columns: columns) {
        
        let columns = self.level.topUpCookies()
        
        self.scene.animateNewCookies(columns) {
      

          self.handleMatches()
          
        }
        
      }
      
    }
    
  }
  
  func beginNextTurn() {
    
    level.detectPossibleSwaps()
    level.resetComboMultiplier()
    decrementMoves()
    view.isUserInteractionEnabled = true
    
  }
  
  func decrementMoves() {
    
    movesLeft -= 1
    updateLabels()
    
  }
  
  func updateLabels() {
    
    targetLabel.text = String(format: "%ld", level.targetScore)
    movesLabel.text = String(format: "%ld", movesLeft)
    scoreLabel.text = String(format: "%ld", score)
    
  }
  
}
