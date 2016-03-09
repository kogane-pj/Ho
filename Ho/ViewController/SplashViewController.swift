//
//  SplashViewController.swift
//  Ho
//
//  Created by 千葉 俊輝 on 2016/03/05.
//  Copyright © 2016年 Toshiki Chiba. All rights reserved.
//

import UIKit
import LTMorphingLabel

class SplashViewController: UIViewController, LTMorphingLabelDelegate {
    @IBOutlet weak var label: EffectLabel!
    
    var isFinish: Bool = false
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.delegate = self
        self.label.morphingEffect = .Fall
        label.text = "Ho!"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isFinish {
            showView()
        }
    }
    
    private func showView() {
        if UserManager.sharedInstance.isLogin() {
            self.performSegueWithIdentifier(SegueID.showRecordViewFromSplash, sender: nil)
        }
        else {
            self.performSegueWithIdentifier(SegueID.showSignUpViewFromSplash, sender: nil)
        }
    }
    
    // MARK: - LTMorphingLabelDelegate
    func morphingDidComplete(label: LTMorphingLabel) {
        UIView.animateWithDuration(0.5, animations: {
            label.alpha = 0
            }, completion: { finish in
                self.showView()
                self.isFinish = true
        })
    }
}
