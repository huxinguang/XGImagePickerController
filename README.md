<p align="center">
  <img src="XGAssetPickerController_logo.png" title="XGAssetPickerController logo" float=left>
</p>

功能描述
==============
`XGAssetPickerController`是一款iOS相册选择器，支持图片、视频拍摄，多图片、多视频混选及预览， 支持Gif浏览(`iOS11+`)，多个相册目录同一图片/视频可自动排重，并具有记录已选图片/视频的功能。


系统要求
==============
该项目最低支持 `iOS 8.0+`。

演示项目
==============
1. 命令行进入`Demo`文件夹路径下，并执行`pod install`
2. 打开`XGAssetPickerController-Demo.xcworkspace`

安装
==============

### CocoaPods

1. 在 `Podfile` 中添加  `pod 'XGAssetPickerController'`。
2. 执行 `pod install` 或 `pod update`。
3. `#import "XG_AssetPickerController.h"`

### 手动安装
1. 下载 XGAssetPickerController 文件夹内的所有内容。
2. 将 XGAssetPickerController 内的源文件添加(拖放)到你的工程。
3. 由于用到了`FLAnimatedImage`，所以需要下载`FLAnimatedImage`（`https://github.com/Flipboard/FLAnimatedImage`），并添加(拖放)到你的工程。
4.  `#import "XG_AssetPickerController.h"`.


使用方法
==============
1. 先使用`[[XG_AssetPickerManager manager] handleAuthorizationWithCompletion:^(XG_AuthorizationStatus aStatus) {
}];`检查是否获取相册权限，然后根据`XG_AuthorizationStatus`做进一步处理 

2. 初始化`XG_AssetPickerOptions`对象来配置选择器，`maxAssetsCount`表示最大可选择数量，`videoPickable`表示是否可选择视频，已选的图片或者视频会保存在`pickedAssetModels`数组中。
3. 使用初始化选择器`XG_AssetPickerController`，然后
    `UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];`
    `[self presentViewController:nav animated:YES completion:nil];`

4. 遵循`<XG_AssetPickerControllerDelegate>`协议，并实现协议方法：
`- (void)assetPickerController:(XG_AssetPickerController *)picker didFinishPickingAssets:(NSArray<XG_AssetModel *> *)assets;`，选择结果在参数`assets`中。

    具体使用方法可参见示例Demo


注意事项
==============
1. 如果运行崩溃,崩溃信息log为：`This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSPhotoLibraryUsageDescription/NSCameraUsageDescription key with a string value explaining to the user how the app uses this data`.
请检查`Info.plist`是否添加相册/相机权限: `NSPhotoLibraryUsageDescription/NSCameraUsageDescription`

2. 模拟器环境下，虽然在工程的`Localizations`配置中添加了简体中文`Chinese（Simplified）`,但相册名称仍会默认为英文，这是正常的，因为`Localizations`在真机环境下才会生效（即真机环境下相册名称会显示成中文）。


许可证
==============
`XGAssetPickerController` 使用 MIT 许可证，详情见 LICENSE 文件。

<br/><br/>



Introduction
==============
`XGAssetPickerController` is an iOS album picker that supports mixed multi-image,multi-video selection and preview. Gif browsing is supproted on `iOS 11.0+`.   Same images or videos in different album can be automatically detected, and selected images or videos can be recorded.

Requirements
==============
This library requires `iOS 8.0+` .

Demo Project
==============
1. Use the terminal to enter the path of `Demo`,then excute  `pod install`
2. Click `XGAssetPickerController-Demo.xcworkspace`

Installation
==============

### CocoaPods

1. Add `pod 'XGAssetPickerController'` to your Podfile.
2. Run `pod install` or `pod update`.
3. `#import "XG_AssetPickerController.h"`

### Manually

1. Download all the files in the XGAssetPickerController subdirectory.
2. Add the source files to your Xcode project.
3. This library references `FLAnimatedImage`, so you need to download `FLAnimatedImage` (`https://github.com/Flipboard/FLAnimatedImage`) and add its source files to your Xcode project too.
4.  `#import "XG_AssetPickerController.h"`.

Usage
==============
1. Check if you get an access to the photo library using `[[XG_AssetPickerManager manager] handleAuthorizationWithCompletion:^(XG_AuthorizationStatus aStatus) {
}];`
2. Initialize a `XG_AssetPickerOptions` object to config the `XG_AssetPickerController` 
3. Initialize a `XG_AssetPickerController` using `initWithOptions: delegate:` method,and present it using
`UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];`
`[self presentViewController:nav animated:YES completion:nil];`
4. Adopt the `XG_AssetPickerControllerDelegate` protocol and implement it's required method `assetPickerController: didFinishPickingAssets:`

Notice
==============
If your app crashed with message like `This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSPhotoLibraryUsageDescription/NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.`, please check if the corresponding usage description is added in the app's Info.plist.

License
==============
`XGAssetPickerController` is provided under the MIT license. See `LICENSE` file for details.






 




