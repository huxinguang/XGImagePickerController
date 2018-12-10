<p align="center">
  <img src="XGImagePickerController_logo.png" title="XGImagePickerController logo" float=left>
</p>

功能描述
==============
XGImagePickerController是一款iOS相册选择器，支持图片、视频拍摄，多图片、多视频混选及预览， 支持Gif浏览(iOS11+)，多个相册目录同一图片/视频可自动排重，并具有记录已选图片/视频的功能。


系统要求
==============
该项目最低支持 `iOS 8.0+`。

安装
==============

### CocoaPods

1. 在 Podfile 中添加  `pod 'XGImagePickerController'`。
2. 执行 `pod install` 或 `pod update`。
3. #import "XG_AssetPickerController.h"

文档
==============
1. 先使用来检查是否获取相册权限，然后做进一步处理 `[[XG_AssetPickerManager manager] handleAuthorizationWithCompletion:^(XG_AuthorizationStatus aStatus) {
}];`

2. 初始化`XG_AssetPickerOptions`对象来配置选择器，`maxAssetsCount`表示最大可选择数量，`videoPickable`表示是否可选择视频，已选的图片或者视频会保存在`pickedAssetModels`数组中。
3. 使用`XG_AssetPickerController *photoPickerVc = [[XG_AssetPickerController alloc] initWithOptions:options delegate:self];`初始化选择器，然后`UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photoPickerVc];
[self presentViewController:nav animated:YES completion:nil];`

4. 遵循`<XG_AssetPickerControllerDelegate>`协议，并实现协议方法：
`- (void)assetPickerController:(XG_AssetPickerController *)picker didFinishPickingAssets:(NSArray<XG_AssetModel *> *)assets;`

具体使用方法可参见示例Demo


注意事项
==============
1. 如果运行崩溃,崩溃信息log为：This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSPhotoLibraryUsageDescription/NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.
请检查Info.plist是否添加相册/相机权限: NSPhotoLibraryUsageDescription/NSCameraUsageDescription

2. 模拟器环境下，虽然在工程的Localizations配置中添加了简体中文Chinese（Simplified）,但相册名称仍会默认为英文，这是正常的，因为Localizations在真机环境下才会生效（即真机环境下相册名称会显示成中文）。


许可证
==============
XGImagePickerController 使用 MIT 许可证，详情见 LICENSE 文件。


<br/><br/>
---

Installation
==============

### CocoaPods

1. Add `pod 'XGImagePickerController'` to your Podfile.
2. Run `pod install` or `pod update`.
3. #import "XG_AssetPickerController.h"

### Manually

1. Download all the files in the `Picker` subdirectory.
2. Add the source files to your Xcode project.
3. Import `XG_AssetPickerController.h`.

Documentation
==============



Requirements
==============
This library requires `iOS 8.0+` .

Notice
==============
If your app crashed with message like 'This app has crashed because it attempted to access privacy-sensitive data without a usage description.  The app's Info.plist must contain an NSPhotoLibraryUsageDescription/NSCameraUsageDescription key with a string value explaining to the user how the app uses this data.',please check if the corresponding usage description is added in the app's Info.plist.

License
==============
XGImagePickerController is provided under the MIT license. See LICENSE file for details.






 




