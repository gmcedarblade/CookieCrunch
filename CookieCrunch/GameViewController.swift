//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Gregory Cedarblade on 2/21/17.
//  Copyright © 2017 Gregory Cedarblade. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class GameViewController: UIViewController {
  
  var scene: GameScene!
  var level: Level!
  
  @IBOutlet weak var targetLabel: UILabel!
  
  @IBOutlet weak var movesLabel: UILabel!
  
  @IBOutlet weak var scoreLabel: UILabel!
  
  @IBOutlet weak var gameOverPanel: UIImageView!
  
  var tapGestureRecognizer: UITapGestureRecognizer!
  
  @IBOutlet weak var shuffleButton: UIButton!
  
  
  var movesLeft = 0
  var score = 0
  var currentLevelNum = 1
  
  lazy var backgroundMusic: AVAudioPlayer? = {
    guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else {
      return nil
    }
    
    do {
      
      let player = try AVAudioPlayer(contentsOf: url)
      player.numberOfLoops = -1
      return player
      
    } catch {
      return nil
    }
  } ()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Setup view with level 1
    setupLevel(levelNum: currentLevelNum)
    
    // Start the background music
    backgroundMusic?.play()
  }
  
  func beginGame() {
  
    movesLeft = level.maximumMoves
    score = 0
    updateLabels()
    
    level.resetComboMultiplier()
    
    scene.animateBeginGame {
    
      self.shuffleButton.isHidden = false
    
    }
    
    // shuffling
    shuffle()
    
  }
  
  func shuffle() {
    
    scene.removeAllCookieSprites()
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
    
    if score >= level.targetScore {
      
      gameOverPanel.image = UIImage(named: "LevelComplete")
      currentLevelNum = currentLevelNum < numLevels ? currentLevelNum+1 : 1
      showGameOver()
      
    } else if movesLeft == 0 {
      
      gameOverPanel.image = UIImage(named: "GameOver")
      showGameOver()
      
    }
    
  }
  
  func updateLabels() {
    
    targetLabel.text = String(format: "%ld", level.targetScore)
    movesLabel.text = String(format: "%ld", movesLeft)
    scoreLabel.text = String(format: "%ld", score)
    
  }
  
  func showGameOver() {
    
    gameOverPanel.isHidden = false
    
    scene.isUserInteractionEnabled = false
    
    shuffleButton.isHidden = true
    
    scene.animateGameOver {
      
      self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
    
      self.view.addGestureRecognizer(self.tapGestureRecognizer)
      
    }
    
    
  }
  
  func hideGameOver() {
    
    view.removeGestureRecognizer(tapGestureRecognizer)
    tapGestureRecognizer = nil
    
    gameOverPanel.isHidden = true
    
    scene.isUserInteractionEnabled = true
    
    setupLevel(levelNum: currentLevelNum)
    
  }
  

  @IBAction func shuffleButtonPressed(_ sender: Any) {
    
    shuffle()
    decrementMoves()
    
  }
  
  func setupLevel(levelNum: Int) {
    
    let skView = view as! SKView
    skView.isMultipleTouchEnabled = false
    
    // Create and configure the scene
    scene = GameScene(size: skView.bounds.size)
    scene.scaleMode = .aspectFill
    
    // Setup the level
    level = Level(fileName: "Level_\(levelNum)")
    scene.level = level
    
    scene.addTiles()
    scene.swipeHandler = handleSwipe
    
    gameOverPanel.isHidden = true
    shuffleButton.isHidden = true
    
    // Present the scene
    skView.presentScene(scene)
    
    // Start the game
    beginGame()
    
  }
  
  
}
