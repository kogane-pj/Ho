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

class BackgroundAnimationViewController: UIViewController {

    @IBOutlet weak var kolodaView: CustomKolodaView!
    @IBOutlet weak var titleLabel: EffectLabel!
    
    var userList: [RecommendUser] = []
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        MatchManager.sharedInstance.delegate = self
        MatchManager.sharedInstance.setup()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Private
    private func setupView() {
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        self.titleLabel.delegate = self
        self.titleLabel.morphingEffect = .Evaporate
    }
    
    //MARK: - IBActions
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

extension BackgroundAnimationViewController: LTMorphingLabelDelegate {
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
    
    func kolodaDidSwipedCardAtIndex(koloda: Koloda.KolodaView, index: UInt, direction: Koloda.SwipeResultDirection) {
        
        if UInt(self.userList.count) > index {
            
            switch direction {
            case .Left:
                MatchManager.sharedInstance.setLikeUser(self.userList[Int(index)], direction: .Left)
                break
            case .Right:
                let isMatch = MatchManager.sharedInstance.setLikeUser(self.userList[Int(index)], direction: .Right)
                print(isMatch)
                break
            case .None:
                break
            }
            
            self.changeText(self)
        }
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
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
        return UInt(self.userList.count)
    }
    
    func kolodaViewForCardAtIndex(koloda: Koloda.KolodaView, index: UInt) -> UIView {
        let view = UIView()
        view.backgroundColor = Color.HoCardColor
        return view //UIImageView(image: UIImage(named: "cards_\(index + 1)"))
    }
    
    func kolodaViewForCardOverlayAtIndex(koloda: Koloda.KolodaView, index: UInt) -> Koloda.OverlayView? {
        let view = OverlayView()
        view.backgroundColor = UIColor.redColor()
        return view //NSBundle.mainBundle().loadNibNamed("CustomOverlayView", owner: self, options: nil)[0] as? OverlayView
    }
}

//MARK: MatchManagerDelegate
extension BackgroundAnimationViewController: MatchManagerDelegate {
    func didLoadUserData() {
        self.userList = MatchManager.sharedInstance.getRecommendUser()
        self.kolodaView.reloadData()
    }
}
