//
//  PageViewController.swift
//  FineDust
//
//  Created by 홍승아 on 2021/06/29.
//

import CoreLocation
import UIKit

import RxSwift
import RxCocoa

class PageViewController: UIViewController {
  
  static let identifer = "PageViewController"
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var listButton: UIButton!
  
  private var fineDustListViewModel = FineDustListViewModel()
  private var pageViewController: UIPageViewController!
  var currentPage = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  override func viewDidAppear(_ animated: Bool) {
    configurePageViewController()
    configurePageControl()
    pageViewController.delegate = self
    pageViewController.dataSource = self
  }
  
  @IBAction func pageControlDidTap(_ sender: Any) {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else { return }
    currentPage = pageControl.currentPage
    vc.mode = currentPage == 0 ? .currentLocation : .added
    vc.index = currentPage
    pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
  }
  
  private func configurePageViewController() {
    pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    addChild(pageViewController)
    view.addSubview(pageViewController.view)
    view.addSubview(pageControl)
    view.addSubview(listButton)
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else { return }
    vc.mode = currentPage == 0 ? .currentLocation : .added
    vc.index = currentPage
    pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
  }
  
  private func configurePageControl(){
    pageControl.numberOfPages = fineDustListViewModel.fineDustListCount
    pageControl.currentPage = currentPage
  }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource{
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if currentPage <= 0 {
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
    if currentPage >= fineDustListViewModel.fineDustListCount - 1 {
      return nil
    }
    currentPage += 1
    guard let vc = storyboard?.instantiateViewController(withIdentifier: FineDustViewController.identifier) as? FineDustViewController else {
      return nil
    }
    vc.mode = .added
    vc.index = currentPage
    return vc
  }
}

// MARK: - UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard completed else { return }
    if let currentViewController = pageViewController.viewControllers?[0] as? FineDustViewController{
      pageControl.currentPage = currentViewController.index
      currentPage = currentViewController.index
    }
  }
}
