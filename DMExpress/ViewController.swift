//
//  ViewController.swift
//  DMExpress
//
//  Created by Narlei A Moreira on 07/02/19.
//  Copyright © 2019 Narlei A Moreira. All rights reserved.
//

import BringgTracking
import UIKit
import MapKit
import ARCarMovement
import GoogleMaps
import Kingfisher
let token = "token"


class ViewController: UIViewController{
    var trackClient: BringgTrackingClient!
    var movement : ARCarMovement?
    var driverMarker : GMSMarker?
    //@property (strong, nonatomic) NSMutableArray CoordinateArr;
    
    @IBOutlet weak var imageDriver: UIImageView!
    @IBOutlet weak var nameOrder: UILabel!
    @IBOutlet weak var rateDrive: RatingControl!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var nameDriver: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    
    var oldCoordinate : CLLocationCoordinate2D?
    var timer : Timer?
    var counter : NSInteger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        trackClient = BringgTrackingClient(developerToken: token, connectionDelegate: self)
        
        trackClient.connect()
        
        movement = ARCarMovement()
        movement?.delegate = self

        self.oldCoordinate = CLLocationCoordinate2DMake(-29.6817622,-53.8101526)
    
        let camera = GMSCameraPosition.camera(withLatitude: -29.6817622, longitude: -53.8101526, zoom: 16)
        //mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.camera = camera
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        
        // Creates a marker in the center of the map.
        //
        driverMarker = GMSMarker(position: oldCoordinate!)
        driverMarker?.icon = UIImage(named: "icMotocycleBig")
        driverMarker?.map = mapView
        

    }
    func drawMap(latitude: Double, longitude: Double){
        let newCoordinate = CLLocationCoordinate2DMake(latitude,longitude)
        
        /**
         *  You need to pass the created/updating marker, old & new coordinate, mapView and bearing value from backend
         *  to turn properly. Here coordinates json files is used without new bearing value. So that
         *  bearing won't work as expected.
         */
        self.movement?.ARCarMovement(marker: driverMarker!, oldCoordinate: oldCoordinate!, newCoordinate: newCoordinate, mapView: mapView, bearing: 0)
         //instead value 0, pass latest bearing value from backend
        
        self.oldCoordinate = newCoordinate;
        print("@@@driverLocationDidChange \(latitude)  \(longitude)")
    }
    func showRateOrder(order: GGOrder){
        let alert = UIAlertController(title: "Deseja avaliar seu pedido?", message: "De 1 a 5, qual sua nota?", preferredStyle: .alert)
        var rate = 0
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Exemplo: 5"
            textField.keyboardType = .numberPad
        })
        let nopButton = UIAlertAction(title: "Não", style: .cancel, handler: nil)
        let okButton = UIAlertAction(title: "Sim", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields![0]{
                rate = Int(textField.text!) ?? 0
            }
            
            if rate != 0 {
                self.trackClient.rateOrder(order, withRating: Int32(rate), completionHandler: { (success, data, rating, error) in
                    if success {
                        UIAlertController.presentInfoAlert(viewController: self, title: "Parabéns!!", message: "Avaliação enviada com sucesso", completion: nil)
                    }
                })
                
            }
        })
        alert.addAction(nopButton)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: ARCarMovementDelegate{
    func ARCarMovementMoved(_ Marker: GMSMarker) {

        driverMarker = Marker
        let point = mapView?.projection.point(for: (driverMarker?.position)!)
        let camera = mapView?.projection.coordinate(for: point!)
        let position = GMSCameraUpdate.setTarget(camera!)

        driverMarker?.map = self.mapView
        //animation to make car icon in center of the mapview
        mapView?.animate(with: position)
    }
    
}
extension ViewController: GMSMapViewDelegate{
    
}
extension ViewController: RealTimeDelegate {
    func trackerDidConnect() {
        print("Connected")
        trackClient.startWatchingOrder(withUUID: "order_uuid", customerAccessToken: token, delegate: self)
    }

