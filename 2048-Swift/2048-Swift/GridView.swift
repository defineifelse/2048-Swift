//
//  GridView.swift
//  2048-Swift
//
//  Created by Pan on 02/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import UIKit

class GridView: UIView {
    private var dimension: Int
    private var tileWidth: CGFloat
    private let tilePadding: CGFloat = 5.0
    
    private let tileSlideTime: TimeInterval = 0.1
    private let tileExpandTime: TimeInterval = 0.1
    private let tileContractTime: TimeInterval = 0.1
    private let tilePopStartScale: CGFloat = 0.1
    private let tilePopMaxScale: CGFloat = 1.3
    
    private var tileViews: [TileView]

    init(frame: CGRect, dimension d: Int) {
        assert(d > 0)
        dimension = d
        tileWidth = (frame.width - tilePadding * CGFloat(dimension + 1)) / CGFloat(dimension)
        tileViews = [TileView]()
        super.init(frame: frame)
        layer.cornerRadius = Theme.cornerRadius
        backgroundColor = Theme.gridColor()
        setupTileBackground()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetView() {
        let _ = tileViews.map{$0.removeFromSuperview()}
        tileViews.removeAll(keepingCapacity: true)
    }
    
    private func setupTileBackground() {
        var x = tilePadding
        var y: CGFloat
        for _ in 0..<dimension {
            y = tilePadding
            for _ in 0..<dimension {
                let background = UIView(frame: CGRect(x: x, y: y, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = Theme.cornerRadius
                background.backgroundColor = Theme.boardColor()
                addSubview(background)
                y += tilePadding + tileWidth
            }
            x += tilePadding + tileWidth
        }
    }
    
    func performTileActions(actions: [TileAction], completion: (() -> Void)? = nil) {
        
        assert(actions.count>0)
        
        var moves = [(TileView, Position, Position)]()
        var dismissViews = [TileView]()
        var merges = [(Position, Int)]()
        var inserts = [(Position, Int)]()
        
        for action in actions {
            switch action {
            case let .move(from: from, to: to, dismissed: dismissed):
                let tileView = getTileView(at: from)!
                if (from != to) {
                    moves.append((tileView, from, to))
                }
                if (dismissed) {
                    dismissViews.append(tileView)
                }
            case let .merge(at: at, value: value):
                merges.append((at, value))
            case let .insert(at: at, value: value):
                inserts.append((at, value))
            }
        }
        
        moveTiles(moves: moves, completion: {
            //remove tileViews
            for tileView in dismissViews {
                self.tileViews.remove(at: self.tileViews.index(of: tileView)!)
                tileView.removeFromSuperview()
            }
            
            //insert merged tile
            self.insertTiles(inserts: merges, fromMerge: true, completion: {
                //insert new tile
                self.insertTiles(inserts: inserts, fromMerge: false, completion: {
                    completion?()
                })
            })
        })
    }
    
    private func moveTiles(moves: [(TileView, Position, Position)], completion: (() -> Void)? = nil) {
        if moves.count == 0 { completion?(); return }
        
        var completedCount = 0
        for move in moves {
            let (tile, from, to) = move
            moveTile(tileView: tile, from: from, to: to, completion: { (finished) in
                completedCount += 1
                if(completedCount == moves.count) {
                    completion?()
                }
            })
        }
    }
    
    private func insertTiles(inserts: [(Position, Int)], fromMerge: Bool, completion: (() -> Void)? = nil) {
        if inserts.count == 0 { completion?(); return }

        var completedCount = 0
        for insert in inserts {
            let (at, value) = insert
            insertTile(at: at, value: value, fromMerge: fromMerge, completion: { (finished) in
                completedCount += 1
                if(completedCount == inserts.count) {
                    completion?()
                }
            })
        }
    }
    
    private func moveTile(tileView: TileView, from: Position, to: Position, completion: ((Bool) -> Void)? = nil) {
        
        tileView.position = to
        let toFrame = frame(at: to)
        UIView.animate(withDuration: tileSlideTime, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            tileView.frame = toFrame
        }, completion: completion)
    }
    
    private func insertTile(at pos: Position, value: Int, fromMerge: Bool, completion: ((Bool) -> Void)? = nil) {
        
        let tileView = TileView(frame: frame(at: pos), position: pos, value: value)
        tileViews.append(tileView)
        
        if !fromMerge {
            tileView.layer.setAffineTransform(CGAffineTransform(scaleX: tilePopStartScale, y: tilePopStartScale))
        }
        addSubview(tileView)
        bringSubview(toFront: tileView)
        
        let popMaxScale = fromMerge ? self.tilePopMaxScale : 1.0
        UIView.animate(withDuration: tileExpandTime, delay: 0, options: UIViewAnimationOptions(), animations: {
            tileView.layer.setAffineTransform(CGAffineTransform(scaleX: popMaxScale, y: popMaxScale))
        }, completion: { finished in
            UIView.animate(withDuration: self.tileContractTime, animations: {
                tileView.layer.setAffineTransform(CGAffineTransform.identity)
            }, completion: completion)
        })
    }
    
    private func getTileView(at pos: Position) -> TileView? {
        return tileViews.filter{ $0.position == pos }.first
    }
    
    private func frame(at pos: Position) -> CGRect {
        let x = tilePadding + CGFloat(pos.col)*(tileWidth + tilePadding)
        let y = tilePadding + CGFloat(pos.row)*(tileWidth + tilePadding)
        return CGRect(x: x, y: y, width: tileWidth, height: tileWidth)
    }
}
