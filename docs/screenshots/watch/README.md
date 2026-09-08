# 워치 앱스토어 스크린샷

App Store Connect 의 watchOS 스크린샷 슬롯에 올리는 원본. 언어별로 한 벌씩이다.

- **규격**: 416 × 496 px — Apple Watch Series 10/11 (46mm). ASC 가 문서화한 워치 규격이라
  다른 크기로 자동 축소된다.
  ⚠️ Ultra 3(49mm) 시뮬레이터는 **422 × 514** 를 뱉는데 이건 ASC 규격 표에 없다. 쓰지 말 것.
- **기기**: Apple Watch Series 11 (46mm), watchOS 26.2 시뮬레이터
- **언어**: `ko/`, `en/` — 같은 화면 같은 순서. 새 언어를 늘리면 폴더도 는다
  (`deploy.env` 의 `LOCALES` 참고).

| 파일 | 화면 | 파는 것 |
|---|---|---|
| `01-duration.png` | 시간 설정 다이얼 | 손목에서 바로 건다 |
| `02-prealerts.png` | 예비 알림 3개(1·3·10분) 선택 | **이 앱의 이유** — 끝나기 전에 여러 번 |
| `03-running.png` | 실행 중 둥근 사각 링 (구간 4개) | 기본 시계 앱과 다른 화면 |
| `04-finished.png` | 종료 + 확인 버튼 | 확인할 때까지 알린다 |

## 다시 찍는 법

```bash
W=<46mm 워치 시뮬레이터 UDID>
xcodebuild -project Rereminder.xcodeproj -scheme RereminderWatch -configuration Debug \
  -destination "platform=watchOS Simulator,id=$W" -derivedDataPath build/watchdd build
xcrun simctl install $W build/watchdd/Build/Products/Debug-watchsimulator/RereminderWatch.app
xcrun simctl launch  $W com.xa.toki.watchkitapp -AppleLanguages '(ko)' -AppleLocale ko_KR   # en 은 '(en)'
xcrun simctl io      $W screenshot ko/01-duration.png
```

- ⚠️ **워치 시뮬레이터를 아이폰과 페어링해 둘 것**(`xcrun simctl pair <워치> <아이폰>` + 아이폰 부팅).
  안 하면 상태 표시줄에 **빨간 "폰 연결 끊김" 아이콘**이 붙어 그대로 스토어에 올라간다.
  ⚠️ 페어링하면 워치의 설치된 앱이 지워지므로 **페어링 먼저, 설치는 그다음**이다.
- 언어는 `-AppleLanguages` 로 앱만 바꾼다(기기 언어는 그대로). 앱 화면에는 시스템 문구가
  없어서 이걸로 충분하지만, **알림 권한 팝업 같은 시스템 창은 기기 언어로 뜬다** — 찍기 전에
  미리 눌러 없앨 것.
- `04-finished.png` 는 2분 타이머(예비 알림 1분)를 걸고 끝날 때까지 기다려 찍는다.
