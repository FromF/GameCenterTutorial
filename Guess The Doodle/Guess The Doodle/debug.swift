//
//  debug.swift
//  Guess The Doodle
//
//  Created by 藤治仁 on 2024/05/24.
//

import Foundation

///デバックモード設定
func debugLog(_ obj: Any?,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
#if DEBUG
    let filename = URL(fileURLWithPath: file).lastPathComponent
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    let dateString = dateFormatter.string(from: Date())
    if let obj = obj {
        print("\(dateString)[\(filename) \(function):\(line)] : \(obj)")
    } else {
        print("\(dateString)[\(filename) \(function):\(line)]")
    }
#endif
}

func errorLog(_ obj: Any?,
              file: String = #file,
              function: String = #function,
              line: Int = #line) {
#if DEBUG
    let filename = URL(fileURLWithPath: file).lastPathComponent
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .medium
    let dateString = dateFormatter.string(from: Date())
    if let obj = obj {
        print("\(dateString)ERROR [\(filename) \(function):\(line)] : \(obj)")
    } else {
        print("\(dateString)ERROR [\(filename) \(function):\(line)]")
    }
#endif
}
