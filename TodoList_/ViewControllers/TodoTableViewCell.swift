//
//  TodoTableViewCell.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import UIKit
import RxSwift
import RxCocoa

class TodoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnCheckbox: CheckUIButton!
    
    static let nibName = "TodoTableViewCell"
    static let identifier = "TodoCell"
    
    var viewModel = TodoViewModel(Todo.empty)
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bind(task: Todo) {
        viewModel = TodoViewModel(task)
        
        // UI 바인딩
        setupBindings()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        let task = viewModel.task.asDriver()
        
        // 제목 설정
        task.map { $0.title }
            .drive(lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        // 설명
        task.map { $0.description ?? "" }
            .drive(lblDescription.rx.text)
            .disposed(by: disposeBag)
        
        task.map {
                if $0.description?.isEmpty == false { return false }
                return true
            }
            .drive(lblDescription.rx.isHidden)
            .disposed(by: disposeBag)
        
        
        task.map { $0.time ?? "" }
            .drive(lblTime.rx.text)
            .disposed(by: disposeBag)
        
        task.map {
                if $0.time?.isEmpty == false { return false }
                return true
            }
            .drive(lblTime.rx.isHidden)
            .disposed(by: disposeBag)
        
       
        viewModel.checkImageString.asDriver(onErrorJustReturn: "circle")
            .map { UIImage(systemName: $0) }
            .drive(btnCheckbox.rx.backgroundImage())
            .disposed(by: disposeBag)
    }
}

class CheckUIButton : UIButton {
    var indexPath: IndexPath?
    var borderColor: UIColor = .clear
        
        override var isSelected: Bool {
            didSet {
                updateBorderColor()
            }
        }
        
        func setColor(_ color: UIColor) {
            self.borderColor = color
            updateBorderColor()
            
        }
        
        private func updateBorderColor() {
            if isSelected {
                self.layer.borderColor = borderColor.cgColor
                self.layer.borderWidth = 2.0
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0.0
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.layer.cornerRadius = self.frame.width / 2
            self.layer.masksToBounds = true
        }
}
