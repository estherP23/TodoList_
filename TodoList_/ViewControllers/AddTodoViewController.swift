//
//  AddTodoViewController.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa

class AddTaskViewController: UIViewController, UIColorPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ColorPickerDelegate  {
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var viewTaskDetails: UIStackView!
    @IBOutlet weak var segctrlTime: UISegmentedControl!
    @IBOutlet weak var btnColorPicker: UIButton! // 색상 선택 버튼 추가
    
    
    @IBOutlet weak var segctrlNotificationTime: UISegmentedControl!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var btnSelectImage: UIButton!
    
    
    
    
    
    // MARK: - Instance Properties
    
    static let storyboardID = "addTask"
    
    let scheduled = 0, anytime = 1
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    
    var delegate: SendDataDelegate?
    var editTask: Todo?
    var indexPath: IndexPath?
    var currentDate: Date?
    var selectedColor: UIColor = .systemGray // 선택된 색상
    
    var disposeBag = DisposeBag()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupBindings()
        addDatePicker()
        addTimePicker()
        
        txtTitle.becomeFirstResponder()
        
        // 색상 선택 버튼 설정
                btnColorPicker.addTarget(self, action: #selector(showColorPicker), for: .touchUpInside)
        
        // 이미지 선택 버튼 설정
                btnSelectImage.addTarget(self, action: #selector(selectImageTapped), for: .touchUpInside)
       
        
        if let task = editTask {
                    // 기존 작업 편집 모드일 경우 데이터 채우기
                    txtTitle.text = task.title
                    txtDescription.text = task.description
                    if let date = task.date, let pickerDate = date.toDate() {
                        datePicker.date = pickerDate
                        datePicker.sendActions(for: .valueChanged)
                    }
                    if let time = task.time, let pickerTime = time.toTime() {
                        timePicker.date = pickerTime
                        timePicker.sendActions(for: .valueChanged)
                    } else {
                        txtTime.text = ""
                    }
                    if let color = task.color {
                        selectedColor = UIColor(hex: color) ?? .systemGray
                    }
                    segctrlNotificationTime.selectedSegmentIndex = task.notificationTime.rawValue
                    
                    if let imageData = task.imageData, let image = UIImage(data: imageData) {
                        imgView.image = image
                    }
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let task = editTask else {
            self.title = "Make List"
            datePicker.date = currentDate ?? Date()
            datePicker.sendActions(for: .valueChanged)
            btnSave.isEnabled = false
            return
        }
        
       
        self.title = "Edit Task"
        btnSave.isEnabled = true
        
      
        if let date = task.date, !date.isEmpty {
            segctrlTime.selectedSegmentIndex = scheduled
        } else {
            segctrlTime.selectedSegmentIndex = anytime
        }
        segctrlTime.sendActions(for: .valueChanged)
        
        // 데이터 채우기
        txtTitle.text = task.title
        txtDescription.text = task.description
        if let date = task.date, let pickerDate = date.toDate() {
            datePicker.date = pickerDate
            datePicker.sendActions(for: .valueChanged)
        }
        if let time = task.time, let pickerTime = time.toTime() {
            timePicker.date = pickerTime
            timePicker.sendActions(for: .valueChanged)
        } else {
            txtTime.text = ""
        }
        // 기존 작업의 색상을 설정합니다.
                if let color = task.color {
                    selectedColor = UIColor(hex: color) ?? .systemGray
                }
        
        // 기존 작업의 이미지를 설정합니다.
                if let imageData = task.imageData, let image = UIImage(data: imageData) {
                    imgView.image = image
                }
    }
    
    // MARK: - UI Binding
    
    func setupBindings() {
        txtTitle.rx.text.asDriver()
            .map {
                guard let title = $0, !title.isEmpty else { return false }
                return true
            }
            .drive(btnSave.rx.isEnabled)
            .disposed(by: disposeBag)
        
        segctrlTime.rx.selectedSegmentIndex.asDriver()
            .map { return ($0 == self.scheduled ? false : true) }
            .drive(onNext: { [weak self] in
                self?.viewTaskDetails.subviews[0].isHidden = $0
                self?.viewTaskDetails.subviews[1].isHidden = $0
            })
            .disposed(by: disposeBag)
        
        datePicker.rx.date.asDriver()
            .map { $0.toString() }
            .drive(txtDate.rx.text)
            .disposed(by: disposeBag)
        
        timePicker.rx.date.asDriver()
            .map { $0.toTimeString() }
            .drive(txtTime.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - DatePicker
    
    func addDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnSpace, btnDone], animated: true)
        
        txtDate.inputView = datePicker
        txtDate.inputAccessoryView = toolbar
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
    }
    
    /*func addTimePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnTrash, btnSpace, btnDone], animated: true)
        
        txtTime.inputView = timePicker
        txtTime.inputAccessoryView = toolbar
        
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
    }*/
    func addTimePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let btnTrash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashPressed))
        let btnSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolbar.setItems([btnTrash, btnSpace, btnDone], animated: true)
        
        txtTime.inputView = timePicker
        txtTime.inputAccessoryView = toolbar
        
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "ko_KR")
    }
    
    // MARK: - Actions
    
 
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        txtTitle.endEditing(true)
        txtDescription.endEditing(true)
        
        var date: String? = ""
        var time: String? = ""
        
        if segctrlTime.selectedSegmentIndex == scheduled {
            date = txtDate.text
            time = txtTime.text
        }
        
        let imageData = imgView.image?.jpegData(compressionQuality: 0.8) // 선택된 이미지 데이터
        
        let notificationTime = Todo.NotificationTime(rawValue: segctrlNotificationTime.selectedSegmentIndex) ?? .atTime
        
        let todoObject = Todo(
            id: editTask?.id ?? UUID(), // 수정 중인 작업이면 기존 ID 사용, 아니면 새 UUID 생성
            title: txtTitle.text!,
            date: date,
            time: time,
            description: txtDescription.text,
            color: selectedColor.toHexString(),
            notificationTime: notificationTime, // 알림 시간 저장
            imageData: imageData // 이미지 데이터 저장
        )
        
        todoObject.scheduleNotification() // 알림 설정
        
        delegate?.sendData(oldTask: editTask, newTask: todoObject, indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func showColorPicker() {
            let colorPickerVC = ColorPickerViewController()
            colorPickerVC.delegate = self
            colorPickerVC.modalPresentationStyle = .popover
            colorPickerVC.preferredContentSize = CGSize(width: 300, height: 400)
            
            if let popoverController = colorPickerVC.popoverPresentationController {
                popoverController.sourceView = btnColorPicker
                popoverController.sourceRect = btnColorPicker.bounds
                popoverController.permittedArrowDirections = .any
            }
            
            present(colorPickerVC, animated: true, completion: nil)
        }
        
        func didSelectColor(_ color: UIColor) {
            self.selectedColor = color
            self.btnColorPicker.backgroundColor = color
        }
    
    @objc func donePressed() {
        self.view.endEditing(true)
    }
    
   
    @objc func trashPressed() {
        txtTime.text = ""
        self.view.endEditing(true)
    }
    
    
    @objc func selectImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imgView.contentMode = .scaleAspectFit
            imgView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
