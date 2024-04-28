//
//  RxViewController.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/10/24.
//
import UIKit
import RxSwift

class RxBaseViewController : BaseViewController {
    var disPoseBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriver()
    }
    func subscriver(){}
}
