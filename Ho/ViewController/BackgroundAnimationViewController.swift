//
//  BackgroundAnimationViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import pop
import LTMorphingLabel

private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1

class BackgroundAnimationViewController: UIViewController, LTMorphingLabelDelegate {

    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var titleLabel: EffectLabel!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.titleLabel.delegate = self
        self.titleLabel.morphingEffect = .Evaporate
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.changeText(self)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
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

    var textArray = [
        "Say Ho!",
        "Ho!",
        "Say Ho-o!",
        "Ho-o!",
        "Say Ho Ho Ho!",
        "Ho Ho Ho!"
    ]
    
    var i = 0
    
    var text:String {
        get {
            if i >= textArray.count {
                i = 0
            }
            return textArray[i++]
        }
    }
}

extension BackgroundAnimationViewController {
    func changeText(sender: AnyObject) {
        self.titleLabel.text = text
    }
}

//MARK: KolodaViewDelegate
extension BackgroundAnimationViewController: KolodaViewDelegate {
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        kolodaView.resetCurrentCardNumber()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
    }
    
    func koloda(kolodaShouldApplyAppearAnimation koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaShouldMoveBackgroundCard koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(kolodaShouldTransparentizeNextCard koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

//MARK: KolodaViewDataSource
extension BackgroundAnimationViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(koloda: Koloda.KolodaView) -> UInt {
        return numberOfCards
    }
    
    func kolodaViewForCardAtIndex(koloda: Koloda.KolodaView, index: UInt) -> UIView {
        return UIImageView(image: UIImage(named: "cards_\(index + 1)"))
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: Koloda.KolodaView, index: UInt) -> Koloda.OverlayView? {
        return nil//NSBundle.mainBundle().loadNibNamed("CustomOverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}
