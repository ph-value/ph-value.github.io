---
layout: post
title:  "[FlutterFire] FirebaseCommandException 해결방안"
date:   2018-09-29
categories: Flutter
comments: true
tags: Error
---


- 상황 (MacOS):
Flutter 프로젝트에 [FlutterFire](https://firebase.flutter.dev/docs/overview) 적용 중, `flutterfire configure` 커맨드 후 `FirebaseCommandException` 발생


- 오류 내용:
  `FirebaseCommandException: An error occured on the Firebase CLI when attempting to run a command.`


- 제안:
  `firebase projects:list --json` 커맨드 실행

- 결과:
  {%- highlight tcl -%}
  Preparing the list of your Firebase projects{
  "status": "error",
  "error": "Failed to list Firebase projects. See firebase-debug.log for more info."}
  {%- endhighlight -%}

> 하지만 firebase에 기존 프로젝트가 있었다.
어디서부터 잘못 되었는지 하나씩 확인해보자.

---

##### 1. node.js, npm 확인
- 버전 확인 및 업데이트

##### 2. firebase-tools 확인
- 운영체제와 사용하는 패키지 관리 시스템에 맞게 [Firebase CLI 참조](https://firebase.google.com/docs/cli?hl=ko) 를 따라하자.

##### 3. `firebase login:list` 
**해당 Flutter 프로젝트 파일 경로에서**
- 계정이 있다면 `Logged in as your@gmail.com` 라고 뜸
- 계정이 없다면 로그인 하기

##### 4. `firebase logout`, `firebase login`
- 결국엔 이 방법이었음.
