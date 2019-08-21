//
//  HomePresenter.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

final class HomePresenter {

    weak var view: HomeViewInput?
    var router: HomeRouterInput?
    var interactor: HomeInteractorInput?

    var output: HomeOutput?
}

// MARK: - HomeViewOutput
extension HomePresenter: HomeViewOutput {
    func showCamera() {
    }

    func showFaceRecognition() {
    }

    func viewDidLoad() {
        view?.configure()
    }
}

// MARK: - HomeInteractorOutput
extension HomePresenter: HomeInteractorOutput {
}

// MARK: - HomeInput
extension HomePresenter: HomeInput {
}
