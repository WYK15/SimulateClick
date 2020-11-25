//
//  ViewController.m
//  Graphic-9
//
//  Created by wangyankun on 2020/3/25.
//  Copyright © 2020 shumei. All rights reserved.
//
#import "ViewController.h"
#import "GraphicsServices.h"
#import "MyButton.h"
#import "NSObject+MyView.h"

#include <mach/mach_time.h>
#import <objc/message.h>
#import <dlfcn.h>
#import "IOHIDEvent.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEventSystemClient.h"
#import "IOHIDUserDevice.h"
#import "IOHIDEventSystem.h"
#import "IOHIDEvent7.h"
#import "IOHIDEventTypes7.h"
#import "IOHIDEventSystemConnection.h"

#import <PTFakeTouch/PTFakeTouch.h>
#import <CoreGraphics/CoreGraphics.h>
#import "GraphicsServices.h"

#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
#define GSPATH  "/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices"
#define IOKITPATH "/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit"

@interface SmWEvent : NSObject
@property int session;        //序列号
@property NSString *type;          //事件类型
@property NSString *phase;      //按压阶段
@property NSNumber *time;          //时间戳
@property CGFloat radius;       //半径
@property CGFloat force;        //压力大小
@end

@implementation SmWEvent

-(NSString*) convert2string{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:self.session],@"s",
                         self.type,@"m",
                         self.phase,@"p",
                         self.time,@"t",
                         [NSNumber numberWithFloat:self.radius],@"r",
                         [NSNumber numberWithFloat:self.force],@"f",
                         nil];
    
    NSData *dicData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:0];
    NSString *dicStr = [[NSString alloc] initWithData:dicData encoding:NSUTF8StringEncoding];
    return dicStr;
}

@end


@interface ViewController ()

@end



@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self HookWindowSendEvent];
    //[self ListenSystemDis];
    
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    
    UIButton    *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(70, 40, 200, 50)];
    [btn1 setTitle:@"按钮1" forState:UIControlStateNormal];
    btn1.layer.borderWidth = 1.0f;
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];

    [btn1 addTarget:self action:@selector(btn1TouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn1 addTarget:self action:@selector(btn1TouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btn1];

    UIButton    *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(40, 150, 200, 50)];
    btn2.layer.borderWidth = 1.0f;
    [btn2 setTitle:@"按钮2" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];

    [btn2 addTarget:self action:@selector(btn2TouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn2 addTarget:self action:@selector(btn2TouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];



    UIButton    *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(40, 260, 200, 50)];
    btn3.layer.borderWidth = 1.0f;
    [btn3 setTitle:@"按钮3" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor blueColor] forState:UIControlEventTouchDown];
    [btn3 addTarget:self action:@selector(btn3TouchDown:) forControlEvents:UIControlEventTouchDown];
    [btn3 addTarget:self action:@selector(btn3TouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:btn3];
    
    MyButton *btn4 = [[MyButton alloc]initWithFrame:CGRectMake(20, 20, 100, 50)];
    btn4.layer.borderWidth = 1.0f;
    [btn4 setTitle:@"按钮4" forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn4 setTitleColor:[UIColor blueColor] forState:UIControlEventTouchDown];
    [self.view addSubview:btn4];

    MyView *ParentView = [[MyView alloc]initWithFrame:CGRectMake(40, 370, 200, 100)];
    ParentView.layer.borderWidth = 1.0f;
    [ParentView addSubview:btn4];
//
//
    [self.view addSubview:ParentView];
    
    //[self RewriteBegin:btn4];
    [self RewriteBegin:btn3];
    
    
}

-(void)RewriteBegin:(UIResponder*)object {
    Method beginMethod = class_getInstanceMethod([object class], @selector(touchesBegan:withEvent:));
    Method mybeginMethod = class_getInstanceMethod([self class], @selector(myTouchBegin:withEvent:));
    if (!beginMethod) {
        NSLog(@"NO exist begin method");
    }
    
    IMP beginMethodImp = method_getImplementation(beginMethod);
    bool addResult = class_addMethod([object class], @selector(touchBeginOrigin:), beginMethodImp, method_getTypeEncoding(beginMethod));
    if (!addResult) {
        NSLog(@"添加失败");
        return;
    }
    
    IMP  mybeginMethodImp = method_getImplementation(mybeginMethod);
    class_replaceMethod([object class], @selector(touchesBegan:withEvent:), mybeginMethodImp, method_getTypeEncoding(beginMethod));
    
}

-(void) myTouchBegin:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"myTouchbegin");
    for (UITouch *touch in touches) {
        SmWEvent *event = [[SmWEvent alloc] init];
        [event setSession:2];
        [event setType:@"touch"];
        [event setPhase:@"begin"];
        [event setTime:[NSNumber numberWithInt:1593569299]];
        [event setRadius:touch.force];
        [event setForce:touch.force];
        NSString *eventStr = [event convert2string];
        NSLog(@"eventStr : %@",eventStr);
        NSLog(@"eventStr len : %d",eventStr.length);
    }
    [self performSelector:@selector(touchBeginOrigin:) withObject:touches withObject:event];
}

