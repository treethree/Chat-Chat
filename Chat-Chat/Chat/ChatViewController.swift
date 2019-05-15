import UIKit
import CoreBluetooth

class ChatViewController: UIViewController {
    
    var deviceUUID : UUID?
    var deviceAttributes : String = ""
    var selectedPeripheral : CBPeripheral?
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    var messages = Array<Message>()
    
    var componentsSet: Set<CBPeripheral> = []
    
    let cellDefinition = "ChatCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var bottomContainer: UIView!
    
    
    @IBAction func sendButtonClick(_ sender: Any) {
        if let msg =  messageTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) {
            if msg.isEmpty { return }
        }
        if(!(messageTextField.text?.isEmpty)!) {
           // centralManager?.connect(selectedPeripheral!, options: nil)
            for item in componentsSet
            {
                centralManager?.connect(item, options: nil)
            }
            messageTextField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 68.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib(nibName: cellDefinition, bundle: nil), forCellReuseIdentifier: cellDefinition)
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        messageTextField.delegate = self
        registerForKeyboardNotifications()
        
        setDeviceValues()
        sendButton.setTitle("_chat_send_button".localized, for: .normal)
    }
    
    func setDeviceValues() {
        
        let deviceData = deviceAttributes.components(separatedBy: "|")
        
        if (deviceData.count > 2) {
            
            self.navigationItem.title = deviceData[0]
            tableView.backgroundColor = Constants.colors[Int(deviceData[2])!]
        }
        
            
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    // Following methods are needed for pushing bottomContainer view up and down when keyboard is shown and hidden.
    func registerForKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        animateViewMoving(up: true, notification: notification)
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        
        animateViewMoving(up: false, notification: notification)
    }
    
    func animateViewMoving (up:Bool, notification :NSNotification){
        let movementDuration:TimeInterval = 0.3
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let moveValue = keyboardSize?.height ?? 0
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.bottomContainer.frame = bottomContainer.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    // end of keyboard animation related methods
    
    
    func updateAdvertisingData() 
    {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let userData = UserData()
        let advertisementData = String(format: "%@|%d|%d", userData.name, userData.avatarId, userData.colorId)
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[Constants.SERVICE_UUID], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    
    func initService() {
        
        let serialService = CBMutableService(type: Constants.SERVICE_UUID, primary: true)
        let rx = CBMutableCharacteristic(type: Constants.RX_UUID, properties: Constants.RX_PROPERTIES, value: nil, permissions: Constants.RX_PERMISSIONS)
        serialService.characteristics = [rx]
        
        peripheralManager.add(serialService)
    }
    
    func appendMessageToChat(message: Message)
    {
        // MARK: - FIRST FIX WAS HERE
        if messages.isEmpty {
            messages.append(message)
            tableView.reloadData()
            return
        }
        
        // MARK: - SECOND FIX HERE
        for item in messages
        {
            if item.text == message.text && item.text.isEmpty
            {
                return;
            }
        }
        
        // MARK: - ANIMATION IMPROVEMENTS
        messages.append(message)
        let lastRow = messages.count - 1
        let dir : UITableViewRowAnimation = message.isSent ? .right : .left
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: lastRow, section: 0)], with: dir)
        tableView.endUpdates()
        
        if lastRow > 0 {
            tableView.scrollToRow(at: IndexPath(row: lastRow, section: 0), at: .bottom, animated: true)
        }
        
    }
    
}

extension ChatViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //poweredOn means bluetooth on.
        if (central.state == .poweredOn){
            //discover Peripherals
            self.centralManager?.scanForPeripherals(withServices: [Constants.SERVICE_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        if peripheral.identifier.description.count > 0
        {
            let advertisementName = advertisementData[CBAdvertisementDataLocalNameKey]
            if advertisementName != nil
            {
                let ad = advertisementName as! String
                let components = ad.components(separatedBy: "|")
                if components.count == 3
                {
                    componentsSet.insert(peripheral)
                }
                print(componentsSet)
                print("----------------")
                
            }
            
        }
        
//        if (peripheral.identifier == deviceUUID) {
//
//           // selectedPeripheral = peripheral
//
//        }
    }
    
    //only handle specific peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        if componentsSet.contains(peripheral)
        {
            //peripheral is keep updating so we need set delegate everytime.
            peripheral.delegate = self
            peripheral.discoverServices(nil)
        }
    }
}

extension ChatViewController : CBPeripheralDelegate {
    
    func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if componentsSet.contains(peripheral)
        {
            for service in peripheral.services! {
                
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        
        for characteristic in service.characteristics! {
            
            let characteristic = characteristic as CBCharacteristic
            if (characteristic.uuid.isEqual(Constants.RX_UUID)) {
                if let messageText = messageTextField.text {
                    let data = messageText.data(using: .utf8)
                    peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                    appendMessageToChat(message: Message(text: messageText, isSent: true))
                    // MARK: - SHOULD CLEAR FIELD ON SEND
                    messageTextField.text = ""
                }
            }
        }
    }
}

extension ChatViewController : CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            
            initService()
            updateAdvertisingData()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
            for request in requests
            {
                if let value = request.value {
                    
                    let messageText = String(data: value, encoding: String.Encoding.utf8) as String!
                    appendMessageToChat(message: Message(text: messageText!, isSent: false))
                }
                self.peripheralManager.respond(to: request, withResult: .success)
            }
        }
  
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
    
    print("this \(peripheral) just received my message")
  }
}

extension ChatViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        return true
    }
    
}


extension ChatViewController: UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        
        if (message.isSent)
        {
            cell.receivedMessage.isHidden = true
            cell.sentMessage.isHidden = false
            cell.sentMessage.text = message.text
            cell.sentMessage.sizeToFit()
        }
        else {
            
            cell.sentMessage.isHidden = true
            cell.receivedMessage.isHidden = false
            cell.receivedMessage.text = message.text
            cell.receivedMessage.sizeToFit()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
}
