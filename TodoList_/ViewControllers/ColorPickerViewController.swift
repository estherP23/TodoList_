//
//  ColorPickerViewController.swift
//  todoList
//
//  Created by 박에스더 on 6/17/24.
//

import Foundation
import UIKit

protocol ColorPickerDelegate: AnyObject {
    func didSelectColor(_ color: UIColor)
}

class ColorPickerViewController: UIViewController {
    
    weak var delegate: ColorPickerDelegate?
    
    let colors: [(String, UIColor)] = [
        ("Pastel Red", UIColor(red: 255/255, green: 153/255, blue: 153/255, alpha: 1.0)),
        ("Pastel Green", UIColor(red: 102/255, green: 255/255, blue: 102/255, alpha: 1.0)),
        ("Pastel Blue", UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)),
        ("Pastel Yellow", UIColor(red: 255/255, green: 255/255, blue: 153/255, alpha: 1.0)),
        ("Pastel Orange", UIColor(red: 255/255, green: 204/255, blue: 153/255, alpha: 1.0)),
        ("Pastel Purple", UIColor(red: 204/255, green: 153/255, blue: 255/255, alpha: 1.0)),
        ("Pastel Gray", UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)),
        ("Pastel Pink", UIColor(red: 255/255, green: 204/255, blue: 229/255, alpha: 1.0)),
        ("Pastel Cyan", UIColor(red: 204/255, green: 255/255, blue: 255/255, alpha: 1.0)),
        ("Pastel Lavender", UIColor(red: 230/255, green: 230/255, blue: 250/255, alpha: 1.0))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
    }
    
    private func setupViews() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        
        for (title, color) in colors {
            let colorButton = UIButton()
            colorButton.backgroundColor = color
            colorButton.layer.cornerRadius = 5
            colorButton.layer.borderWidth = 1
            colorButton.layer.borderColor = UIColor.black.cgColor
            colorButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
            colorButton.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(colorButton)
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func colorButtonTapped(_ sender: UIButton) {
        guard let color = sender.backgroundColor else { return }
        delegate?.didSelectColor(color)
        dismiss(animated: true, completion: nil)
    }
}