-(void) HookWindowSendEvent
{
        // 获取到UIWindow中sendEvent对应的method
         Method sendEvent = class_getInstanceMethod([UIWindow class], @selector(sendEvent:));
         Method sendEventMySelf = class_getInstanceMethod([self class], @selector(sendEventHooked:));
    
         // 将目标函数的原实现绑定到sendEventOriginalImplemention方法上
         IMP sendEventImp = method_getImplementation(sendEvent);
         class_addMethod([UIWindow class], @selector(sendEventOriginal:), sendEventImp, method_getTypeEncoding(sendEvent));
    
         // 然后用我们自己的函数的实现，替换目标函数对应的实现
         IMP sendEventMySelfImp = method_getImplementation(sendEventMySelf);
         class_replaceMethod([UIWindow class], @selector(sendEvent:), sendEventMySelfImp, method_getTypeEncoding(sendEvent));
}

-(void) sendEventHooked : (UIEvent *)event{
    NSLog(@"event : %@",event);
    
    [self performSelector:@selector(sendEventOriginal:) withObject:event];
}


static void SendTouchesEvent(double x,double y) {
    //IOHIDDigitizerTransducerType

    uint64_t abTime = mach_absolute_time();
    AbsoluteTime timeStamp;
    timeStamp.hi = (UInt32)(abTime >> 32);
    timeStamp.lo = (UInt32)(abTime);
    //1.新建事件引用handEvent
    //IOHIDEventRef handEvent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, timeStamp, /*kIOHIDDigitizerTransducerTypeHand*/3, 0, 0, kIOHIDDigitizerEventTouch, 0, 0, 0, 0, 0, 0, 0, 1, 0);
    IOHIDEventRef handEvent = IOHIDEventCreateDigitizerEvent(kCFAllocatorDefault, timeStamp, kIOHIDDigitizerTransducerTypeHand, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, true, 0);
//    IOHIDEventRef IOHIDEventCreateDigitizerEvent(CFAllocatorRef allocator, AbsoluteTime timeStamp, IOHIDDigitizerTransducerType type,
//    uint32_t index, uint32_t identity, uint32_t eventMask, uint32_t buttonMask,
//    IOHIDFloat x, IOHIDFloat y, IOHIDFloat z, IOHIDFloat tipPressure, IOHIDFloat barrelPressure,
//    Boolean range, Boolean touch, IOOptionBits options);
    //2.设置属性
    //ios <= 7.0
//    IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldDigitizerDisplayIntegrated, 1LL, 4026531840LL);
//    IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldBuiltIn, 1LL, 4026531840LL);
    //ios > 7.0
    IOHIDEventSetIntegerValue(handEvent, kIOHIDEventFieldDigitizerDisplayIntegrated, true);
    IOHIDEventSetIntegerValue(handEvent, kIOHIDEventFieldBuiltIn, 1); //2.1
    //IOHIDEventSetIntegerValue(handEvent, kIOHIDEventFieldBuiltIn, 0); //2.2
    //IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldDigitizerDisplayIntegrated, 1, -268435456);
    //IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldBuiltIn, 1, -268435456);
    
//   重要，设置senderId(It looks changing each time, but it doens't care. just don't use 0)
    uint64_t sendId;
    if (@available(iOS 11.0,*)) sendId = 0x000000010000027F/*4294967990LL*/;//-9223372002105912458LL;
    else sendId = 4294967990LL;
    //IOHIDEventSetSenderID(handEvent, sendId);
    IOHIDEventSetSenderID(handEvent, 4294967935LL);
    
    //3. 创建finger事件(子事件)
    //IOHIDEventRef fingerEvent = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, timeStamp, 1, 2, kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch, x, y, 0, 0, 0, 1, 1, 0);  //3.1
    //IOHIDEventRef fingerEvent = IOHIDEventCreateDigitizerFingerEventWithQuality(kCFAllocatorDefault, timeStamp, 1, 3, kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch, x, y, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0); //3.2
    
    //IOHIDEventRef fingerEvent = IOHIDEventCreateDigitizerFingerEventWithQuality(kCFAllocatorDefault, timeStamp, 1, 3, 2, x, y, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0);  //3.3
    
    IOHIDEventRef fingerEvent = IOHIDEventCreateDigitizerFingerEvent(kCFAllocatorDefault, timeStamp, 1, 2, 1, x, y, 0, 0, 90.00, 0, 0, 0);
    
    //4.将事件添加入handEvent（父事件）
    //IOHIDEventAppendEvent(handEvent, fingerEvent);
    //NSLog(@"addr : %x",IOHIDEventAppendEvent);
    void *lib = dlopen(IOKITPATH, RTLD_LAZY);
    int (*IOHIDEventAppendEventByDlsym)(IOHIDEventRef f,IOHIDEventRef s) = dlsym(lib, "IOHIDEventAppendEvent");
    IOHIDEventAppendEventByDlsym(handEvent, fingerEvent);
    
    //5.再设置父事件属性
    IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldDigitizerEventMask, 0/*kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch | kIOHIDDigitizerEventIdentity*/, -268435456);
    IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldDigitizerRange, 1, -268435456);
    IOHIDEventSetIntegerValueWithOptions(handEvent, kIOHIDEventFieldDigitizerTouch, 1, -268435456);
    
    //6.分发父事件
    if (!handEvent) NSLog(@"handEvent is null!!");
    else {
        NSLog(@"handEvent : %@",handEvent);
        IOHIDEventSystemClientRef client = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
//        [client IOHIDEventSystemClientRegisterEventCallback:];
        if (!client) {
            
            NSLog(@"client is null!!!!");
        }else{
            NSLog(@"client : %@",client);
        }
        IOHIDEventSystemClientDispatchEvent(client,handEvent);
        
    }

}
extern  void IOHIDEventSystemClientDispatchEvent(IOHIDEventSystemClientRef client, IOHIDEventRef event);
extern IOHIDEventSystemClientRef IOHIDEventSystemClientCreate(CFAllocatorRef allocator);


