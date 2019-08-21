//
//  HomeRouter.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit

// sourcery: AutoMockable
protocol HomeRouterInput: AnyObject {
    func show(on window: UIWindow)
}

final class HomeRouter {

    weak var view: HomeViewInput?

    private var viewController: UIViewController? {
        return view as? UIViewController
    }
}

// MARK: - HomeRouterInput

extension HomeRouter: HomeRouterInput {
    func show(on window: UIWindow) {
        guard let viewController = self.viewController else { return }
        let navigationController = UINavigationController(rootViewController: viewController)
        window.rootViewController = navigationController
    }
}
