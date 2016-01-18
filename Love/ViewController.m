//
//  ViewController.m
//  Love
//
//  Created by 金小白 on 16/1/19.
//  Copyright © 2016年 金小白. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface ViewController ()

@property (nonatomic, strong) CALayer *bgLayer;
@property (nonatomic, strong) CALayer *stringLayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化界面
    [self setupView];
    
    [self setupStringLayer];
    
    [self startAnimate];
}

- (void)setupView {
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 44)];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    
    self.bgLayer = [CALayer layer];
    self.bgLayer.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64);
    [self.view.layer addSublayer:self.bgLayer];
}

- (void)setupStringLayer {
    
    if (self.stringLayer) {
        [self.stringLayer removeFromSuperlayer];
        self.stringLayer = nil;
    }
    
    CGMutablePathRef stringPaths = CGPathCreateMutable();
    
    CTFontRef stringFont = CTFontCreateWithName(CFSTR("HelveticaNeue-UltraLight"), 44, NULL);
    
    NSDictionary *attDic = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)stringFont,kCTFontAttributeName, nil];
    
    NSAttributedString *displayAttStr = [[NSAttributedString alloc] initWithString:@"Why are u so diao?" attributes:attDic];
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)displayAttStr);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    for (CFIndex runIndex = 0; runIndex < CFArrayGetCount(runArray); runIndex++) {
        
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            {
                CGPathRef stringPath = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform transform = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(stringPaths, &transform, stringPath);
                CGPathRelease(stringPath);
            }
        }
        
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:stringPaths]];
    
    CFRelease(line);
    CFRelease(stringFont);
    CGPathRelease(stringPaths);
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.bgLayer.bounds;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [UIColor colorWithRed:234.0/255 green:84.0/255 blue:87.0/255 alpha:1].CGColor;
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    self.stringLayer = pathLayer;
    [self.bgLayer addSublayer:self.stringLayer];
    
    self.bgLayer.speed = 0;
    self.bgLayer.timeOffset = 0;
}

- (void)sliderChanged:(UISlider *)slider {
    self.bgLayer.timeOffset = slider.value;
}

- (void)startAnimate {
    [self.stringLayer removeAllAnimations];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [self.stringLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void)dealloc {
    self.stringLayer = nil;
    self.bgLayer = nil;
}

@end
