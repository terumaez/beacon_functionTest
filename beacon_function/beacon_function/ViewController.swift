//
//  ViewController.swift
//  beacon_function
//
//  Created by 山田 諭 on 2018/05/21.
//  Copyright © 2018年 山田 諭. All rights reserved.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    // Mark: - 変数
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion!
    let uuidString: String = "48534442-4C45-4144-80C0-1800FFFFFFFF"
    let beaconIdentifier = "BBBDFU"

    // Mark: - IBOutlet
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!

    // Mark: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()

        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.distanceFilter = 1

        let status = CLLocationManager.authorizationStatus()

        if (status == .notDetermined) {

            locationManager.requestAlwaysAuthorization()
        }

    }

    // Mark: - Method()
    private func startMonitoring() {

        guard let uuid = UUID(uuidString: uuidString) else { return }
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: beaconIdentifier)
        // ディスプレイがオフでも通知がくる
        beaconRegion.notifyEntryStateOnDisplay = false
        // 入域通知の設定
        beaconRegion.notifyOnEntry = true
        // 退域通知の設定
        beaconRegion.notifyOnExit = true
        // モニタ開始
        locationManager.startMonitoring(for: beaconRegion)
    }
    // Mark: - delegateメソッド
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch(status) {
        case .notDetermined:
            print("notDetermined")
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            startMonitoring()
            break
        case .authorizedWhenInUse:
            print("authorizedWAhenInUse")
            startMonitoring()
            break
        }
    }
    // startMonitoring(for:)実行で呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 領域の内部にいるかの判定
        manager.requestState(for: region);
    }

    // requestState実行で非同期で呼ばれる
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch(state) {
        case .inside:
            print("リージョン内に入っている")
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break
        case .outside:
            print("リージョン外にいます")
            break
        case .unknown:
            print("わかりません")
            break
        }
    }

    // startRangingBeacons実行で呼ばれる
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            print("beaconsの中身: \(beacons)")
            let beacon = beacons[0]
            let minorID = beacon.minor
            let majorID = beacon.major
            let rssi = beacon.rssi
            var proximity = ""
            switch(beacon.proximity) {
            case .immediate:
                proximity = "かなり近い"
                break
            case .near:
                proximity = "近い"
                break
            case .far:
                proximity = "遠い"
                break
            case .unknown:
                proximity = "測定不可"
                break
            }
            var myBeaconDetails = "Major: \(majorID) "
            myBeaconDetails += "Minor: \(minorID) "
            myBeaconDetails += "Proximity:\(proximity) "
            myBeaconDetails += "RSSI:\(rssi)"
            print("myBeaconDetailsの値:\(myBeaconDetails)")
            proximityLabel.text = "距離 \(proximity)"
            rssiLabel.text = "RSSI \(rssi)"
        }
    }

    //IN/OUT検知 - IN
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {

        print("リージョンに入った")
        // CLBeaconRegionオブジェクトの持つ情報の取得
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        // ユーザーの位置情報を更新して確認
        manager.startUpdatingLocation()
    }

    // IN/OUT検知 - OUT
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("リージョンから出た")
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }

    // 監視エラー
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("error内容：\(error)")
    }

}

