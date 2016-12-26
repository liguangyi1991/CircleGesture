//
//  ColorPickerView.m
//  moveview
//
//  Created by 钱权 on 16/5/31.
//  Copyright © 2016年 钱权. All rights reserved.
//

#import "ColorPickerView.h"
#import "UIImage+Color.h"

#define centerR 143
#define lnnerR 135
CGFloat aacc ;
@interface ColorPickerView () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIImageView *moveView;
@property (nonatomic, strong) UIBezierPath *lnnerRing;
@property (nonatomic, strong) UIBezierPath *centerRing;
@property (nonatomic, strong) UIBezierPath *outerRing;
@property (nonatomic, assign) BOOL first;
@property (nonatomic, assign) CGPoint beforPoint;
@property (nonatomic, assign) CGPoint lastGestureVelocity;
@property (nonatomic, assign) CGPoint lastGestureVelocityTwo;

@property (nonatomic, assign) BOOL isShun;


@property CGFloat currentAngle;
@property CGFloat previousAngle;

@end
@implementation ColorPickerView

-(UIImageView *)moveView{
    
    if (_moveView == nil) {
        _moveView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4"]];
        self.backgroundColor = [UIColor yellowColor];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(one:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
    }
    
    return _moveView;
}

- (UIBezierPath *)centerRing{
    if (_centerRing == nil) {
        _centerRing = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:centerR startAngle:0 endAngle:2 * M_PI clockwise:YES];
    }
    return _centerRing;
}

- (UIBezierPath *)lnnerRing{
    if (_lnnerRing == nil) {
        _lnnerRing = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2) radius:lnnerR startAngle:0 endAngle:2 * M_PI clockwise:YES];
    }
    return _lnnerRing;
}

- (UIBezierPath *)outerRing{
    if (_outerRing == nil) {
        _outerRing = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    }
    return _outerRing;
}
- (void)one:(UIPanGestureRecognizer *)panGesture
{
    if( ([panGesture state] == UIGestureRecognizerStateBegan) ||
       ([panGesture state] == UIGestureRecognizerStateChanged) )
    {
        if ([panGesture state] == UIGestureRecognizerStateBegan) {
            CGPoint point = [panGesture locationInView:self];
            self.lastGestureVelocityTwo = point;

        }
        CGPoint point = [panGesture locationInView:self];

        self.currentAngle = [self getTouchAngle:point];
        self.previousAngle = [self getTouchAngle:self.lastGestureVelocityTwo];

        CGAffineTransform transform = CGAffineTransformRotate( self.moveView.layer.affineTransform,self.currentAngle - self.previousAngle);
        self.moveView.layer.affineTransform = transform;
        self.lastGestureVelocityTwo = point;
    }

}


- (float)getTouchAngle:(CGPoint)touch {
    
    // Translate into cartesian space with origin at the center of a 320-pixel square
    float x = touch.x - 150;
    float y = -(touch.y - 150);
//    NSLog(@"点击视图的坐标 x: %f ,y %f",x,y);
    // Take care not to divide by zero!
    if (y == 0) {
        if (x > 0) {
            return M_PI_2;
        }
        else {
            return 3 * M_PI_2;
        }
    }
    
    float arctan = atanf(x/y);
    
    // Figure out which quadrant we're in
    
    // Quadrant I
    if ((x >= 0) && (y > 0)) {
        return arctan;
    }
    // Quadrant II
    else if ((x < 0) && (y > 0)) {
        return arctan + 2 * M_PI;
    }
    // Quadrant III
    else if ((x <= 0) && (y < 0)) {
        return arctan + M_PI;
    }
    // Quadrant IV
    else if ((x > 0) && (y < 0)) {
        return arctan + M_PI;
    }
    
    return -1;
}


- (void) getterColor{
    CGPoint center = self.moveView.center;
    
    CGFloat xScale = self.image.size.width / self.bounds.size.width;
    CGFloat yScale = self.image.size.height / self.bounds.size.height;
    CGPoint img = CGPointMake(center.x * xScale, center.y * yScale);
    
    
    UIColor *uicolor = [self.image colorAtPixel:img];
    
    
    int R = 0, G = 0, B = 0;
    
    //    UIColor *red = [UIColor blueColor];
    CGColorRef color = [uicolor CGColor];
    
    int numComponents = CGColorGetNumberOfComponents(color);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        R = components[0] * 255;
        G = components[1] * 255;
        B = components[2] * 255;
    }
    
    if ([self.delegate respondsToSelector:@selector(didChangeColor:andRed:green:blue:)]) {
        [self.delegate didChangeColor:uicolor andRed:R green:G blue:B];
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    [self addSubview:self.moveView];
    if (self.first == NO) {
        self.moveView.center = CGPointMake(centerR, centerR);
        self.moveView.backgroundColor = [UIColor redColor];;
        self.moveView.userInteractionEnabled = YES;
        self.moveView.layer.anchorPoint = CGPointMake(0.5, 5.4);
        self.first = YES;
    }

//    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    CGPoint point = [touch locationInView:[touch view]];
//    BOOL isZai =  CGRectContainsPoint(self.moveView.layer.frame,point);
//    if(isZai)
//    {
//        return YES;
//    }
    return YES;
}


@end
