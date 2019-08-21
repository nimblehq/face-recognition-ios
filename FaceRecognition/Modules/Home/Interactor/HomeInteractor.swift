//
//  HomeInteractor.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

// sourcery: AutoMockable
protocol HomeInteractorInput: AnyObject {
}

// sourcery: AutoMockable
protocol HomeInteractorOutput: AnyObject {
}

final class HomeInteractor {

    weak var output: HomeInteractorOutput?
}

// MARK: - HomeInteractorInput
extension HomeInteractor: HomeInteractorInput {
}
