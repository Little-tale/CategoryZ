//
//  CustomDebouncer.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import Foundation


final class CustomDebouncer {
    
    private
    let delayTime: UInt64
    
    private
    var task: Task<Void, Error>?
    
    init(delayTime: UInt64, task: Task<Void, Error>? = nil) {
        self.delayTime = UInt64(delayTime * 1_000_000_000)
        self.task = task
    }
    
    deinit {
        cancle()
    }
}

extension CustomDebouncer {
    func actionHandler(action: @escaping() async -> Void) {
        execute(action: action)
    }
    
    func execute(action: @escaping () async -> Void) {
        task?.cancel()
        task = Task { [delayTime] in
            do {
                try await Task.sleep(nanoseconds: delayTime)
            } catch {
                return
            }
        }
    }
    
    func cancle() {
        task?.cancel()
        task = nil
    }
}
