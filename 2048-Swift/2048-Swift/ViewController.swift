//
//  ViewController.swift
//  2048-Swift
//
//  Created by Pan on 20/08/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GameProtocol {
    
    var gameType = Global.gameType()
    var dimension = Global.dimension()
    var threshold = Global.threshold(gameType: Global.gameType(), dimension: Global.dimension())
    var difficulty = Global.difficulty()
    
    var bestScore = Global.bestScore()
    
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var socreLabel: UILabel!
    @IBOutlet weak var bestScoreView: UIView!
    @IBOutlet weak var bestSocreLabel: UILabel!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var targetSocreLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var gridView: GridView!
    
    var game: GameModel!
        
    override func viewDidLoad()  {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.backgroundColor()
        
        targetSocreLabel.textColor = Theme.buttonColor()
        targetSocreLabel.font = UIFont(name: Theme.boldFontName, size: 50)
        subTitleLabel.textColor = Theme.buttonColor()
        subTitleLabel.font = UIFont(name: Theme.regularFontName, size: 16)
        
        scoreView.backgroundColor = Theme.scoreBoardColor()
        scoreView.layer.cornerRadius = Theme.cornerRadius
        socreLabel.font = UIFont(name: Theme.regularFontName, size: 20)
        socreLabel.text = "0"
        bestScoreView.backgroundColor = Theme.scoreBoardColor()
        bestScoreView.layer.cornerRadius = Theme.cornerRadius
        bestSocreLabel.font = UIFont(name: Theme.regularFontName, size: 20)
        bestSocreLabel.text = "\(bestScore)"
        
        restartButton.backgroundColor = Theme.buttonColor()
        restartButton.titleLabel?.font = UIFont(name: Theme.boldFontName, size: 16)
        restartButton.layer.cornerRadius = Theme.cornerRadius
        settingButton.backgroundColor = Theme.buttonColor()
        settingButton.titleLabel?.font = UIFont(name: Theme.boldFontName, size: 16)
        settingButton.layer.cornerRadius = Theme.cornerRadius

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if game == nil {
            setupGame()
            return
        }
        
        //if setting has changed
        let _gameType = Global.gameType()
        let _dimension = Global.dimension()
        let _difficulty = Global.difficulty()
        if ((_gameType != gameType) || dimension != _dimension) || (difficulty != _difficulty){
            gameType = _gameType
            dimension = _dimension
            threshold = Global.threshold(gameType: _gameType, dimension: _dimension)
            difficulty = _difficulty
            gridView.removeFromSuperview()
            setupGame()
        }
    }
    
    func setupGame() {
        setupView()
        game = GameModel(gameType: gameType, dimension: dimension, difficulty: difficulty, delegate: self)
        game.start()
    }
    
    func setupView() {
        var horizontalOffset: CGFloat = 20
        if dimension > 4 { horizontalOffset = 5 }
        if dimension < 4 { horizontalOffset = 50 }
        let width = view.frame.width - horizontalOffset * 2.0
        let headViewHeight: CGFloat = 180.0
        let y = (view.frame.height - headViewHeight - width)/2.0 + headViewHeight
        let grid: GridView = GridView(frame: CGRect(x: horizontalOffset, y: y, width: width, height: width), dimension: dimension)
        view.addSubview(grid)
        gridView = grid
        setupSwipeControls()
        
        targetSocreLabel.text = "\(threshold)"
        subTitleLabel.text = "Join the numbers to get to \(threshold)!"
        socreLabel.text = "0"
    }
    
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        gridView.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        gridView.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        gridView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        gridView.addGestureRecognizer(rightSwipe)
    }
    
    // MARK: Actions
    
    @IBAction func restart(_ sender: Any) {
        gridView.resetView()
        game.reset()
        game.start()
        threshold = Global.threshold(gameType: gameType, dimension: dimension)
    }
    
    func handleSwipe(_ swipe: UISwipeGestureRecognizer!) {
        var direction: MoveDirection = .left
        switch swipe.direction {
        case UISwipeGestureRecognizerDirection.right:
            direction = .right
        case UISwipeGestureRecognizerDirection.up:
            direction = .up
        case UISwipeGestureRecognizerDirection.down:
            direction = .down
        default:
            break
        }
        
        game.moveTiles(direction: direction)
    }

    // MARK: GameModelProtocol
    
    func scoreDidChange(game: GameModel, score: Int) {
        socreLabel.text = "\(score)"
        
        if score > bestScore {
            bestScore = score
            bestSocreLabel.text = "\(score)"
            Global.saveBestScore(score: score)
        }
    }
    
    func tilesDidChange(game: GameModel, actions: [TileAction]) {
        gridView.isUserInteractionEnabled = false
        gridView.performTileActions(actions: actions, completion: {
            self.gridView.isUserInteractionEnabled = true
        })
    }
    
    func gameDidGetNumber(game: GameModel, number: Int) {
        guard number > threshold else { return }
        
        let alert = UIAlertController(title: "Win", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (action) in
            self.restart(self.restartButton)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.threshold = Int.max
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func gameDidOver(game: GameModel) {
        let alert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (action) in
            self.restart(self.restartButton)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

