---
title: FVM으로 프로젝트별 Flutter 버전 고정하기 (Windows)
date: 2026-11-16
category: Flutter
tag: [FVM, TIL]
slug: flutter-fvm-local-version
---

FVM(Flutter Version Management)을 사용하면 시스템에 설치된 Flutter를 바꾸지 않고 프로젝트마다 SDK 버전을 지정할 수 있다. 로컬과 배포 환경의 버전을 맞추거나, 서로 다른 Flutter 버전을 사용하는 프로젝트를 관리할 때 유용하다.

이 블로그도 GitHub Pages에서는 게시물이 정상적으로 보였지만, 같은 코드를 로컬에서 실행하자 로딩 오류가 발생했다. 확인해 보니 GitHub Actions의 배포 환경과 로컬의 Flutter 버전이 달랐다. 같은 조건에서 실행하기 위해 이 프로젝트의 Flutter 버전을 배포 환경에 맞춰 고정하기로 했다.

아래는 Windows PowerShell에서 프로젝트의 Flutter 버전을 고정하는 방법이다. 기존 Flutter와 Dart가 설치되어 있다고 가정한다. 명령어와 설정에 사용한 `3.35.3`은 예시이며, 프로젝트의 배포 설정에 맞게 바꾸면 된다.

## 1. FVM 설치 및 버전 지정

```powershell
dart pub global activate fvm
cd C:\path\to\your-project
fvm use 3.35.3
```

`fvm` 명령을 찾지 못한다면 현재 PowerShell의 PATH에 다음 경로를 추가한다.

```powershell
$env:Path += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

프로젝트에 생성된 `.fvmrc`에는 사용할 버전이 기록된다.

```json
{
  "flutter": "3.35.3"
}
```

## 2. Git으로 버전 설정 공유

**`.fvmrc`는 커밋하고**, 로컬 SDK 연결과 캐시를 위한 **`.fvm/`은 `.gitignore`에 추가**한다.

```gitignore
.fvm/
```

GitHub Actions에서 Flutter 버전을 별도로 지정했다면 같은 버전으로 맞춘다. `.fvmrc`를 생성하는 것만으로 배포 설정이 자동 변경되지는 않는다.

## 3. Windows 심볼릭 링크 권한 오류 해결

SDK 설치 뒤 프로젝트에 연결하는 단계에서 다음 오류가 발생할 수 있다.

```text
Failed to create version symlink
클라이언트가 필요한 권한을 가지고 있지 않습니다, errno = 1314
```

SDK 설치 실패가 아니라 Windows의 심볼릭 링크 생성 권한 문제다. 해결하려면 **PowerShell을 관리자 권한으로 열어** 다시 설정한다.

```powershell
cd C:\path\to\your-project
fvm use 3.35.3
fvm flutter --version
```

Windows 설정에서 **개발자 모드**를 켜는 방법도 있다.

## 4. 고정한 버전으로 로컬 실행

버전 확인 결과가 지정한 버전과 일치하면 기존 서버를 종료하고 일반 PowerShell에서 실행한다.

```powershell
fvm flutter clean
fvm flutter pub get
fvm flutter run -d chrome --web-port 8080
```

`clean`은 버전 전환 후 한 번 실행하고, 평소에는 마지막 실행 명령을 사용하면 된다. 브라우저 주소는 `http://localhost:8080`이다.

이후에는 **`flutter` 대신 `fvm flutter`로 실행**한다. 일반 `flutter` 명령은 시스템 PATH에 등록된 다른 SDK를 사용할 수 있다.

버전 고정은 실행 환경을 일치시키는 방법이다. SDK 업그레이드로 발생하는 코드 호환성 문제는 별도의 수정이 필요할 수 있다.

이번 설정의 목적은 GitHub Pages 배포에 사용하는 Flutter 버전과 로컬 실행 버전을 맞추는 것이었다. FVM을 사용하면 다른 프로젝트의 SDK를 바꾸지 않고도 이 블로그의 실행 버전을 배포 환경에 맞출 수 있다. 이후 버전을 올릴 때도 로컬과 GitHub Actions 설정을 함께 맞추면 된다.

참고: [FVM 공식 안내](https://fvm.app/documentation/getting-started/overview)
