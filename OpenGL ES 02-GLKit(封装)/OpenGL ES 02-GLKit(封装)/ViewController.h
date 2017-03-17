//
//  ViewController.h
//  OpenGL ES 02-GLKit(封装)
//
//  Created by Dustin on 17/3/17.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

@interface ViewController :GLKViewController

@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

