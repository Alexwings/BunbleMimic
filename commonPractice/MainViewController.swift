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

class MainViewController: UIViewController {
    
    let containerView = CardView(frame: CGRect.zero)
    
    let cardViewModel = CardViewModel()
    
    var lastOnScreenPageIndex: Int = 0

    //MARK: Controller Life Cycle related methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        setupViews()
    }

    private func setupLayouts() {
        view.addSubview(containerView)
        containerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: GlobalVariables.CardViewIntervals.top.rawValue).isActive = true
        containerView.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor, constant: GlobalVariables.CardViewIntervals.left.rawValue).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor, constant: GlobalVariables.CardViewIntervals.right.rawValue).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: GlobalVariables.CardViewIntervals.bottom.rawValue).isActive = true
        
        containerView.collectionView.dataSource = self.cardViewModel
        containerView.collectionView.delegate = self
    }
    
    private func setupViews() {
        containerView.panGesture.addTarget(self, action: #selector(handleGesture(gesture:)))
        containerView.tapGestrue.addTarget(self, action: #selector(handleCloseTap(sender:)))
        containerView.collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleInfoPan(sender:)))
        containerView.pageIndicator.numberOfPages = cardViewModel.dataSource.count + 1
        containerView.pageIndicator.addTarget(self, action: #selector(handlePageValueChanged(_:)), for: .valueChanged)
    }
    
    //MARK: action related methods
    
    func handlePageValueChanged(_ page: UIPageControl) {
        if page.currentPage < cardViewModel.dataSource.count {
            let index = IndexPath(item: page.currentPage, section: 0)
            lastOnScreenPageIndex = page.currentPage
            containerView.collectionView.scrollToItem(at: index, at: .top, animated: true)
        }
    }
    func handleGesture(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self.view)
        let viewWidth = view.bounds.size.width
        let virticalDismissline: CGFloat = viewWidth * GlobalVariables.dismissLineFactor
        let rotateAnimation: ()->Void = {[unowned self] in
            switch gesture.state {
            case .began:
                break
            case .changed:
                let isSwipe = abs(velocity.x) >= GlobalVariables.dismissVelocity
                let isOKToDismiss = self.containerView.center.x >= viewWidth - virticalDismissline || self.containerView.center.x <= virticalDismissline
                
                if isSwipe || isOKToDismiss {
                    self.rotateToDismiss(cardView: self.containerView, toRight: velocity.x > 0)
                }else {
                    self.rotate(cardView: self.containerView, translationPoint: gesture.translation(in: self.view))
                }
                break
            case .ended, .cancelled, .failed:
                self.rotate(cardView: self.containerView, translationPoint: CGPoint(x: 0, y: 0))
                self.containerView.transform = CGAffineTransform.identity
                break
            default:
                break
            }
        }
        rotateAnimation()
    }
    
    func handleInfoPan(sender: UIPanGestureRecognizer) {
        let scrollView = containerView.collectionView
        guard scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height else { return }
        containerView.infoBackView.isHidden = false
    }
    
    func handleCloseTap(sender:UITapGestureRecognizer) {
        if sender == containerView.tapGestrue{
            self.hideCardInfoView(for: containerView)
        }
    }
    
    //MARK: animations
    
    private func panWithTouch(to point: CGPoint, for view:CardView) {
            UIView.animate(withDuration: 0.1, animations: {
                let height = GlobalVariables.cardInfoHeaderHeight
                let expandHeight = view.bounds.size.height
                if let constant = view.infoHeightConstraint?.constant, (constant - point.y >= height) && (constant - point.y <= expandHeight) {
                    view.infoHeightConstraint?.constant = height - point.y
                    view.layoutIfNeeded()
                }
            })
    }
    private func rotate(cardView: CardView, translationPoint translation: CGPoint) {
        let y = self.view.bounds.size.height
        let centerX = self.view.center.x
        //            let locationX = gesture.location(in: self.view).x
        UIView.animate(withDuration: 0.1, animations: {
            let rotate = CGAffineTransform(rotationAngle: atan(translation.x / y))
            cardView.transform = rotate
            cardView.center.x = centerX + translation.x
        })
    }
    
    private func rotateToDismiss(cardView view:CardView, toRight:Bool ) {
        let y = self.view.bounds.size.height
        let x = self.view.bounds.size.width / 2
        let angle = toRight ? atan(x / y) : (0 - atan(x / y))
        let movingDistance = toRight ? self.view.bounds.size.width - view.center.x : 0 - view.center.x
        let rotate = CGAffineTransform(rotationAngle: angle)
        let translate = CGAffineTransform(translationX: movingDistance, y: 0)
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = translate.concatenating(rotate)
            view.alpha = 0
            view.isHidden = true
        }) {[unowned self] (finish) in
            if finish {
                view.transform = CGAffineTransform.identity
                view.center = self.view.center
                view.alpha = 1
            }
        }
    }
    
    internal func hideCardInfoView(for card:CardView) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseIn, animations: {
            card.infoHeightConstraint?.constant = GlobalVariables.cardInfoHeaderHeight
            card.layoutIfNeeded()
        }) { (success) in
            if success {
                card.pageIndicator.currentPage = self.lastOnScreenPageIndex
                card.pageIndicator.updateCurrentPageDisplay()
            }
        }
    }
    
    internal func showCardInfoView(for card: CardView) {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            card.infoHeightConstraint?.constant = card.bounds.size.height / 2
            card.layoutIfNeeded()
        }) { (success) in
            if (card.pageIndicator.currentPage != self.cardViewModel.infoViewIndex) {
                card.pageIndicator.currentPage = self.cardViewModel.infoViewIndex
                card.pageIndicator.updateCurrentPageDisplay()
            }
        }
    }
    
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return containerView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.containerView.pageIndicator.currentPage = indexPath.item
        self.lastOnScreenPageIndex = indexPath.item
        self.containerView.pageIndicator.updateCurrentPageDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + scrollView.bounds.size.height >= scrollView.contentSize.height) {
            scrollView.bounces = false
        }else {
            scrollView.bounces = true
        }
    }
}

//extension MainViewController: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard let pan = gestureRecognizer as? UIPanGestureRecognizer, let otherPan = otherGestureRecognizer as? UIPanGestureRecognizer else { return false }
//        let vel = pan.velocity(in: self.view)
//        let vx = abs(vel.x)
//        let vy = abs(vel.y)
//        
//    }
//}

