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
    
    // 受信行う
    var locationManager: CLLocationManager!
    // 発信を行う
    var beaconRegion: CLBeaconRegion!
    let uuidString: String = "242A4B01-BD42-2CE0-9300-BA790F8FACBA"
    let beaconIdentifier = "BBBDFU"
    
    // Mark: - IBOutlet
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    // Mark: - IBAction
    @IBAction func button1(_ sender: UIButton) {
        if (label1.text == "Immediate") {
            label2.text = "ポイントゲットしましたー！"
        }
    }
    @IBAction func button2(_ sender: UIButton) {
        label2.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        // 距離精度
        // 精度を最高に設定する
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得感覚を設定
        // 1メートル離れたら位置情報を更新する
        locationManager.distanceFilter = 1
        
        // 位置情報の利用許可を確認
        let status = CLLocationManager.authorizationStatus()
        print("CLAuthorizedStatus: \(status.rawValue)")
        // 位置情報の利用ステータスがまだ設定されていない場合
        if (status == .notDetermined) {
            // バックグラウンドも常に許可に変更する
            locationManager.requestAlwaysAuthorization()
        }
        
    }
    
    private func startMyMonitoring() {
        // ビーコン領域(発信を行うオブジェクト)生成
        guard let uuid = UUID(uuidString: uuidString) else {return}
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: beaconIdentifier)
        // デフォルト設定
        // リージョンに入ったときと出たときに通知が来る
        // ディスプレイがオフのときでも通知がくる
        beaconRegion.notifyEntryStateOnDisplay = false
        // 入域通知の設定
        beaconRegion.notifyOnEntry = true
        // 退域通知の設定
        beaconRegion.notifyOnExit = true
        // モニタ開始
        locationManager.startMonitoring(for: beaconRegion)
    }
    // Mark: - delegateメソッド
    // ステータスの設定条件による処理の分岐
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChanngeAuthorizationStatus")
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
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
            print("authorizedWAhenInUse")
            startMyMonitoring()
            break
        }
    }
    // viewdidload() - startMonitoring(for:)が開始されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 領域の内部にいるかの判定
        manager.requestState(for: region);
    }
    
    
    // requestStateが呼ばれると非同期で呼ばれる
    // 現在リージョン内にいるかどうかの通知(結果)を受け取る
    // 結果はstateの中に入っている
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch(state) {
        case .inside:
            print("リージョン内に入っている")
            // CLBeaconRegionオブジェクトのもつ情報の取得
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
    
    // startRangingBeaconsが呼ばれると呼ばれる
    // リージョン内にあるビーコンが検知され、引数beaconsに格納して渡されている
    // regionが開始されると1秒ごとに呼ばれるため、beaconsの中にbeaconある場合のみ処理を実行する
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            print("beaconsの中身: \(beacons)")
            let beacon = beacons[0]
            print(beacon.proximityUUID)
            print(beacon.major)
            print(beacon.minor)
            print(beacon.rssi)
            
        }
        
    }
    
    // Mark: IN/OUT検知 - delegate
    // IN - 領域内に入った際に通知
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("リージョンに入った")
        // CLBeaconRegionオブジェクトの持つ情報の取得
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        // ユーザーの位置情報を更新して確認
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("リージョンから出た")
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    // 監視エラー
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("監視でエラー")
        print("error内容：\(error)")
    }
    
}

