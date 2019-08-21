//
//  HomeViewController.swift
//  FaceRecognition
//
//  Created by Su Van Ho on 21/8/19.
//  Copyright © 2019 Nimble. All rights reserved.
//

import UIKit

// sourcery: AutoMockable
protocol HomeViewInput: AnyObject {
    func configure()
}

// sourcery: AutoMockable
protocol HomeViewOutput: AnyObject {
    func viewDidLoad()
}

final class HomeViewController: UIViewController {

    var output: HomeViewOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        output?.viewDidLoad()
    }
}

// MARK: - HomeViewInput
extension HomeViewController: HomeViewInput {
    func configure() {
        navigationItem.title = "Face Recognition"
        view.backgroundColor = .white
    }
}
