#include <M5StickCPlus.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#define ANALOG_PIN 36
#define SERVICE_UUID        "d746652e-9557-11ec-b909-0242ac120002"
#define CHARACTERISTIC_UUID "d746688a-9557-11ec-b909-0242ac120002"

BLECharacteristic* pCharacteristic;
int R1 = 10;

void setup() {
  initM5();
  M5.Lcd.print("Setup....");
  initBLE();
  M5.Lcd.println("Done");
}

void loop() {
  M5.update();
  int val = analogRead(ANALOG_PIN);

  int weight = calculateWeight(val);
  Serial.println(val);
  sendMessage(weight);
  delay(1000);
}

void initM5() {
  M5.begin();
  pinMode(ANALOG_PIN, INPUT);
  gpio_pulldown_dis(GPIO_NUM_25);
  gpio_pullup_dis(GPIO_NUM_25);
  M5.Lcd.setRotation(3);
  M5.Lcd.setTextSize(2);
  M5.Lcd.fillScreen(BLACK);
}

void initBLE() {
  BLEDevice::init("ESP32 Bluetooth Server");
  BLEServer* pServer = BLEDevice::createServer();
  BLEService* pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_NOTIFY);
  pService->start();
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void sendMessage(int v) {
  char str[30];
  sprintf(str, "%d", v);
  pCharacteristic->setValue(str);
  pCharacteristic->notify();
}

int calculateWeight(int data) {
  double Vo, Rf, fg;
  // analogRead -> 出力電圧
  Vo = data * 3.3 / 4095;
  if (Vo == 0) {
    fg = 0;
  } else {
    // 出力電圧 -> FRSの抵抗値
    Rf = R1 * Vo / (3.3 - Vo);
    fg = 880.79 / Rf + 47.96;
  }
  return fg;
}
