# -Eodiyeo-
자꾸 까먹는 당신을 위한, 약속 - 위치 알림 앱 [어디여] 

![Simulator Screenshot - iPhone 15 - 2024-01-05 at 12 47 40](https://github.com/jinyongyun/Eodiyeo/assets/102133961/ca2619e5-c5a8-4a8b-bff4-0425dcba654d)| ![Simulator Screenshot - iPhone 15 - 2024-01-05 at 12 50 47](https://github.com/jinyongyun/Eodiyeo/assets/102133961/37a8d501-86cc-459d-9ce2-6c8b60f3d200)| ![Simulator Screenshot - iPhone 15 - 2024-01-05 at 12 51 01](https://github.com/jinyongyun/Eodiyeo/assets/102133961/7bcf7802-c637-42a8-ad5b-c344f0cb4345)| 실제구동화면
----- | ----- | ----- | -----

## 구성 및 맡은 역할

**개인 프로젝트**

## 개요

- 사용자가 위치와, 해당 위치에서 진행해야 할 일을 입력하면
- 테이블 뷰에 해당 할 일 목록들이 나타난다(이는 하나하나가 Notification이므로 스위치로 제어할 수 있다)
- 전체 목록에 맞는 마커(Marker)가 전체 지도 상에 나타난다.
- 지도상에서 해당 마커를 클릭하게 되면 사용자가 입력한 ‘할 일’을 볼 수 있다.
- 해당 위치 인근에 도달하거나 멀어지면 로컬 알림으로 해야 할 일을 까먹지 않도록 알려준다.

## 개발배경.

***자꾸 어디 가서 뭐 해야 할 지를 잊어버려서 만들었다. (개인적으로 강렬하게 필요했다.)***

## 앱스토어

[‎어디여](https://apps.apple.com/kr/app/어디여/id6475540191)

## 구현기능

<img width="1792" alt="스크린샷 2024-01-05 오후 3 08 38" src="https://github.com/jinyongyun/Eodiyeo/assets/102133961/5aeb93f8-3933-4dc0-87d4-6523c3b538f6">


- 위치 검색 (위치 정보를 입력하면 자동완성)
    - 사용자가 입력한 위치이름으로 해당 위치 정보를 알아낼 수 있다.
- 할 일 목록 작성
    - 해야 할 일을 작성하고, 테이블 뷰 자체에서 삭제할 수 있다.
- 전체 맵
    - 사용자 위치를 중심으로 주위에 사용자가 기록한 할 일 마커를 보여줄 수 있다.
- 인근 위치 알림
    - 사용자가 기록한 할 일의 위치 인근에 도착했을 때 로컬 알림을 받을 수 있다.

## 고민 & 구현 방법

### 알림 추가화면에서 새로운 alert을 어떻게 상위 뷰(테이블 뷰 컨트롤러)로 넘겨줄까

- 해결방법
    
    많이들 쓰는 방법으로 클로져 함수를 통해 넘겨줄 수 있다.
    
    - AddAlertViewController
    
    ```swift
    // 클로저 함수 선언
    var pickedNewAlert: ((_ location: String, _ shortterm: String, _ content: String, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> Void)?
    ...
    
    // 저장 버튼에서 dismiss하기 전에 해당 클로저 함수를 실행해준다. 실제 구현은 상위 뷰 컨트롤러(AlertListViewController)에서 해줬다.
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
            pickedNewAlert?(locationTextField.text ?? "내용 없음", shortTerm.text ?? "내용 없어", detailTextView.text, latitude ?? 0.0, longitude ?? 0.0)
            self.dismiss(animated: true, completion: nil)
        }
    ```
    
    - AlertListViewController
    
    ```swift
    @IBAction func addAlertButtonAction(_ sender: UIBarButtonItem) {
            guard let addAlertVC = storyboard?.instantiateViewController(identifier:
            "AddAlertViewController") as? AddAlertViewController else {return}
            
            addAlertVC.pickedNewAlert = { [weak self] location, shortterm, content, latitude, longitude in
                guard let self = self else {return}
                var alertList = self.alertList()
                let newAlert = Alert(location: location, shortterm: shortterm, content: content, latitude: latitude, longitude: longitude, isOn: true)
                alertList.append(newAlert)
                
                self.alerts = alertList
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts") //여기서 새로운 alert UserDefaults에 추가
                self.userNotificationCenter.addNotificationRequest(by: newAlert)
                
                self.tableView.reloadData()
            }
            
            self.present(addAlertVC, animated: true, completion: nil)
        }
    
    func alertList() -> [Alert] {
            guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
                  let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return []}
            return alerts
        }
    ```
    
    instantiateViewController를 통해 하위 뷰 컨트롤러(위에서 보았던 AddAlertViewController)를 인스턴스화 시키고(그래야 멤버 접근 가능), 클로저 함수를 구현한다. 순환참조방지를 위해 weak self 붙여주고 
    
    내부 한정 강한 참조를 위해 guard let self = self else {return}을 구현해줬다.
    
    여기서 alertList() 함수가 등장하는데, 
    
    UserDefaults에서 키 alerts로 alert 배열 꺼내오는 함수이다. 당연히 우리가 따로 만들어 준 alert 구조체이므로 decode 해줘야 한다.
    
    alertList 변수에 alertList()를 이용해 alert배열을 넣어주고, 새롭게 만들어 준 Alert 객체를 append한다.
    
    해당 alert 배열을 다시 UserDefaults에 저장해주면 끝!
    

---

### 계속해서 업데이트 되는 알림들의 상태(위치와 이름, 정보, on/off)를 어떻게 관리할까

- 해결방법
    
    앱을 껐다 켜도 정보가 유지되어야 하니, UserDefaults를 사용해 alerts 즉 alert으로 이루어진 배열을 만들었다. 우리 앱에서는 정확히 두 군데에서 notification이 탄생하고 소멸하는데, 한 곳은 위에서 구현했던 pickedNewAlert 클로저 함수고, 두 번째는 할 일 리스트 cell에 있는 스위치의 값이 변할 때이다.
    
    ```swift
    @IBAction func alertSwitchValueChanged(_ sender: UISwitch) {
            guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
                  var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else {return}
            
            alerts[sender.tag].isOn = sender.isOn
            UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")
            
            if sender.isOn {
                userNotificationCenter.addNotificationRequest(by: alerts[sender.tag])
            } else {
                userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
            }
        }
    ```
    
    AlertListCell.swift에서 스위치 값이 변했을 때의 액션 함수인 alertSwitchValueChanged에서 
    
    UserDefaults에서 alerts을 키로 한 alert 배열을 가져와서(물론 디코드 해야 함)
    
    매개변수인 sender에서  tag값으로 indexpath.row 처럼 값이 바뀐 스위치의 cell index를 파악해 isOn 처리해줬다. 그럼 이 tag는 어디서 설정해줬냐
    
    바로 위에서도 나왔던, UITableViewController를 상속한 AlertListViewController이다. 
    
    여기서 cellForRowAt 메서드를 구현할 때, 다음과 같이  cell.alertSwitch.tag  = indexPath.row 를 설정해줬다.
    
    ```swift
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListCell", for: indexPath) as? AlertListCell else {return UITableViewCell()}
            
            cell.alertSwitch.isOn = alerts[indexPath.row].isOn
            cell.locationLabel.text = alerts[indexPath.row].location
            cell.shorttermLabel.text = alerts[indexPath.row].shortterm
            cell.alertSwitch.tag  = indexPath.row
            
            return cell
            
        }
    ```
    

---

### 어떻게 search bar를 addAlertViewController에 추가하나, 위치 자동 완성 검색은 어떻게 구현하나

- 해결방법
    
    [Interacting with nearby points of interest | Apple Developer Documentation](https://developer.apple.com/documentation/mapkit/mapkit_for_appkit_and_uikit/interacting_with_nearby_points_of_interest)
    
    위에 문서 참조
    
    ### TableView 와 SearchBar를 생성해준다.
    
    Storyboard에서 TableView와 SearchBar를 아래 사진과 같이 생성해준다.
    
    (tableview에 datasoruce와 delegate 설정해주고 searchbar에도 delegate를 설정한다.)
    
    ```swift
    //
    //  locationCell.swift
    //  Eodiyeo
    //
    //  Created by jinyong yun on 1/3/24.
    //
    
    import UIKit
    
    class locationCell: UITableViewCell {
    
        @IBOutlet weak var titleLabel: UILabel!
        
        @IBOutlet weak var subtitleLabel: UILabel!
    }
    ```
    
    ### 변수 선언
    
    **MapKit**을 import 해준 후 tableView와 searchbar를 Outlet으로 연결한다.
    
    ```swift
    //
    //  FindLocationViewController.swift
    //  Eodiyeo
    //
    //  Created by jinyong yun on 1/3/24.
    //
    
    import UIKit
    import MapKit
    
    class FindLocationViewController: UIViewController {
    
        @IBOutlet weak var tableView: UITableView!
        @IBOutlet weak var searchbar: UISearchBar!
    
    ```
    
    ### 구현 순서
    
    - SearchBar에 입력된 문자열을 searchCompleter에게 넘긴다.
        - searchCompleter: MKLocalSearchCompleter // 검색을 도와주는 변수
    - 해당 문자열을 포함하는 Location 정보를 completerResults에 담는다.
        - completerResults: [MKLocalSearchCompletion] // 검색한 결과를 담는 변수
    - tableView에 completerResults를 표현한다.
    - tableView에 cell을 선택하면 해당 Location의 정보(위도, 경도 등)을 가져온다.
    
    ### 이외에 필요한 변수
    
    - searchRegion: MKCoordinateRegion // 검색 지역 범위를 결정하는 변수
    - places: MKMapItem // tableView에서 선택한 Location의 정보를 담는 변수
    - localSearch: MKLocalSearch? // tableView에서 선택한 Location의 정보를 가져오는 변수
        - 지도 기반 검색과 그 결과를 관리하는 유틸리티 object
    
    ```swift
     private var searchCompleter: MKLocalSearchCompleter?
        
        private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
        
        var completerResults: [MKLocalSearchCompletion]?
        
        private var places: MKMapItem? {
            didSet {
                tableView.reloadData()
            }
        }
        
        private var localSearch: MKLocalSearch? {
            willSet {
                // Clear the results and cancel the currently running local search before starting a new search.
                places = nil
                localSearch?.cancel()
            }
        }
    ```
    
    ### searchCompleter 정의 (검색을 도와주는 변수 MKLocalSearchCompleter 타입)
    
    resultType은 검색할 유형을 나타낸다.
    
    - address : 주소를 검색하고 싶어
    - pointOfInterest : 건물과 같은 특정 지점 검색 (**이걸로 선택했다. 주로 할 일을 특정 목적지에서 발생**)
    - query : 모든 결과 검색
    
    region은 검색할 지역 범위를 나타낸다.
    
    ```swift
    //위에서 이렇게 선언
    private var searchRegion: MKCoordinateRegion = MKCoordinateRegion(MKMapRect.world)
    ```
    
    Completer 개체는 수명이 긴 개체이므로 **강력한 참조**를 하기 때문에
    
    viewDidDisappear에서 참조를 해제 해준다.
    
    ```swift
       override func viewDidLoad() {
            super.viewDidLoad()
            
            searchCompleter = MKLocalSearchCompleter()
            searchCompleter?.delegate = self
            searchCompleter?.resultTypes = .pointOfInterest 
            searchCompleter?.region = searchRegion
            
            searchBar.delegate = self
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            **searchCompleter = nil //여기서 참조 해제**
        }
    ```
    
    ### SearchBar Delegate 구현
    
    searchCompleter?.queryFragment에 SearchBar에 입력된 값을 넘겨준다.
    
    queryFragment에 자동 완성이 되길 원하는 String을 넣으면 된다.
    
    - ***Apple 공식문서 설명***
    
    > Assigning a string to this property initiates a search based on that string. The completer object waits a short amount of time before initiating new searches. This delay gives you enough time to update the search string based on typed input from the user.
    > 
    
    ```swift
    extension FindLocationViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText == "" {
                completerResults = nil
            }
            
            searchCompleter?.queryFragment = searchText
        }
    }
    ```
    
    ### MKLocalSearchCompleterDelegate 구현
    
    searchCompleter?.queryFragment에 들어온 값을 토대로 Location을 검색한다.
    
    func completerDidUpdateResults에 completer.results를 통해 검색한 결과를 completerResults에 담는다.
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error)를 통해 에러를 확인하면 된다.
    
    ```swift
    extension ViewController: MKLocalSearchCompleterDelegate {
        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            completerResults = completer.results
            tableView.reloadData()
        }
    
        func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
            if let error = error as NSError? {
                print("MKLocalSearchCompleter encountered an error: \(error.localizedDescription). The query fragment is: \"\(completer.queryFragment)\"")
            }
        }
    }
    ```
    
    ### UITableViewDataSource 구현
    
    completerResult의 값을 tableView에 나타낸다.
    
    title은 관심 지점과 관련된 제목 문자열이다.
    
    subtitle은 관심 지점과 관련된 부제목 문자열.
    
    ```swift
    extension ViewController: UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return completerResults?.count ?? 0
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? Cell else { return UITableViewCell()}
    
            if let suggestion = completerResults?[indexPath.row] {
                cell.titleLabel.text = suggestion.title
                cell.subtitleLabel.text = suggestion.subtitle
            }
            return cell
        }
    }
    ```
    
    이렇게 검색부분은 끝났다!! (소리질러)
    
    그럼 이제 tableView의 Cell을 선택했을 때 Location의 정보를 가져와 보자.
    
    ### UITableViewDelegate 구현
    
    ### 1. tableView에서 선택한 completerResults 값을 가져온다.
    
    ```swift
    extension ViewController: UITableViewDelegate{
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true) // 선택 표시 해제
    
            if let suggestion = completerResults?[indexPath.row] {
                search(for: suggestion)
            }
        }
    }
    ```
    
    ### 2. 1번의 값을 토대로 MKLocalSearch.Request를 생성한다.
    
    ```swift
    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }
    ```
    
    ### 3. 2번의 값을 토대로 MKLocalSearch를 생성한다.
    
    ### 4. MKLocalSearch의 start함수를 사용하여 검색을 시작하여 정보를 가져옵니다.
    
    ```swift
    private func search(using searchRequest: MKLocalSearch.Request) {
            // 검색 지역 설정
            searchRequest.region = searchRegion
            
            // 검색 유형 설정
            searchRequest.resultTypes = .pointOfInterest
            // MKLocalSearch 생성
            localSearch = MKLocalSearch(request: searchRequest)
            // 비동기로 검색 실행
            localSearch?.start { [unowned self] (response, error) in
                guard error == nil else {
                    return
                }
                // 검색한 결과 : reponse의 mapItems 값을 가져온다.
                self.places = response?.mapItems[0]
                
                print(places?.placemark.coordinate as Any) // 위경도 가져옴
                searchBar.text = places?.name
                pickedNewLocation?(searchBar.text ?? "잘못된 위치", places?.placemark.coordinate.latitude ?? 0.0, places?.placemark.coordinate.longitude ?? 0.0)
                dismiss(animated: true, completion: nil)
            }
        }
    ```
    
    ### pickedNewLocation은 이전 화면인 AddAlertViewController로 위경도 값을 넘겨주는 클로저 함수!
    
    ```swift
    FindLocationVC.pickedNewLocation = { [weak self] location, latitude, longitude in
                guard let self = self else {return}
                self.locationTextField.text = location
                mark = Marker(title: location, subtitle: location, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                mapView.addAnnotation(mark)
                // 중심값(필수): 위, 경도
                let center = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
    
                // 영역을 확대 및 축소를 한다. (값이 낮을수록 화면을 확대/높으면 축소)
                let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                            longitudeDelta: 0.01)
    
                // center를 중심으로 span 영역만큼 확대/축소 해서 보여줌
                let region = MKCoordinateRegion(center: center,
                                                span: span)
    
                mapView.setRegion(region, animated: true)
                self.latitude = Double(latitude)
                self.longitude = Double(longitude)
                
                
            }
    ```
    

---

### MKMapView에 마커 표시는 어떻게 하나

- 해결방법
    
    ```swift
    //
    //  Marker.swift
    //  Eodiyeo
    //
    //  Created by jinyong yun on 1/3/24.
    //
    
    import MapKit
    
    class Marker: NSObject, MKAnnotation {
      let title: String?
      let coordinate: CLLocationCoordinate2D
      let subtitle:String?
    
      init(
        title: String?,
        subtitle: String?,
        coordinate: CLLocationCoordinate2D
      ) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
      }
    
    }
    ```
    
    다음과 같이, NSObject와 MKAnnotation을 상속한 Marker 클래스를 먼저 구현해야 한다.
    
    공식문서에 따르면 멤버로 들어갈 수 있는 변수로 color, title, coordinate, subtitle 등이 있다. 여기서 적절하게 원하는 것만 뽑아 초기화 함수를 구성한다.
    
    ```swift
    mark = Marker(title: location, subtitle: location, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
    mapView.addAnnotation(mark)
    ```
    
    그런 다음 위와 같이 marker 객체를 만들어 준 다음, mapView에 addAnnotation 메서드를 이용해 마커를 추가한다. 물론 전체 화면에 마커만 추가되는 형식이라 확대와 중심 잡는 건 따로 해줘야 한다.
    
    ```swift
    // 중심값(필수): 위, 경도
                let center = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
    
                // 영역을 확대 및 축소를 한다. (값이 낮을수록 화면을 확대/높으면 축소)
                let span = MKCoordinateSpan(latitudeDelta: 0.01,
                                            longitudeDelta: 0.01)
    
                // center를 중심으로 span 영역만큼 확대/축소 해서 보여줌
                let region = MKCoordinateRegion(center: center,
                                                span: span)
    
                mapView.setRegion(region, animated: true)
    ```
    

---

### 해당 반경 중심으로, 반경에 들어오면 알리는 위치 기반 트리커는 어떻게 설정할까

- 해결방법
    
    **물 마시기 알람 앱**에서 배운 걸 활용했다.
    
    UNUserNotificationCenter를 확장한 파일을 만들고
    
    함수 addNotificationRequest를 만들어준다. (UNUserNotification 함수에 NotificationRequest를 추가하는 함수. 매개변수는 alert, 새로운 alert을 매개변수에 넣어주면 되겠다.)
    
    우선 Notification의 content를 구성하고(제목, 내용, 사운드, 뱃지표현 등)
    
    다음으로는 trigger를 구성한다. 어떤 지점을 중심으로 특정 반경만큼에 들어서거나, 나갈 때 로컬 알림이 발생되어야 하므로
    
    먼저 중심위치부터 잡는다. CLLocationCoordinate2D 객체로 매개변수 alert의 위경도를 이용한다.
    
    ```swift
     let center = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
    ```
    
    그 다음 해당 center를 중심으로 한 반경 영역을 만들어준다. radius로 반경 50m를 경계로 지어줬다.
    
    ```swift
    let region = CLCircularRegion(center: center, radius: 50.0, identifier: "\(alert.location)")
      region.notifyOnEntry = true // 반경에 들어올 때 알림 발생
      region.notifyOnExit = true // 반경에서 나갈 때 알림 발생
    ```
    
    region을 넣어준 트리거를 완성한다. (repeats은 alert의 스위치가 켜있는 동안 발생되어야 하니까 isOn)
    
    ```swift
    let trigger = UNLocationNotificationTrigger(region: region, repeats: alert.isOn)
    ```
    
    UNRequest를 구성하는데 필요한 삼신기(?) id, content, trigger가 전부 있으니, 이젠 UserNotificationRequest를 작성할 수 있다. 
    
    ```swift
     let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
     self.add(request, withCompletionHandler: nil) //self==UNUserNotificationCenter 즉 NotificationCenter에 해당 UNRequest를 추가
    ```
    
    아래는 전체 코드이다.
    
    ```swift
    //
    //  UNNotificationCenter.swift
    //  Eodiyeo
    //
    //  Created by jinyong yun on 1/4/24.
    //
    
    import Foundation
    import UserNotifications
    import CoreLocation
    
    extension UNUserNotificationCenter {
        
        func addNotificationRequest(by alert: Alert) {
                
                let content = UNMutableNotificationContent()
                content.title = "🤦🏻 \(alert.location)에서 뭐 하기로 혔슈?"
                content.body = "\(alert.shortterm)하기로 했잖유 기억나유?"
                content.sound = .default
                content.badge = 1
                
                let center = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
                let region = CLCircularRegion(center: center, radius: 50.0, identifier: "\(alert.location)")
                region.notifyOnEntry = true
                region.notifyOnExit = true
                let trigger = UNLocationNotificationTrigger(region: region, repeats: alert.isOn)
            
                let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
                self.add(request, withCompletionHandler: nil)
            
        }
        
    }
    ```
    

---

### 위치 기반 트리거를 등록했는데 왜 알림이 안오냐

- 해결방법
    
    위에서 설명했던 것처럼 트리거를 등록해줬는데, 정작 테스트 시행에서 알림이 날아오지 않았다.
    
    > 설마 우리 집이랑 내가 표시한 마커가 50m가 넘어가지 않아서 그런가?
    > 
    
    라고 생각해 집 밖으로 열심히 나돌아다녀봤으나 결과는 같았다. 
    
    (시뮬레이터 상에서 local 위치를 바꿔 테스트 해보기도 했다.)
    
    아니 분명 처음으로 테스트 했을 때는 성공했었는데….
    
    **라고 생각할 찰나 머리에 빛이 번뜩했다. (like 코난)**
    
    생각해보니, 처음 시도는 마커가 하나일 때!
    
    지금은 마커 여러개를 설정하고 움직이고 있으니, 아마도 마커에 문제가 있을 것이다.
    
    ```swift
    extension UNUserNotificationCenter {
        
        func addNotificationRequest(by alert: Alert) {
                
                let content = UNMutableNotificationContent()
                content.title = "🤦🏻 \(alert.location)에서 뭐 하기로 혔슈?"
                content.body = "\(alert.shortterm)하기로 했잖유 기억나유?"
                content.sound = .default
                content.badge = 1
                
                let center = CLLocationCoordinate2D(latitude: alert.latitude, longitude: alert.longitude)
                **let region = CLCircularRegion(center: center, radius: 50.0, identifier: "location")**
                region.notifyOnEntry = true
                region.notifyOnExit = true
                let trigger = UNLocationNotificationTrigger(region: region, repeats: alert.isOn)
            
                let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)
                self.add(request, withCompletionHandler: nil)
            
        }
        
    }
    ```
    
    위에서 설명했던 해당 UNUserNotification의 extension 파일이다. 여기서 region 설정 당시 identifier 부분이 사실은 저렇게 location 하나로 통일되어 있었다. 
    
    이게 문제다! 싶었다. location이 구분되지 않으니 경계도 의미가 없어진 것이다.
    
    해당 부분을 identifier: “\(alert.location)”  으로 고치니, 역시나 제대로 알림이 동작하기 시작했다. 
    

---

## 앱 심사 reject 해결

### guideline 5.1.1 - legal - privacy - data collection and storage

- 해결방법
    
    두근거리는 마음으로 심사 요청을 날렸는데…
     반려당했다.
  
    그래 이제는 익숙한 그녀석 guideline 5.1.1이다.
    
    권한 요청 알림에 나타나는 상세 메세지를 더 상세하게 쓰라는 요청이다.
    
    그런데 문제는…난 이미 상세하게 작성했는데??
    
    저번 앱에서도 같은 reject 사유를 받아서, 이미 info.plist에 알림에 대한 메세지를 상세하게 적어놓은 상태였다. 이제 문제는 상세하게 적는 것이 아니라, 왜 info.plist가 적용이 안되는 가-로 바뀌었다.
    
    열심히 구글을 뒤져봐도 안나오길래…혹시나 하는 마음으로 앱 설정으로 들어가봤다.
    
    혹시나 여기도 info.plist 관련한 무언가가 있지 않을까?
    
    역시나 info.plist Values가 이전에 설정한 값으로 되어있고, info.plist에 입력한 값이 업데이트가 안되어있었다. 해당 Value를 바꿔주니 알림에 문구가 제대로 적용됐다.
    

---

## 앱 소개



https://github.com/jinyongyun/Eodiyeo/assets/102133961/5704fe1f-e1fe-446e-bb88-49acfa5f9578



아이폰 화면 녹화로 진행하다 보니, 화질이 조금 떨어진다.

동네를 열심히 돌아다니면서 알림이 오나 안오나

어느 시점에 오나 확인했다. 아래는 실제 알림이 도착한 모습이다.

![Simulator Screenshot - iPhone 15 Plus - 2024-01-05 at 13 12 35](https://github.com/jinyongyun/Eodiyeo/assets/102133961/38e8bddd-aa28-4b6c-8afe-ce023d16c61e)

