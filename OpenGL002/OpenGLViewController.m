//
//  OpenGLViewController.m
//  OpenGL001
//
//  Created by 钟凡 on 2020/12/11.
//

#import "OpenGLViewController.h"
#import "ZFShader.h"

@interface OpenGLViewController ()

@property (nonatomic, assign) GLuint triangleVBO;
@property (nonatomic, assign) GLuint rectangleVBO;

@property (nonatomic, strong) ZFShader *triangleShader;
@property (nonatomic, strong) ZFShader *rectangleShader;

@end

@implementation OpenGLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *glView = (GLKView *)self.view;
    glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glView.context];
    
    [self setupShader];
    [self setupVBO];
}
- (void)setupShader {
    _triangleShader = [[ZFShader alloc] initWithVertexShader:@"triangle.vs" fragmentShader:@"triangle.fs"];
    _rectangleShader = [[ZFShader alloc] initWithVertexShader:@"rectangle.vs" fragmentShader:@"rectangle.fs"];
}
- (void)setupVBO {
    GLfloat triangleVertices[] = {
        -0.4, 0.0, 0.0,
         0.0, 0.4, 0.0,
         0.5, 0.0, 0.0,
    };
    glGenBuffers(1, &_triangleVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _triangleVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(triangleVertices), triangleVertices, GL_STATIC_DRAW);
    
    GLfloat rectangleVertices[] = {
        -0.4, -0.4, 0.0,
        -0.4, -0.8, 0.0,
         0.4, -0.8, 0.0,
         0.4, -0.4, 0.0,
    };
    glGenBuffers(1, &_rectangleVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _rectangleVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(rectangleVertices), rectangleVertices, GL_STATIC_DRAW);
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    GLKView *glView = (GLKView *)self.view;
    [EAGLContext setCurrentContext:glView.context];
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_triangleShader prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _triangleVBO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_rectangleShader prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _rectangleVBO);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}
@end
