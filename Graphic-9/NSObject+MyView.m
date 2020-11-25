//
//  NSObject+MyView.m
//  Graphic-9
//
//  Created by wangyankun on 2020/4/3.
//  Copyright © 2020 shumei. All rights reserved.
//

#import "NSObject+MyView.h"


#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>

@implementation MyView : UIView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Parent Begin");
    UIResponder *nextresponser = [self nextResponder];
//    [nextresponser touchesBegan:touches withEvent:event];
}

@end