    func trackerDidDisconnectWithError(_ error: Error?) {
        print("@@@trackerDidDisconnectWithError \(String(describing: error))")
    }
}
extension ViewController: DriverDelegate{
    func watchDriverSucceed(for driver: GGDriver?) {
        print("@@@watchDriverSucceed \(driver?.name)  \(driver?.ratingUrl)")
        
    }
    
    func watchDriverFailed(for driver: GGDriver?, error: Error) {
        print("@@@watchDriverFailed \(String(describing: driver))")
    }
    
    func driverLocationDidChange(with driver: GGDriver) {
        drawMap(latitude: driver.latitude, longitude: driver.longitude)
    }
}
extension ViewController: OrderDelegate {

    func watchOrderSucceed(for order: GGOrder) {
        self.nameOrder.text = "\(order.title ?? "...") - R$ \(order.totalPrice)"
        if let lat = (order.waypoints[0] as AnyObject).lat, let lng = (order.waypoints[0] as AnyObject).lng {
            drawMap(latitude: lat, longitude: lng)
        }
        print("@@@watchOrderSucceed: \(order)")
    }

    func watchOrderFail(for order: GGOrder, error: Error) {
        print("@@@watchOrderFail: \(error)")
    }

    func orderDidAssign(with order: GGOrder, with driver: GGDriver) {
        self.orderStatus.text = "order atribuido"
        print("@@@orderDidAssign: \(driver)")
        if let shereduuid = order.sharedLocationUUID{
            print("@@@sharedLocationUUID: \(shereduuid)")
            trackClient.startWatchingDriver(withUUID: driver.uuid, shareUUID: shereduuid, delegate: self)
        }
    }

    func orderDidAccept(with order: GGOrder, with driver: GGDriver) {
        self.orderStatus.text = "pedido aceito"
        print("@@@orderDidAssign: \(driver.name)")
        if let shereduuid = order.sharedLocationUUID{
            print("@@@sharedLocationUUID: \(shereduuid)")
            trackClient.startWatchingDriver(withUUID: driver.uuid, shareUUID: shereduuid, delegate: self)
        }
    }

    func orderDidStart(with order: GGOrder, with driver: GGDriver) {
        self.orderStatus.text = "pedido iniciado"
        self.nameDriver.text = driver.name
        if let image = driver.imageURL {
            imageDriver.kf.setImage(
                with: URL(string: image),
                placeholder: UIImage(named: "icMotocycleBig"),
                options: nil,
                progressBlock: nil,
                completionHandler: nil)
        }
        rateDrive.rating = driver.averageRating <= 5 ? driver.averageRating : 5
        print("@@@orderDidStart: \(driver)")
        if let shereduuid = order.sharedLocationUUID{
            print("@@@sharedLocationUUID: \(shereduuid)")
            trackClient.startWatchingDriver(withUUID: driver.uuid, shareUUID: shereduuid, delegate: self)
        }
    }
    
    func orderDidFinish(_ order: GGOrder, with driver: GGDriver) {
        self.orderStatus.text = "pedido finalizado"
        trackClient.stopWatchingAllDrivers()
        print("@@@orderDidFinish: \(order)")
    }
    
    func orderDidArrive(_ order: GGOrder, with driver: GGDriver) {
        self.orderStatus.text = "pedido entregue"
        showRateOrder(order: order)
        trackClient.stopWatchingAllDrivers()
        print("@@@orderDidArrive \(order)")
    }
    
    func orderDidCancel(_ order: GGOrder, with driver: GGDriver?) {
        self.orderStatus.text = "pedido cancelado"
        trackClient.stopWatchingAllDrivers()
        print("@@@orderDidCancel \(order)")
    }
    func order(_ order: GGOrder, didUpdate sharedLocation: GGSharedLocation?, findMeConfiguration: GGFindMe?) {
        print("@@@order with ID \(order.orderid) did update shared location \(sharedLocation!.locationUUID ?? "" ) find me configuration to \(String(describing: findMeConfiguration))")
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}

extension UIAlertController{
    static func presentInfoAlert(viewController: UIViewController,
                                 title: String?,
                                 message: String?,
                                 completion: (() -> Void)?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alertController, animated: true, completion: completion)
    }
}

