//
//  Utilities.swift
//  todoList
//
//  Created by 박에스더 on 6/17/24.
//

import Foundation

func saveDataToFile(data: Data, filename: String) -> URL? {
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    let fileURL = documentsURL.appendingPathComponent(filename)
    do {
        try data.write(to: fileURL, options: .atomic)
        return fileURL
    } catch {
        print("Error saving file: \(error)")
        return nil
    }
}

func loadDataFromFile(filename: String) -> Data? {
    let fileManager = FileManager.default
    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return nil
    }
    
    let fileURL = documentsURL.appendingPathComponent(filename)
    do {
        let data = try Data(contentsOf: fileURL)
        return data
    } catch {
        print("Error loading file: \(error)")
        return nil
    }
}
