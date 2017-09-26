//
//  ViewController.swift
//  commonPractice
//
//  Created by Xinyuan's on 8/2/17.
//  Copyright © 2017 Xinyuan Wang. All rights reserved.
//

import UIKit
import QuartzCore
import Photos

enum CellTypes: String {
    case imageCell = "imageCell"
}

class MainViewController: UIViewController {
    
    var frontView: CardView = CardView(frame: .zero)
    
    var backView: CardView = CardView(frame: .zero)
    
    @objc dynamic var currentDisplayView: CardView? {
        didSet {
            guard currentDisplayView != oldValue, let display = currentDisplayView else { return }
            let back = self.cardView(under: display)
            display.alpha = 1
            
            enableGestures(for: display)
            display.functionEnabled = true
            
            disableGestures(for: back)
            back.functionEnabled = false
            let totalCount = SimpleImageManager.shared.count
            var moveIndex = self.backAlbumIndex
            if self.isMoveForward {
                moveIndex = (moveIndex > totalCount - 2) ? 0 : (moveIndex + 1)
            }else {
                moveIndex = (moveIndex < 1) ? totalCount - 1 : moveIndex - 1
            }
            self.backAlbumIndex = moveIndex
        }
    }
    private var observation: NSKeyValueObservation?
    private var isMoveForward: Bool = true
    var backAlbumIndex:SimpleImageManager.Index = 1;
    //MARK: Controller Life Cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        setupViews()
        let manager = SimpleImageManager.shared
        currentDisplayView = frontView
        guard  let result = manager.fetchCollection(at: 0) else { return }
        let frontModel = CardViewModel(with: result, from: self)
        frontModel.managedView = self.frontView
        self.frontView.model = frontModel
        guard let backResult = manager.fetchCollection(at: self.backAlbumIndex) else { return }
        let backModel = CardViewModel(with: backResult, from: self)
        backModel.managedView = self.backView
        self.backView.model = backModel
    }

    private func setupLayouts() {
        
        view.addSubview(backView)
        backView.collectionView.backgroundColor = UIColor.blue
        
        backView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: GlobalVariables.CardViewIntervals.top.rawValue).isActive = true
        backView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        backView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        backView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: GlobalVariables.CardViewIntervals.bottom.rawValue).isActive = true
        backView.infoView.albumName.delegate = self
        
        view.addSubview(frontView)
        frontView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: GlobalVariables.CardViewIntervals.top.rawValue).isActive = true
        frontView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        frontView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        frontView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: GlobalVariables.CardViewIntervals.bottom.rawValue).isActive = true
        //153, 219, 210
        frontView.backgroundColor = UIColor(red: 153/255, green: 219/255, blue: 210, alpha: 1)
        frontView.infoView.albumName.delegate = self
    }
    
    private func setupViews() {
        frontView.collectionView.delegate = self
        frontView.functionEnabled = false
        frontView.alpha = 0
        frontView.collectionView.tag = 1
        
        backView.collectionView.delegate = self
        backView.functionEnabled = false
        backView.alpha = 0
        backView.collectionView.tag = 2
    }
    
    //MARK: action related methods
    
    @objc func handleGesture(gesture: UIPanGestureRecognizer) {
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
                        viewOnTheBack.alpha = 1
                    }, completion: {[unowned self] in
                        if $0 {
                            display.transform = CGAffineTransform.identity
                            display.center = viewOnTheBack.center
                            self.view.insertSubview(display, belowSubview: viewOnTheBack)
                            self.isMoveForward = angle > 0
                            self.currentDisplayView = viewOnTheBack
                        }
                    })
                }
            }
            break
        default:
            break
        }
    }
    
    @objc func handleInfoPan(sender: UIPanGestureRecognizer) {
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
            display.showCardInfoView()
            break
        case .ended, .failed, .cancelled:
            display.panGesture.isEnabled = true
            if vel.y < 0 {
                display.showCardInfoView()
            }else {
                display.hideCardInfoView()
            }
        default:
            break
        }
    }
    
    
    
    @objc func enableTextField(sender: UITapGestureRecognizer) {
        guard let display = currentDisplayView else { return }
        guard sender.numberOfTapsRequired == 2 else { return }
        display.infoView.albumName.isEnabled = !display.infoView.albumName.isEnabled
        if display.infoView.albumName.isEnabled {
            display.infoView.albumName.becomeFirstResponder()
            display.functionEnabled = false
            display.tapGestrue.isEnabled = true
        }
    }
    //MARK: Private helper methods
    
    private func disableGestures(for card: CardView?) {
        guard let card = card else { return }
        card.infoView.doubleTap.removeTarget(self, action: #selector(enableTextField(sender:)))
        card.collectionView.panGestureRecognizer.removeTarget(self, action: #selector(handleInfoPan(sender:)))
    }
    
    private func enableGestures(for card: CardView?) {
        guard let card = card else { return }
        card.panGesture.addTarget(self, action: #selector(handleGesture(gesture:)))
        card.infoView.doubleTap.addTarget(self, action: #selector(enableTextField(sender:)))
        card.collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleInfoPan(sender:)))
    }
    //MARK: animations
    
    private func panWithTouch(to point: CGPoint, for view:CardView) {
        view.infoBackView.isHidden = false
        let height = GlobalVariables.cardInfoHeaderHeight
        let expandHeight = view.bounds.size.height / 2
        let alp = (height - point.y) / (expandHeight - height)
        let const = height - point.y > expandHeight ? expandHeight : height - point.y
        UIView.animate(withDuration: 0.1, animations: {
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
            viewOntheBack.alpha = abs(translation.x) * 2 / self.view.bounds.size.width
        }
    }
    //Helper methods
    private func cardView(under card: CardView) -> CardView {
        return card == frontView ? backView : frontView
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            if let card = self.currentDisplayView {
                card.functionEnabled = true
            }
            textField.resignFirstResponder()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let str = textField.text, str.isEmpty{
            return !string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
        }
        return true
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


