本教程是为了让新手快速了解融云 Flutter 即时通讯能力库。在本教程中，您可以体验集成 SDK 的基本流程和基础通信能力。

## 融云开发者账户

融云开发者账户是使用融云 SDK 产品的必要条件。

在开始之前，请先[前往融云官网注册开发者账户]。注册后，开发者后台将自动为您创建一个应用，默认为开发环境应用，使用国内数据中心。请获取该应用的 App Key，在本教程中使用。

>App Secret 用于生成数据签名，仅在请求融云服务端 API 接口时使用。本教程中暂不涉及。

如果您已拥有融云开发者账户，您可以直接选择合适的环境，创建应用。

应用的 App Key / Secret 是获取连接融云服务器身份凭证的必要条件，请注意不要泄露。

### 导入 SDK {#import}

1. 在项目的 `pubspec.yaml` 中添加依赖

```yaml
dependencies:
  flutter:
    sdk: flutter

  rongcloud_im_kit: ^1.0.0+2
```


2. 在项目路径执行 `flutter pub get` 来下载相关插件

### 初始化 {#init}

1. 使用 SDK 功能前，需要 `import` 下面的头文件

```dart
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
```


2. 开发者在使用融云 SDK 所有功能之前，需要先配置工程。

### Android 平台

1. 在 `android/app/build.gradle` 文件中添加以下配置：

```gradle
android {
    defaultConfig {
        // 请根据实际情况设置最小SDK版本
        minSdkVersion 23
    }
    
    // 添加Java 8特性支持
    compileOptions {
        // 启用desugaring以支持较新的Java API
        coreLibraryDesugaringEnabled true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }
    
    // 可选：添加签名配置
    signingConfigs {
        release {
            storeFile file("./your-key.jks")  // 密钥文件路径
            storePassword "yourPassword"      // 密钥库密码
            keyAlias "yourAlias"              // 密钥别名
            keyPassword "yourKeyPassword"     // 密钥密码
        }
    }
    
    // ProGuard混淆配置（可选但推荐）
    buildTypes {
        release {
            // 启用代码混淆
            minifyEnabled true
            // 启用资源压缩
            shrinkResources true
            // 指定ProGuard规则文件
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            // 使用签名配置
            signingConfig signingConfigs.release
        }
    }
}

dependencies {
    // 添加desugaring支持库
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
    // 添加窗口管理相关依赖
    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
}
```

2. 创建 `android/app/proguard-rules.pro` 文件，添加以下内容以保护融云SDK代码：

```proguard
# 融云SDK混淆规则
-keepattributes Exceptions,InnerClasses,Signature
-keep class io.rong.** {*;}
-keep class cn.rongcloud.** {*;}
-keep class * implements io.rong.imlib.model.MessageContent {*;}
-dontwarn io.rong.**
-dontwarn cn.rongcloud.**
```

3. 在 `android/app/src/main/AndroidManifest.xml` 文件中添加必要的权限和配置：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 网络权限 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    
    <!-- 本地通知权限 -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <!-- 存储权限 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- 多媒体相关权限 -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    
    <application
        android:label="你的应用名称"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true"
        android:networkSecurityConfig="@xml/network_security_config">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- 其他Activity配置 -->
        </activity>
        
        <!-- Flutter插件注册 -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    
    <!-- 文本处理相关查询（Flutter引擎需要） -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

4. 创建 `android/app/src/main/res/xml/network_security_config.xml` 文件，添加以下内容：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### iOS 平台

1. 在 `ios/Runner/Info.plist` 文件中添加必要的权限和配置：

```xml
<dict>
    <!-- 必要的权限说明 -->
    <key>NSCameraUsageDescription</key>
    <string>使用摄像头拍摄图片发送消息</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>使用麦克风发送语音消息</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>使用相册选择图片发送消息</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>使用位置权限发送位置消息</string>
    
    <key>NSAppleMusicUsageDescription</key>
    <string>使用音乐文件夹发送文件</string>
    
    <!-- 网络安全设置 -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- URL Scheme 查询支持 -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>http</string>
        <string>https</string>
    </array>
    
    <!-- 文档支持配置 -->
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    <key>UISupportsDocumentBrowser</key>
    <true/>
    
    <!-- 其他默认配置 -->
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    
    <!-- 支持的界面方向 -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
```

2. 确保 `ios/Podfile` 中的 iOS 版本设置正确：

```ruby
platform :ios, '15.0'
```

3. 修改 `ios/Runner/AppDelegate.swift` 文件以支持本地通知（如果使用Objective-C，修改对应的AppDelegate.m文件）：

对于Swift：
```swift
import Flutter
import UIKit
import flutter_local_notifications  // 添加本地通知插件导入

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 设置本地通知插件回调
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
    }

    // 设置通知中心代理（iOS 10及以上）
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

对于Objective-C：
```objc
#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // 设置本地通知插件回调
  [FlutterLocalNotificationsPlugin setPluginRegistrantCallback:^(NSObject<FlutterPluginRegistry> *registry) {
    [GeneratedPluginRegistrant registerWithRegistry:registry];
  }];
  
  // 设置通知中心代理（iOS 10及以上）
  if (@available(iOS 10.0, *)) {
    [UNUserNotificationCenter currentNotificationCenter].delegate = (id<UNUserNotificationCenterDelegate>) self;
  }
  
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

## 连接与启动  {#connect}

1. 请使用开发功能之前从[融云开发者后台](https://developer.rongcloud.cn/app/appkey/iwj1eg7Wb9M437VP1w==)注册得到的 `Appkey`
2. `Token` 即用户令牌，相当于您 APP 上当前用户连接融云的身份凭证。在您连接融云服务器之前，您需要请求您的 App Server，您的 App Server 通过融云 [Server API 获取 Token](/imserver/server/v1/user/register) 并返回给您的客户端，客户端获取到这个 Token 即可连接融云服务器。
3. `timeout` 连接超时时间，单位：秒。

注：如果 `code == 31004` 即过 `Token` 无效，是因为您在开发者后台设置了 `Token` 过期时间或者 `Token` 和初始化的 `AppKey` 不同环境，您需要请求您的服务器重新获取 `Token` 并再次用新的 `Token` 建立连接。

在应用启动时初始化 SDK：

```dart
import 'package:rongcloud_im_kit/rongcloud_im_kit.dart';
import 'package:provider/provider.dart';

// 在主应用中确保已配置Provider
// 使用 RongCloudAppProviders.of 来包裹你的根组件
runApp(
  RongCloudAppProviders.of(
    MyApp(), // 你的根组件
    additionalProviders: [ // 可以添加额外的Provider
      // ...
    ],
  ),
);

// 在需要初始化的页面中获取Provider
final engineProvider = Provider.of<RCKEngineProvider>(context, listen: false);

// 初始化并连接到融云服务器

final engine = await engineProvider.engineCreate(
  appKey,
  options,
);

await engineProvider.engineConnect(
  token,
  timeout,
  onResult: (code) {
    if (code == 0) {
      //连接成功
    } else {
      //错误提示
    }
  },
);

```
