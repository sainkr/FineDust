//
//  PageViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/29.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class PageViewController: UIViewController{
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var listButton: UIButton!
  
  private var fineDustListViewModel = FineDustListViewModel()
  var currentPage = 0
  private var pageViewController: UIPageViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    configurePageController()
    pageViewController.delegate = self
    pageViewController.dataSource = self
  }
  
  private func configurePageController(){
    pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    view.addSubview(listButton)
    
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else {
      return
    }
    
    pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
    pageControl.numberOfPages = fineDustListViewModel.fineDustListCount == 0 ? 1 : fineDustListViewModel.fineDustListCount
    pageControl.currentPage = currentPage
  }
}

extension PageViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if currentPage == 0 {
      return nil
    }
    currentPage -= 1
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else {
      return nil
    }
    vc.mode = currentPage == 0 ? .currentLocation : .added
    vc.index = currentPage
    return vc
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if fineDustListViewModel.fineDustListCount == 0 || currentPage == fineDustListViewModel.fineDustListCount - 1 {
      return nil
    }
    currentPage += 1
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else {
      return nil
    }
    vc.mode = .added
    vc.index = currentPage - 1
    return vc
  }
}

extension PageViewController: UIPageViewControllerDelegate{
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    if let currentViewController = pageViewController.viewControllers?[0] as? FineDustViewController{
      pageControl.currentPage = currentViewController.index
      currentPage = currentViewController.index
    }
  }
}
