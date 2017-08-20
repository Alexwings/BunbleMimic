//
//  ViewController.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/2/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import UIKit
import QuartzCore

enum CellTypes: String {
    case imageCell = "imageCell"
}

enum CardZPosition: CGFloat {
    case back = 0, front = 1
}

class MainViewController: UIViewController {
    
    var frontView: CardView = CardView(frame: .zero)
    
    let cardViewModel = CardViewModel()
    
    var backView: CardView = CardView(frame: .zero)
    
    var currentDisplayView: CardView? {
        didSet {
            guard currentDisplayView != oldValue, let display = currentDisplayView else { return }
            let back = self.cardView(under: display)
            display.alpha = 1
            display.functionEnabled = true
            back.functionEnabled = false
            display.layer.zPosition = CardZPosition.front.rawValue
            back.layer.zPosition = CardZPosition.back.rawValue
        }
    }
    
    //MARK: Controller Life Cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        setupViews()
        currentDisplayView = frontView
    }

    private func setupLayouts() {
        
        view.addSubview(backView)
        backView.collectionView.backgroundColor = UIColor.blue
        
        backView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: GlobalVariables.CardViewIntervals.top.rawValue).isActive = true
        backView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        backView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        backView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: GlobalVariables.CardViewIntervals.bottom.rawValue).isActive = true
        
        view.addSubview(frontView)
        frontView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: GlobalVariables.CardViewIntervals.top.rawValue).isActive = true
        frontView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        frontView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        frontView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: GlobalVariables.CardViewIntervals.bottom.rawValue).isActive = true
        //153, 219, 210
        frontView.backgroundColor = UIColor(red: 153/255, green: 219/255, blue: 210, alpha: 1)
    }
    
    private func setupViews() {
        frontView.panGesture.addTarget(self, action: #selector(handleGesture(gesture:)))
        frontView.tapGestrue.addTarget(self, action: #selector(handleCloseTap(sender:)))
        frontView.infoView.doubleTap.addTarget(self, action: #selector(enableTextField(sender:)))
        frontView.infoView.singleTapGuesture.addTarget(self, action: #selector(handleOpenTap(sender:)))
        frontView.collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleInfoPan(sender:)))
        frontView.collectionView.dataSource = self.cardViewModel
        frontView.collectionView.delegate = self
        frontView.functionEnabled = false
        frontView.alpha = 0
        frontView.collectionView.tag = 1
        
        backView.panGesture.addTarget(self, action: #selector(handleGesture(gesture:)))
        backView.tapGestrue.addTarget(self, action: #selector(handleCloseTap(sender:)))
        backView.infoView.doubleTap.addTarget(self, action: #selector(enableTextField(sender:)))
        backView.infoView.singleTapGuesture.addTarget(self, action: #selector(handleOpenTap(sender:)))
        backView.collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleInfoPan(sender:)))
        
        backView.collectionView.dataSource = self.cardViewModel
        backView.collectionView.delegate = self
        backView.functionEnabled = false
        backView.alpha = 0
        backView.collectionView.tag = 2
    }
    
    //MARK: action related methods
    
    func handleGesture(gesture: UIPanGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        let viewOnTheBack = self.cardView(under: display)
        let velocity = gesture.velocity(in: self.view)
        let size = view.bounds.size
        let translation = gesture.translation(in: self.view)
        let isSwipe = abs(velocity.x) >= GlobalVariables.dismissVelocity
        let isOKToDismiss = abs(atan(translation.x / size.height)) > abs(atan(size.width / (2 * size.height)))
        switch gesture.state {
        case .began:
            break
        case .changed:
            
            self.rotate(cardView: display, translationPoint: translation)
            break
        case .ended, .cancelled, .failed:
            if !isSwipe && !isOKToDismiss {
                self.rotate(cardView: display, translationPoint: CGPoint(x: 0, y: 0))
            }else {
                let angle = atan(display.center.x / size.height)
                if abs(angle) < (CGFloat.pi / 2) {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                        display.transform = CGAffineTransform(rotationAngle: angle > 0 ? (CGFloat.pi / 4): -(CGFloat.pi / 4))
                        display.center.x = angle > 0 ? size.width + size.height / 2 : 0 - size.height / 2
                    }, completion: {
                        if $0 {
                            display.transform = CGAffineTransform.identity
                            display.center = viewOnTheBack.center
                            self.currentDisplayView = self.cardView(under: display)
                        }
                    })
                }
            }
            break
        default:
            break
        }
    }
    
    func handleInfoPan(sender: UIPanGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        let scrollView = display.collectionView
        guard scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height else { return }
        let vel = sender.velocity(in: self.view)
        let translation = sender.translation(in: self.view)
        let isSwipe = abs(vel.y) >= GlobalVariables.virticalVelocity
        switch sender.state {
        case .began, .changed:
            display.panGesture.isEnabled = false
            guard isSwipe else {
                panWithTouch(to: translation, for: display)
                break
            }
            showCardInfoView(for: display)
            break
        case .ended, .failed, .cancelled:
            display.panGesture.isEnabled = true
            if vel.y < 0 {
                showCardInfoView(for: display)
            }else {
                hideCardInfoView(for: display)
            }
        default:
            break
        }
    }
    
    func handleCloseTap(sender:UITapGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        if sender == display.tapGestrue && !display.infoBackView.isHidden{
            self.hideCardInfoView(for: display)
        }
    }
    func handleOpenTap(sender:UITapGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        if sender == display.infoView.singleTapGuesture{
            if display.infoBackView.isHidden {
                self.showCardInfoView(for: display)
            }else {
                self.hideCardInfoView(for: display)
            }
        }
    }
    
    @objc func enableTextField(sender: UITapGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        guard sender.numberOfTapsRequired == 2 else { return }
        display.infoView.albumName.isEnabled = !display.infoView.albumName.isEnabled
        if display.infoView.albumName.isEnabled {
            display.infoView.albumName.becomeFirstResponder()
        }
    }
    //MARK: animations
    
    private func panWithTouch(to point: CGPoint, for view:CardView) {
        view.infoBackView.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                let height = GlobalVariables.cardInfoHeaderHeight
                let expandHeight = view.bounds.size.height / 2
                let alp = (height - point.y) / (expandHeight - height)
                let const = height - point.y > expandHeight ? expandHeight : height - point.y
                view.infoBackView.alpha = alp > 0.8 ? 0.8 : alp
                view.infoHeightConstraint?.constant = const < height ? height : const
                view.layoutIfNeeded()
            })
    }
    
    private func rotate(cardView: CardView, translationPoint translation: CGPoint) {
        let angle = atan(translation.x / self.view.bounds.size.height)
        let viewOntheBack = self.cardView(under: cardView)
        let rotate = CGAffineTransform(rotationAngle: angle)
        UIView.animate(withDuration: 0.1) {
            cardView.transform = rotate
            cardView.center.x = self.view.center.x + translation.x
            viewOntheBack.alpha = abs(translation.x) / self.view.bounds.size.width
        }
    }
    
    internal func hideCardInfoView(for card:CardView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
            card.infoBackView.alpha = 0
            card.infoHeightConstraint?.constant = GlobalVariables.cardInfoHeaderHeight
            card.layoutIfNeeded()
        }) { (success) in
            if success {
                card.infoBackView.isHidden = true
                card.collectionView.panGestureRecognizer.isEnabled = true
            }
        }
    }
    
    internal func showCardInfoView(for card: CardView) {
        card.infoBackView.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            card.infoBackView.alpha = 0.8
            card.infoHeightConstraint?.constant = card.bounds.size.height / 2
            card.layoutIfNeeded()
        }) { (success) in
            card.collectionView.panGestureRecognizer.isEnabled = false
        }
    }
    
    //Helper methods
    private func cardView(under card: CardView) -> CardView {
        return card == frontView ? backView : frontView
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height) {
            scrollView.bounces = false
        }else {
            scrollView.bounces = true
        }
    }
}