-(void) applicationEnterBackground {

    NSLog(@"Enter BACK");
//    [NSThread sleepForTimeInterval:1.0f];
//    SendTouchesEvent(40.0, 50.1);
    //int centerX = 148,centerY = 350;
    //[self sendTapByIOkit:50 y:50];
//    for (int i = 170; i < 700; i += 10) {
//        CGPoint   point = CGPointMake(i, i);
//        [self sendTap:point];
//        NSLog(@"Clicked");
//        [NSThread sleepForTimeInterval:0.5f];
//    }
    //CGPoint   point = CGPointMake(65, 70);
//    CGPoint   point = CGPointMake(148, 350);
//    //CGPoint   point = CGPointMake(70, 70);
//    [self sendTap:point];
//    [self sendTapByIOkit:148 y:350];
//    NSLog(@"Clicked");
//    [NSThread sleepForTimeInterval:1.0f];
//
//    CGPoint point2 = CGPointMake(165, 165);
//    [self sendTap:point2];
    //SendTouchesEvent(147,350);
//    SendTouchesEvent(58, 57);
//    SendTouchesEvent(47.1, 56.1);
    
 //    SendTouchesEvent(162, 350);
}

//iOS 8之后已经被禁止 https://stackoverflow.com/questions/25939616/how-to-get-frontmost-app-is-ios8
//static mach_port_t getFrontMostAppPort() {
//    mach_port_t *port;
//    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
//    int (*SBSSpringBoardServerPort)() = dlsym(lib, "SBSSpringBoardServerPort");
//    port = (mach_port_t *)SBSSpringBoardServerPort();
//    dlclose(lib);
//
//    void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
//    char appId[256];
//    memset(appId, 0, sizeof(appId));
//    SBFrontmostApplicationDisplayIdentifier(port, appId);
//    return GSCopyPurpleNamedPort(appId);
//}



