//
//  ViewController.h
//  OpenGL ES 01-GLKit
//
//  Created by Dustin on 17/3/9.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ViewController : GLKViewController
{
    GLuint vertexBufferID;//保存了用于盛放本例中用到的顶点数据的缓存的OpenGl ES标识符
}

@property (nonatomic,strong) GLKBaseEffect *baseEffect;//声明一个GLKBaseEffect实例的指针

@end

