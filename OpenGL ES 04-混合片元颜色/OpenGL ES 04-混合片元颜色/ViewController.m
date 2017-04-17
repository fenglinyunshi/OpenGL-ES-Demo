//
//  ViewController.m
//  OpenGL ES 04-混合片元颜色
//
//  Created by Dustin on 2017/4/17.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface ViewController ()

@property (nonatomic,strong)GLKTextureInfo* info;
@property (nonatomic,strong)GLKTextureInfo* info1;

@end

@implementation ViewController

typedef struct{
    GLKVector3 positionCoords;//GLKVector3类型的positionCoords
    GLKVector2 textureCoords;//GLKVector2类型的纹理坐标
}SceneVertex;

//初始化位置坐标和纹理坐标
static const SceneVertex vertices[] = {
    {{-0.5f,-0.4f,0.0f},{0.0f,0.0f}},//前面三个数字是位置坐标，后面2个数字是纹理坐标
    {{0.5f,-0.4f,0.0f},{1.0f,0.0f}},
    {{-0.5f,0.4f,0.0f},{0.0f,1.0f}},
    {{0.5f,0.4f,0.0},{1.0f,1.0f}},
    {{-0.1f,0.20f,0.0f},{0.0f,0.0f}},//蜜蜂的坐标
    {{0.1f,0.20f,0.0f},{1.0f,0.0f}},
    {{-0.1f,0.30f,0.0f},{0.0f,1.0f}},
    {{0.1f,0.30f,0.0},{1.0f,1.0f}}

};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *view = (GLKView *)self.view;
    
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f,//red
                                                   1.0f,//green
                                                   1.0f,//blue
                                                   1.0f);
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    
    /*1、为缓存生成一个独一无二的标识符
     *2、为接下来的应用绑定缓存
     *3、复制数据到缓存中
     */
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices)/sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    
    CGImageRef imageRef = [[UIImage imageNamed:@"flower.jpg"] CGImage];
    self.info = [GLKTextureLoader textureWithCGImage:imageRef options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [NSNumber numberWithBool:YES],
                                                                       GLKTextureLoaderOriginBottomLeft, nil] error:NULL];//接受一个CGImageRef并创建一个新的包含CGImageRef的像素数据的OpenGL ES纹理缓存，options参数接受一个存储了用于指定GLKTextureLoader怎么解析加载的图像数据的键值对的NSDictionary。可用选项之一是指示GLKTextureLoader为加载的图像生成MIP贴图。
    
    CGImageRef imageRef1 = [[UIImage imageNamed:@"honeybee"] CGImage];
    //GLKTextureLoaderOriginBottomLeft确保画出的图像与UIKit坐标一致，不颠倒
    self.info1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [NSNumber numberWithBool:YES],
                                                                       GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    
    //加载第二个纹理并开启与像素颜色渲染缓存的混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
}

#pragma mark 这两个方法每帧都执行一次（循环执行），执行频率与屏幕刷新率相同。第一次循环时，先调用“glkView”再调用“update”。一般，将场景数据变化放在“update”中，而渲染代码则放在“glkView”中。
- (void)update{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    /*4、启动顶点缓存渲染操作
     *5、告诉OpenGL ES顶点数据在哪里，以及解释为每个顶点保存的数据
     */
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    
    /*4、启动纹理缓存渲染操作
     *5、告诉OpenGL ES纹理数据在哪里，以及解释为每个纹理保存的数据
     */
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    //设置baseEffect的texture2d0属性和使用一个新的纹理缓存。GLKTextureInfo类封装了与刚创建的纹理缓存相关的信息，包含他的尺寸、是否包含MIP贴图、OpenGL ES标识符、名字以及用于纹理的OpenGL ES目标等。（纹理1）
    self.baseEffect.texture2d0.name = self.info.name;
    self.baseEffect.texture2d0.target = self.info.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_STRIP startVertexIndex:0 numberOfVertices:4];
    
    //设置baseEffect的texture2d0属性和使用一个新的纹理缓存。GLKTextureInfo类封装了与刚创建的纹理缓存相关的信息，包含他的尺寸、是否包含MIP贴图、OpenGL ES标识符、名字以及用于纹理的OpenGL ES目标等。（纹理2）
    self.baseEffect.texture2d0.name = self.info1.name;
    self.baseEffect.texture2d0.target = self.info1.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_STRIP startVertexIndex:4 numberOfVertices:4];//从第5个顶点开始数4个顶点

    
    
}

- (void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer = nil;
    
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end
