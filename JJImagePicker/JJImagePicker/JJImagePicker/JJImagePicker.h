//
//  JJImagePicker.h
//  JJImagePicker
//
//  Created by xiaozhu on 2018/7/16.
//  Copyright © 2018年 xiaozhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TOCropViewController.h"
@class JJImagePicker;

typedef void(^imagePickerDidFinished)(JJImagePicker *picker,UIImage *image);
typedef void(^imagePickerDidCancel)(JJImagePicker *picker);

typedef TOCropViewController*(^customCropViewController)(UIImage *image);

typedef NS_ENUM(NSInteger,JJImagePickerType){
    JJImagePickerTypeCamera = 0,
    JJImagePickerTypePhoto = 1
};
@interface JJImagePicker : NSObject


@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic ,copy) customCropViewController  customCropViewController;
@property (nonatomic ,assign,readonly)JJImagePickerType type;
//取消按钮字体
@property (nonatomic ,strong) NSString *cancelText;
//完成按钮字体
@property (nonatomic ,strong) NSString *doneText;
//相册标题
@property (nonatomic ,strong) NSString *albumText;
//拍照后，重拍按钮字体
@property (nonatomic ,strong) NSString *retakeText;
//拍照后，使用照片按钮字体
@property (nonatomic ,strong) NSString *choosePhotoText;
//相机，自动
@property (nonatomic ,strong) NSString *automaticText;
//相机，打开
@property (nonatomic ,strong) NSString *openText;
//相机，关闭
@property (nonatomic ,strong) NSString *closeText;

+ (instancetype) sharedInstance;

- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished;
- (void)showImagePickerWithType:(JJImagePickerType)type InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;

- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished;
- (void)actionSheetWithTakePhotoTitle:(NSString *)takePhotoTitle  albumTitle:(NSString *)albumTitle cancelTitle:(NSString *)cancelTitle InViewController:(UIViewController *)viewController didFinished:(imagePickerDidFinished)finished didCancel:(imagePickerDidCancel)cancel;
@end