static mach_port_t getFrontMostAppPort()
{
    bool locked;
    bool passcode;
    mach_port_t *port;
    void *lib = dlopen(SBSERVPATH, RTLD_LAZY);
    int (*SBSSpringBoardServerPort)() = dlsym(lib, "SBSSpringBoardServerPort");
    void* (*SBGetScreenLockStatus)(mach_port_t* port, bool *lockStatus, bool *passcodeEnabled) = dlsym(lib, "SBGetScreenLockStatus");
    port = (mach_port_t *)SBSSpringBoardServerPort();
    
    dlclose(lib);
    SBGetScreenLockStatus(port, &locked, &passcode);
    void *(*SBFrontmostApplicationDisplayIdentifier)(mach_port_t *port, char *result) = dlsym(lib, "SBFrontmostApplicationDisplayIdentifier");
    char appId[256];
    memset(appId, 0, sizeof(appId));
    SBFrontmostApplicationDisplayIdentifier(port, appId);
    NSString * frontmostApp=[NSString stringWithFormat:@"%s",appId];
//    if([frontmostApp length] == 0 || locked)
    
    void *gslib = dlopen(GSPATH, RTLD_LAZY);
    int (*GSGetPurpleSystemEventPort)() = dlsym(gslib, "GSGetPurpleSystemEventPort");
    int (*GSCopyPurpleNamedPort)(char *appid) = dlsym(gslib, "GSCopyPurpleNamedPort");
//    if([frontmostApp length] < 3 || locked)
//        return GSGetPurpleSystemEventPort();
//    else
//        NSLog(@"appid: %@",frontmostApp);
//        return GSCopyPurpleNamedPort(appId);
        return GSCopyPurpleNamedPort("com.shumei.Graphic-9");
}

- (IBAction)btn3TouchDown:(id)sender {
    NSLog(@" System Button3 Down");
}

-(IBAction)btn3TouchUpInside:(id)sender {
     NSLog(@" System Button3 UP");
    
}

- (IBAction)btn4TouchDown:(id)sender {
    NSLog(@"Button4 Down");
}

-(IBAction)btn4TouchUpInside:(id)sender {
     NSLog(@"Button4 UP");
    
}


- (void) btn1TouchDown: (id) sender
{
    UIButton    *btn1 = (UIButton *) sender;
    NSLog(@"Button1 Down");
    [btn1 setHighlighted:YES];
    
}

- (void) btn1TouchUpInside: (id) sender
{
    NSLog(@"Button1 Up");
//    UIButton    *btn1 = (UIButton *) sender;
//    [btn1 setHighlighted:NO];
//    CGPoint     point = CGPointMake(100, 100);
//    [self sendTap:point];
    

//    int centerX = 148,centerY = 350;
    
//    [self sendTapByIOkit:148 y:300];
    //SendTouchesEvent(148, 300);
    [self sendTapByIOkit:40 y:280];
//    SendTouchesEvent(58, 57);
}


-(void) sendTapByIOkit:(int) x
                     y:(int) y
{
        NSInteger pointId = [PTFakeTouch fakeTouchId:[PTFakeTouch getAvailablePointId] AtPoint:CGPointMake(x,y) withTouchPhase:UITouchPhaseBegan];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [PTFakeTouch fakeTouchId:pointId AtPoint:CGPointMake(x,y) withTouchPhase:UITouchPhaseEnded];
        });
}



- (void) btn2TouchDown: (id) sender
{
    NSLog(@"Button2 Down");
    UIButton    *btn2 = (UIButton *) sender;
    [btn2 setHighlighted:YES];
}

- (void) btn2TouchUpInside: (id) sender
{
     NSLog(@"Button2 Up");
    UIButton    *btn2 = (UIButton *) sender;
    [btn2 setHighlighted:NO];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)sendTap : (CGPoint) point{
    [self sendTouchStart:point];
    [self sendTouchEnd:point];
}

- (void)sendTouchStart: (CGPoint) point{
    [self sendEventForPhase:UITouchPhaseBegan point:point];
}

- (void)sendTouchEnd: (CGPoint) point{
    [self sendEventForPhase:UITouchPhaseEnded point:point];
}


