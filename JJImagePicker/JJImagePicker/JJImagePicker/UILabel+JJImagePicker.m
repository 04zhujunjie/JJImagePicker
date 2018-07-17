//
//  UILabel+JJImagePicker.m
//  JJImagePicker
//
//  Created by xiaozhu on 2018/7/16.
//  Copyright © 2018年 xiaozhu. All rights reserved.
//

#import "UILabel+JJImagePicker.h"
#import <objc/runtime.h>
#import "JJImagePicker.h"

@implementation UILabel (JJImagePicker)

- (void)setJj_ifdo:(BOOL)jj_ifdo{
    objc_setAssociatedObject(self, @selector(jj_ifdo), @(jj_ifdo), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)jj_ifdo{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        [self jj_exchangeIMP];
    });
}

+ (void)jj_exchangeIMP{
    [self jj_exchangeOriginalSelector:@selector(setText:) swizzledSelector:@selector(jj_setText:)];
}


- (void)jj_setText:(NSString *)text{
    [self jj_setText:text];
//    NSLog(@"===%@=%@------%@==",NSStringFromClass(self.superview.class),NSStringFromClass(self.superview.superview.class),text);
    [self setupCancel];
}



- (void)setupCancel{
    
    if ([NSStringFromClass([self class]) isEqualToString:@"UIButtonLabel"]) {
        UIView *modernBarButton = self.superview;
        if (![NSStringFromClass([modernBarButton class]) isEqualToString:@"_UIModernBarButton"]) {
            return;
        }
        
        if ([NSStringFromClass([modernBarButton.superview class]) isEqualToString:@"_UIBackButtonContainerView"]) {
            return;
        }
        if (![JJImagePicker sharedInstance].imagePickerController||![JJImagePicker sharedInstance].cancelText.length) {
            return;
        }
        [self setupText:[JJImagePicker sharedInstance].cancelText];
    }
}

- (void)setupText:(NSString *)text{
    if (!self.jj_ifdo) {
        self.jj_ifdo = YES;
        self.text = text;
        self.jj_ifdo = NO;
    }
}

+ (void)jj_exchangeOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector{
    
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end
