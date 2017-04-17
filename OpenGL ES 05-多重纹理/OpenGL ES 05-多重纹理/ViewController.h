//
//  ViewController.h
//  OpenGL ES 05-多重纹理
//
//  Created by Dustin on 2017/4/17.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

@interface ViewController :GLKViewController

@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

