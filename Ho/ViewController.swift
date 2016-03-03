//
//  ViewController.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/03.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: UInt = 5

class ViewController: UIViewController {
    @IBOutlet weak var kolodaView: KolodaView!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
}

//MARK: KolodaViewDelegate
extension ViewController: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        //Example: loading more cards
        if index >= 3 {
            numberOfCards = 6
            kolodaView.reloadData()
        }
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        kolodaView.resetCurrentCardNumber()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
}

//MARK: KolodaViewDataSource
extension ViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(koloda: Koloda.KolodaView) -> UInt {
        return numberOfCards
    }
    
    func kolodaViewForCardAtIndex(koloda: Koloda.KolodaView, index: UInt) -> UIView {
        return UIImageView(image: UIImage(named: "Card_like_\(index + 1)"))
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: Koloda.KolodaView, index: UInt) -> Koloda.OverlayView? {
        return nil//NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}