//- (void)sendEventForPhase: (UITouchPhase)phase
//                   point : (CGPoint) point{
//    void *gslib = dlopen(GSPATH, RTLD_LAZY); //1
//    int64_t (*GSCurrentEventTimestamp)() = dlsym(gslib, "GSCurrentEventTimestamp"); //1.1
//
//    CGPoint adjustedPoint = [self.view convertPoint:point toView:self.view.window];
//
//    //    NSLog(@"point : %@ \n NSStringFromCGPoint(adjustedPoint: %@ \n", NSStringFromCGPoint(point), NSStringFromCGPoint(adjustedPoint));
//    uint8_t touchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];
//    struct GSTouchEvent {
//        GSEventRecord record;
//        GSHandInfo    handInfo;
//    } * event = (struct GSTouchEvent*) &touchEvent;
//    bzero(event, sizeof(event));
//    event->record.type = kGSEventHand;
//    event->record.subtype = kGSEventSubTypeUnknown;
//    event->record.location = point;
//    event->record.timestamp = GSCurrentEventTimestamp();
//    event->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
//    event->handInfo.type = (phase == UITouchPhaseBegan) ? kGSHandInfoTypeTouchDown : kGSHandInfoTypeTouchUp;
//    event->handInfo.pathInfosCount = 1;
//
//    bzero(&event->handInfo.pathInfos[0], sizeof(GSPathInfo));
//    event->handInfo.pathInfos[0].pathIndex     = 1;
//    event->handInfo.pathInfos[0].pathIdentity  = 2;
//    event->handInfo.pathInfos[0].pathProximity = (phase == UITouchPhaseBegan) ? 0x03 : 0x00;
//    event->handInfo.pathInfos[0].pathLocation  = adjustedPoint;
//
//
//
//    mach_port_t port = getFrontMostAppPort();
//    NSLog(@"port is : %d",port);
//    NSLog(@"timestamp: %lld",GSCurrentEventTimestamp());
//    GSEventRecord* record = (GSEventRecord*)event;
//    record->timestamp = GSCurrentEventTimestamp();
//
//    void* (*GSSendEvent)(GSEventRecord* record,mach_port_t* port) = dlsym(gslib, "GSSendEvent"); //1.2
//
//    GSSendEvent(record, port);
//    GSSendSystemEvent(record);
//}


- (void)sendEventForPhase: (UITouchPhase)handInfoType
point : (CGPoint) point {
    void *gslib = dlopen(GSPATH, RTLD_LAZY); //1
    int64_t (*GSCurrentEventTimestamp)() = dlsym(gslib, "GSCurrentEventTimestamp"); //1.1

   CGPoint adjustedPoint = [self.view convertPoint:point toView:self.view.window];
    uint8_t gsTouchEvent[sizeof(GSEventRecord) + sizeof(GSHandInfo) + sizeof(GSPathInfo)];

   // structure of touch GSEvent
   struct GSTouchEvent {
      GSEventRecord record;
      GSHandInfo    handInfo;
   } * touchEvent = (struct GSTouchEvent*) &gsTouchEvent;
   bzero(touchEvent, sizeof(touchEvent));

   touchEvent->record.type = kGSEventHand;
   touchEvent->record.subtype = kGSEventSubTypeUnknown;
   touchEvent->record.location = point;
   touchEvent->record.windowLocation = point;
   touchEvent->record.infoSize = sizeof(GSHandInfo) + sizeof(GSPathInfo);
   touchEvent->record.timestamp = GSCurrentEventTimestamp();
   //touchEvent->record.window = winRef;
   //touchEvent->record.senderPID = 919;
   bzero(&touchEvent->handInfo, sizeof(GSHandInfo));
   bzero(&touchEvent->handInfo.pathInfos[0], sizeof(GSPathInfo));
   GSHandInfo touchEventHandInfo;
   touchEventHandInfo._0x5C = 0;
   touchEventHandInfo.deltaX = 0;
   touchEventHandInfo.deltaY = 0;
   touchEventHandInfo.height = 0;
   touchEventHandInfo.width = 0;
   touchEvent->handInfo = touchEventHandInfo;
   touchEvent->handInfo.type = (handInfoType == kGSHandInfoTypeTouchDown) ? 2 : 1;
   touchEvent->handInfo.deltaX = 1;
   touchEvent->handInfo.deltaY = 1;
   touchEvent->handInfo.pathInfosCount = 1;
   touchEvent->handInfo.pathInfos[0].pathIndex = 1;
   touchEvent->handInfo.pathInfos[0].pathIdentity = 2;
   touchEvent->handInfo.pathInfos[0].pathProximity = (handInfoType == kGSHandInfoTypeTouchDown || handInfoType == kGSHandInfoTypeTouchDragged || handInfoType == kGSHandInfoTypeTouchMoved) ? 0x03: 0x00;
   touchEvent->handInfo.pathInfos[0].pathLocation = point;
   //touchEvent->handInfo.pathInfos[0].pathWindow = winRef;

   GSEventRecord* record = (GSEventRecord*) touchEvent;
   record->timestamp = GSCurrentEventTimestamp();
    
    mach_port_t port = getFrontMostAppPort();
    
    NSLog(@"port is : %d",port);
    NSLog(@"timestamp: %lld",GSCurrentEventTimestamp());

    
    void* (*GSSendEvent)(GSEventRecord* record,mach_port_t* port) = dlsym(gslib, "GSSendEvent"); //1.2
    void* (*GSSendSystemEvent)(GSEventRecord* record) = dlsym(gslib,"GSSendSystemEvent");
//   GSSendEvent(record, port);
    GSSendSystemEvent(record);

    
}


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"系统的touch Begin");

