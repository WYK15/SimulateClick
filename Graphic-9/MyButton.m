//
//  NSObject+MyUITouch.m
//  Graphic-9
//
//  Created by wangyankun on 2020/4/3.
//  Copyright © 2020 shumei. All rights reserved.
//

#import "MyButton.h"



@implementation MyButton : UIButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"btn4 Button Begin");
//    UIResponder *responder = [self nextResponder];
    //NSLog(@"responser : %@",responder);
 //   [responder touchesBegan:touches withEvent:event];
    
}

@end
