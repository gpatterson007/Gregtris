//
//  GameViewController.swift
//  Gregtris
//
//  Created by Greg Patterson on 2/18/16.
//  Copyright (c) 2016 Greg Patterson. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GregtrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene!
    var gregtris:Gregtris!
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Configure the view.
            let skView = view as! SKView
            skView.isMultipleTouchEnabled = false
            
            // Create and configure the scene.
            scene = GameScene(size: skView.bounds.size)
            scene.scaleMode = .aspectFill
        
            scene.tick = didTick
        
            gregtris = Gregtris()
            gregtris.delegate = self
            gregtris.beginGame()
            
            // Present the scene.
            skView.presentScene(scene)
        
              }
    
    
    @IBAction func didSwip(_ sender: UISwipeGestureRecognizer) {
        gregtris.dropShape()
    }
    
    // #5
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // #6
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            // #3
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                // #4
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    gregtris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    gregtris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        gregtris.rotateShape()
    }
    func didTick() {
        gregtris.letShapeFall()
    }
    func nextShape() {
        let newShapes = gregtris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
        self.scene.movePreviewShape(fallingShape) {
            // #16
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(_ gregtris: Gregtris) {
        levelLabel.text = "\(gregtris.level)"
        scoreLabel.text = "\(gregtris.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        // The following is false when restarting a new game
        if gregtris.nextShape != nil && gregtris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(gregtris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(_ gregtris: Gregtris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(gregtris.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            gregtris.beginGame()
        }
    }
    
    func gameDidLevelUp(_ gregtris: Gregtris) {
        levelLabel.text = "\(gregtris.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
        
    }
    
    func gameShapeDidDrop(_ gregtris: Gregtris) {
        scene.stopTicking()
        scene.redrawShape(gregtris.fallingShape!) {
            gregtris.letShapeFall()
        }
        scene.playSound("Sounds/drop.mp3")
        
    }
    
    func gameShapeDidLand(_ gregtris: Gregtris) {
        scene.stopTicking()
        self.view.isUserInteractionEnabled = false
        // #10
        let removedLines = gregtris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(gregtris.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(gregtris)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    
    // #17
    func gameShapeDidMove(_ gregtris: Gregtris) {
        scene.redrawShape(gregtris.fallingShape!) {}
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

}