//     NSLog(@"UIView begin");
//    NSSet *allTouch = [event allTouches];
//    for(UITouch* touch in allTouch) {
//        [self printTouchInfo:touch Phase:@"Begin"];
//    }
   
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *eventInfo = [NSString stringWithFormat:@"%@",event]
//    [fileManager createFileAtPath:@"/tmp/tt.txt" contents:[eventInfo dataUsingEncoding: NSUTF8StringEncoding] attributes:nil];
    /*
    NSLog(@"touches in event : %@",allTouch);
    
    NSLog(@"params : %@",touches);
    
    UITouch *touch = [allTouch anyObject];
    
    CGPoint point = [touch locationInView:[touch view]];
    double x = point.x;
    double y = point.y;
    NSLog(@"粗略坐标：x,y == (%f, %f)", x, y);
    NSLog(@"半径: %f",touch.majorRadius);
    
    CGPoint precisePoint = [touch preciseLocationInView:touch.view];
    NSLog(@"精确坐标: x,y == (%f, %f)",precisePoint.x,precisePoint.y);
    
    NSLog(@"触摸的事件类型 : %ld",touch.type); //以下为几种类型
    //      UITouchTypeDirect,                       // A direct touch from a finger (on a screen)
    //      UITouchTypeIndirect,                     // An indirect touch (not a screen)
    //      UITouchTypePencil API_AVAILABLE(ios(9.1)), // Add pencil name variant
    //      UITouchTypeStylus API_AVAILABLE(ios(9.1)) = UITouchTypePencil, // A touch from a stylus (deprecated name, use pencil)
    
    NSLog(@"压力大小: %f",touch.force);
    
    NSLog(@"触摸阶段：%ld",touch.phase); //以下介绍
    //手指触及屏幕
//
//    UITouchPhaseBegan,
//
//    //手指在屏幕上移动时
//
//    UITouchPhaseMoved,
//
//    //手指触摸屏幕但不移动
//
//    UITouchPhaseStationary,
//
//    //手指离开屏幕
//
//    UITouchPhaseEnded,
//
//    //触摸没有结束，但停止跟踪
//
//    UITouchPhaseCancelled,
    
    NSLog(@"window: %@",touch.window);
    
    NSLog(@"view : %@",touch.view);
    
    NSLog(@"tapcount: %ld",touch.tapCount);
    
    NSLog(@"Begin 触控发生的时间: %f",touch.timestamp);

    NSLog(@"-------------------------");
    
    //NSLog(@"UITouchInfo:%@",touch);
    
    //NSLog(@"")
     */
}



