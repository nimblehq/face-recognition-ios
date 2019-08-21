//
//  HomeModule.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit

// sourcery: AutoMockable
protocol HomeInput: AnyObject {}

// sourcery: AutoMockable
protocol HomeOutput: AnyObject {}

final class HomeModule {

    let view: HomeViewController
    let presenter: HomePresenter
    let router: HomeRouter
    let interactor: HomeInteractor

    var output: HomeOutput? {
        get { return presenter.output }
        set { presenter.output = newValue }
    }

    var input: HomeInput? {
        return presenter
    }

    init() {
        self.view = HomeViewController()
        self.presenter = HomePresenter()
        self.router = HomeRouter()
        self.interactor = HomeInteractor()

        view.output = presenter

        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        presenter.output = output

        interactor.output = presenter

        router.view = view
    }
}
