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
    
    var currentPage = 0
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        view.addSubview(pageControl)
        view.addSubview(listButton)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController")
        
        pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        pageControl.numberOfPages = FineDustListViewModel.finedustList.count == 0 ? 1 : FineDustListViewModel.finedustList.count
        pageControl.currentPage = currentPage
    }
}

extension PageViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("Before")
        if currentPage == 0 {
            return nil
        }

        currentPage -= 1
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        vc?.mode = .show
        vc?.index = currentPage - 1

        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if currentPage == FineDustListViewModel.finedustList.count - 1{
            return nil
        }
    
        currentPage += 1
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        vc?.mode = .show
        vc?.index = currentPage
    
        return vc
    }
}

extension PageViewController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        print("delegate",currentPage)
        
        pageControl.currentPage = currentPage
    }
}
