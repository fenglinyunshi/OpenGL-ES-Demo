//
//  ViewController.m
//  OpenGL ES 01-GLKit
//
//  Created by Dustin on 17/3/9.
//  Copyright © 2017年 PicVision. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

typedef struct{
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0}},//lower left corner
    {{0.5f,-0.5f,0.0}},//lower right corner
    {{-0.5f,0.5f,0.0}}//upper left corner

};


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //viewDidLoad方法会将它继承的view的属性值转换为GLKView类型
    GLKView *view = (GLKView *)self.view;
    //使用NSAssert()函数的一个运行时检查会验证self.view是否为正确的类型
    NSAssert([view isKindOfClass:[GLKView class]], @"viewcontroller’s view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];//分配一个新的EAGLContext的实例，并将它初始化为OpenGL ES 2.0
    [EAGLContext setCurrentContext:view.context];//在任何其他的OpenGL ES配置或者渲染之前，应用的GLKview实例的上下文属性都要设置为当前
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(0.4f,//red
                                                   0.6f,//green
                                                   0.2f,//blue
                                                   1.0f);//alpha
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);//设置当前OpenGL ES的上下文的“清除颜色”为不透白色，清除颜色由RGBA颜色元素值组成，用于在上下文的帧缓存被清除时初始化每个像素的颜色值

    /*
     *参数一：要生成缓存标识符的数量
     *参数二：指向生成的标识符的内存保存位置的指针
     */
    glGenBuffers(1, &vertexBufferID);//为缓存生成一个独一无二的标识符
    
    /*
     *参数一：用于指定要绑定那一种类型的缓存，OPenGL ES2.0对于glbindBuffer()的实现只支持两种类型的缓存
     GL_ARRAY_BUFFER：顶点缓冲区对象
     GL_ELEMENT_ARRAY_BUFFER：顶点索引缓冲区对象
     参数二：要绑定缓存的标识符
     */
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);//为接下来的应用绑定缓存
    
    /*
     *参数1：指定要更新当前上下文中所绑定的是哪一种缓存
     *参数2：指定要复制这个缓存字节的数量
     *参数3：复制的字节的地址
     *参数4：缓存在未来的运算中可能将会被怎样使用
     GL_STATIC_DRAW提示会告诉上下文，缓存中的内容适合复制到GPU控制的内存，因为很少对其修改
     GL_DYNAMIC_DRAW会告诉上下文，缓存内的数据会频繁改变，同时提示OpenGL ES以不同的方式来处理缓存的存储
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);//复制数据到缓存中
    
    
}

#pragma mark 每当一个GLKView实例需要重绘时，它都会让保存在视图的上下文属性中的OpenGL ES的上下文称为当前上下文。如果需要的话，GLKView实例会绑定与一个Core Animation层分享的帧缓存，执行其他的标准OpenGL ES配置，并发送一个消息来调用控制器的- glkView: drawInRect:方法。- glkView: drawInRect:是GLKView类的委托方法。
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self.baseEffect prepareToDraw];
    //清除颜色缓冲
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    //启动顶点缓存渲染操作
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    /*告诉OpenGL ES顶点数据在哪里，以及解释为每个顶点保存的数据
     *参数1：指示当前绑定的缓存包含每个顶点的位置信息
     *参数2：指示每个位置有三个部分
     *参数3：告诉OpenGL ES每个部分都保存为一个浮点类型的值
     *参数4：告诉OPenGL ES小数点固定数据是否可以被改变
     *参数5：叫做步幅，他指定了每个顶点的保存需要多少个字节
     *参数6：告诉OpenGL ES可以从当前绑定的顶点缓存的位置访问顶点数据
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3
                          , GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);

    /*绘图
     *参数1：告诉GPU怎么处理在绑定的顶点缓存内的顶点数据
     GL_POINTS //把每一个顶点作为一个点进行处理，顶点n即定义了点n，共绘制N个点
     GL_LINES //把每一个顶点作为一个独立的线段，顶点2n－1和2n之间共定义了n条线段，总共绘制N/2条线段
     GL_LINE_LOOP //绘制从第一个顶点到最后一个顶点依次相连的一组线段，然后最后一个顶点和第一个顶点相连，第n和n+1个顶点定义了线段n，总共绘制n条线段
     GL_LINE_STRIP //绘制从第一个顶点到最后一个顶点依次相连的一组线段，第n和n+1个顶点定义了线段n，总共绘制n－1条线段
     GL_TRIANGLES //把每个顶点作为一个独立的三角形，顶点3n－2、3n－1和3n定义了第n个三角形，总共绘制N/3个三角形
     GL_TRIANGLE_STRIP //绘制一组相连的四边形。每个四边形是由一对顶点及其后给定的一对顶点共同确定的。顶点2n－1、2n、2n+2和2n+1定义了第n个四边形，总共绘制N/2-1个四边形
     GL_TRIANGLE_FAN //绘制一组相连的三角形，三角形是由第一个顶点及其后给定的顶点确定，顶点1、n+1和n+2定义了第n个三角形，总共绘制N-2个三角形
     *参数2：需要渲染的第一个顶点
     *参数3：需要渲染的顶点的个数
     */
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}


#pragma mark 删除不再需要的顶点缓存和上下文
-(void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0!=vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        //设置vertexBufferID为0避免了在对应的缓存被删除后还使用其无效的标识符。
        vertexBufferID = 0;
    }
    
    //设置视图的上下文属性为nil并设置当前的上下文为nil，以便让Cocoa Touch收回所有上下文使用的内存和其他资源
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];

}




@end
