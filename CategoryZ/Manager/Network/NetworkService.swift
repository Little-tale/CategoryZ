//
//  NetworkService.swift
//  CategoryZ
//
//  Created by Jae hyung Kim on 4/30/24.
//

/*
 NWPathMovitor
 Apple이 네트워크 프레임 워크
 네트워크 연결의 상태를 모니터링 할 수 있게 해주는 클래스
 네트워크 연결상태가 변경 될때마다 알림을 받을 수 있다.
 현재 연결 상태도 받을수 있다.
 */

import Network
import RxSwift
import RxCocoa

final class NetWorkServiceMonitor {
    
    static
    let shared = NetWorkServiceMonitor()
    
    fileprivate
    let queue = DispatchQueue.global(qos: .background)
    
    fileprivate
    let monitor: NWPathMonitor
    
    fileprivate(set)
    var isConnected: Bool = false
    
    fileprivate(set)
    var connectionType: ConnectionType = .unknown
    
    let behaivorNetwork = PublishRelay<Bool> ()
    
    let behaiborNetworkType = PublishRelay<ConnectionType> ()
    
    private
    init(){
        monitor = NWPathMonitor()
    }
    
    // IOS 에서 나올수 있는 경우를 Enum 화합니다.
    // 기본제공되는것은 열거형이 아니기에 이렇게 작업합니다.
    enum ConnectionType {
        case cellular
        case ethernet
        case unknown
        case wifi
    }
    // 외부에선 이메서드를 통해 모니터를 시작할수 있습니다.
    
    func startMonitor(){
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = {
            [weak self] path in
            guard let self else { return }
            isConnected = path.status == .satisfied
            getConnectionType(path)
            behaivorNetwork.accept(isConnected)
        }
    }
    /// NWPath 에서 path.status 열겨헝중
    /// .satisfied는 인터넷이 연결된 상태임을 뜻한다.
    /// usesInterfaceType 에선 셀룰러 와이파이 무선 연결 등이 더 존재한다.
    private
    func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
            
        } else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        behaiborNetworkType.accept(connectionType)
    }
    // MARK: 모니터링을 그만할수 있습니다.
    func stopMonitoring(){
        monitor.cancel()
    }
}
