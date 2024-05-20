//
//  CustomDebouncer.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 5/20/24.
//

import Foundation


final class CustomDebouncer {
    
    private
    var workItem: DispatchWorkItem?
    
    private
    let miliSeconds: Int
    
    init(miliSeconds: Int) {
        self.miliSeconds = miliSeconds
    }
    
    deinit {
        cancel()
    }
}

extension CustomDebouncer {
    
    func setAction(_ action: @escaping () -> Void) {
        workItem?.cancel()
        let new = DispatchWorkItem(block: action)
        workItem = new
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(miliSeconds / 100), execute: new)
    }
    
    func cancel() {
        workItem?.cancel()
    }
}