-(void) ListenSystemDis {
 
    IOHIDEventSystemClientRef client = IOHIDEventSystemClientCreate(kCFAllocatorSystemDefault);
    //NSLog(@"%@",client);
    IOHIDEventSystemClientScheduleWithRunLoop(client, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(client, (IOHIDEventSystemClientEventCallback)(handle_event), 0, 0);
}

void handle_event(void* target, void* refcon, IOHIDEventQueueRef queue, IOHIDEventRef event) {
//    NSLog(@"event: %@",event);
     if (IOHIDEventGetType(event) == kIOHIDEventTypeDigitizer) {
         NSLog(@"event: %@",event);
//        void* children = IOHIDEventGetChildren(event);
//         int count = CFArrayGetCount(children);
//         for (int i = 0; i < count; i++) {
//             void* item = CFArrayGetValueAtIndex(children, i);
//              mainX = IOHIDEventGetFloatValue(item,kIOHIDEventFieldDigitizerX) * [[UIScreen mainScreen] bounds].size.width;
//             mainY = IOHIDEventGetFloatValue(item,kIOHIDEventFieldDigitizerY) * [[UIScreen mainScreen] bounds].size.height;
//             mainType = IOHIDEventGetFloatValue(item,kIOHIDEventFieldDigitizerType);
//             mainIndex = IOHIDEventGetFloatValue(item,kIOHIDEventFieldDigitizerIndex);
//
//         }
     }
}

- (void)  touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"UIView MOVE");
    NSSet *allTouch = [event allTouches];
    for(UITouch* touch in allTouch) {
        [self printTouchInfo:touch Phase:@"Moved"];
    }
}
 

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"UIView END");
    NSSet *allTouch = [event allTouches];
    for(UITouch* touch in allTouch) {
        //NSLog(@"Endtouch : %@",touch);
        //[self printTouchInfo:touch Phase:@"End"];
    }
    

    //NSLog(@"touches in event : %@",allTouch);
    
    //NSLog(@"params : %@",touches);
    
    //UITouch *touch = [allTouch anyObject];
    
    //NSLog(@"End 触控发生的时间: %f",touch.timestamp);
}

-(void)printTouchInfo:(UITouch*) touch
                Phase:(NSString*) phase
{
    
    //SmWevent
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:10];
//    [dic setObject:@"92211203993920203" forKey:@"s"];
//    [dic setObject:@"touch" forKey:@"m"];
//    [dic setObject:@"begin" forKey:@"p"];
//    [dic setObject:@"15739020344" forKey:@"t"];
//    [dic setObject:[NSNumber numberWithFloat:3.2] forKey:@"f"];
//    [dic setObject:[NSNumber numberWithFloat:3.2] forKey:@"r"];
//    
//    NSData *dat = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
//    NSString *s = [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding];
//    NSLog(@"slen : %d",s.length); //113
    
    CGPoint point = [touch locationInView:[touch view]];
        double x = point.x;
        double y = point.y;
        NSLog(@"%@: 粗略坐标：x,y == (%f, %f)", phase , x, y);
        NSLog(@"%@: 半径: %f",phase ,touch.majorRadius);
        
        CGPoint precisePoint = [touch preciseLocationInView:touch.view];
        NSLog(@"%@: 精确坐标: x,y == (%f, %f)",phase ,precisePoint.x,precisePoint.y);
        
        NSLog(@"%@: 触摸的事件类型 : %ld",phase ,touch.type); //以下为几种类型
        //      UITouchTypeDirect,                       // A direct touch from a finger (on a screen)
        //      UITouchTypeIndirect,                     // An indirect touch (not a screen)
        //      UITouchTypePencil API_AVAILABLE(ios(9.1)), // Add pencil name variant
        //      UITouchTypeStylus API_AVAILABLE(ios(9.1)) = UITouchTypePencil, // A touch from a stylus (deprecated name, use pencil)
        
        NSLog(@"%@: 压力大小: %f",phase ,touch.force);
        
        NSLog(@"%@: 触摸阶段：%ld",phase ,touch.phase); //以下介绍
        //手指触及屏幕
    //
    //    UITouchPhaseBegan,
    //
    //    //手指在屏幕上移动时
    //
    //    UITouchPhaseMoved,
    //
    //    //手指触摸屏幕但不移动
    //
    //    UITouchPhaseStationary,
    //
    //    //手指离开屏幕
    //
    //    UITouchPhaseEnded,
    //
    //    //触摸没有结束，但停止跟踪
    //
    //    UITouchPhaseCancelled,
        
        NSLog(@"%@: window: %@",phase ,touch.window);
        
        NSLog(@"%@: view : %@",phase ,touch.view);
        
        NSLog(@"%@: tapcount: %ld",phase ,touch.tapCount);
        
        NSLog(@"%@: 触控发生的时间: %f",phase ,touch.timestamp);

        NSLog(@"-------------------------");
        
        //NSLog(@"UITouchInfo:%@",touch);
}

-(void) track:(UIResponder*) response {
    
}


@end
