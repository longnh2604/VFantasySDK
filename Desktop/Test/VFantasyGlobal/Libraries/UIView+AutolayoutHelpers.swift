//
//  UIView+AutolayoutHelpers.swift
//  VTMan
//
//  Created by Le Duc Tien on 5/18/19.
//  Copyright © 2019 ppcLink. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  
  // retrieves all constraints that mention the view
  func getAllConstraints() -> [NSLayoutConstraint] {
    
    // array will contain self and all superviews
    var views = [self]
    
    // get all superviews
    var view = self
    while let superview = view.superview {
      views.append(superview)
      view = superview
    }
    
    // transform views to constraints and filter only those
    // constraints that include the view itself
    return views.flatMap({ $0.constraints }).filter { constraint in
      return constraint.firstItem as? UIView == self ||
        constraint.secondItem as? UIView == self
    }
  }
}

extension UIView {
  
  // Example 1: Get all width constraints involving this view
  // We could have multiple constraints involving width, e.g.:
  // - two different width constraints with the exact same value
  // - this view's width equal to another view's width
  // - another view's height equal to this view's width (this view mentioned 2nd)
  func getWidthConstraints() -> [NSLayoutConstraint] {
    return getAllConstraints().filter( {
      ($0.firstAttribute == .width && $0.firstItem as? UIView == self) ||
        ($0.secondAttribute == .width && $0.secondItem as? UIView == self)
    } )
  }
  
  // Example 2: Change width constraint(s) of this view to a specific value
  // Make sure that we are looking at an equality constraint (not inequality)
  // and that the constraint is not against another view
  func changeWidth(to value: CGFloat) {
    
    getAllConstraints().filter( {
      $0.firstAttribute == .width &&
        $0.relation == .equal &&
        $0.secondAttribute == .notAnAttribute
    } ).forEach( {$0.constant = value })
  }
  
  func changeHeight(to value: CGFloat) {
    
    getAllConstraints().filter( {
      $0.firstAttribute == .height &&
        $0.relation == .equal &&
        $0.secondAttribute == .notAnAttribute
    } ).forEach( {$0.constant = value })
  }
  
  // Example 3: Change leading constraints only where this view is
  // mentioned first. We could also filter leadingMargin, left, or leftMargin
  func changeLeading(to value: CGFloat) {
    getAllConstraints().filter( {
      $0.firstAttribute == .leading &&
        $0.firstItem as? UIView == self
    }).forEach({$0.constant = value})
  }
  
  func changeTrailing(to value: CGFloat) {
    getAllConstraints().filter( {
      $0.firstAttribute == .trailing &&
        $0.firstItem as? UIView == self
    }).forEach({$0.constant = value})
  }
  
  func changeTop(to value: CGFloat) {
    getAllConstraints().filter( {
      $0.firstAttribute == .top &&
        $0.firstItem as? UIView == self
    }).forEach({$0.constant = value})
  }
  
  func changeBottom(to value: CGFloat) {
    getAllConstraints().filter( {
      $0.firstAttribute == .bottom &&
        $0.firstItem as? UIView == self
    }).forEach({$0.constant = value})
  }
}
