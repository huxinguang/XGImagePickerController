# XGImagePickerController
iOS相册选择器,支持多图片、多视频混选及预览

使用须知：

1.本工具只适用于iOS8.0以上系统

2.如果运行崩溃， 崩溃信息log为：This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSPhotoLibraryUsageDescription key with a string value explaining to the user how the app uses this data.

请检查Info.plist是否添加相册/相机/麦克风权限：

<key>NSPhotoLibraryUsageDescription</key>
<string>需要您的同意,才能访问相册</string>
<key>NSCameraUsageDescription</key>
<string>需要您的同意,才能访问相机</string>
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风才能采集声音，是否允许访问您的麦克风？</string>


3.

