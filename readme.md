# 在iOS中如何使用OpenGL画一些简单的图形
本篇文章中，主要实现的是如何使用OpenGL画一个三角形和矩形，我分为下几个步骤来说明：
- OpenGL的语言GLSL
- 编译OpenGL的语言
- 创建顶点缓冲区
- 将图形画出来

## OpenGL的语言GLSL
它和C语言类似，可以声明一些变量（`a_Position`），有一个main的入口函数，有系统内置的变量（`gl_Position`）。
```c
attribute vec3 a_Position;

void main(void) {
    gl_Position = vec4(a_Position, 1.0);
}
```
## 使用OpenGL的语言
和我们的代码一样，要使用这些GLSL，还需要编译它们，将它们加载到内存中。整个加载、编译过程有这3步：
- 加载shader字符串
- 根据字符串创建shader对象
- 编译shader对象
```objc
- (GLuint)compileShader:(NSString *)shaderName withType:(GLenum)shaderType {
    //加载shader字符串
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        return -1;
    }
    
    //shader
    GLuint shaderHandle = glCreateShader(shaderType);
    
    //将字符串代码转为shader
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //编译shader
    glCompileShader(shaderHandle);
    
    //检查编译结果
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        return -1;
    }
    
    return shaderHandle;
}
```
编译好后，我们还需要创建一个管道，将内存中的这些编译好的东西交给GPU。之后CPU中更新的数据都是通过这个管道传送给GPU的。
```objc
- (void)compileVertexShader:(NSString *)vertexShader
             fragmentShader:(NSString *)fragmentShader {
    GLuint vertexShaderName = [self compileShader:vertexShader
                                         withType:GL_VERTEX_SHADER];
    GLuint fragmentShaderName = [self compileShader:fragmentShader
                                           withType:GL_FRAGMENT_SHADER];
    
    //创建program
    _programHandle = glCreateProgram();
    
    //绑定着色器
    glAttachShader(_programHandle, vertexShaderName);
    glAttachShader(_programHandle, fragmentShaderName);
    
    glLinkProgram(_programHandle);
    
    //检查program结果
    GLint linkSuccess;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(_programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
    }
    
    // 删除着色器，它们已经链接到我们的程序中了，已经不再需要了
    glDeleteShader(vertexShaderName);
    glDeleteShader(fragmentShaderName);
}
```
## 创建顶点缓冲区
我们这里画两个图形，所以创建两个顶点缓冲区，并将对应的顶点坐标存储到顶点缓冲区中。
```objc
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
```
## 将图形画出来
我们先指定好用哪个通道，然后再通过这个通道传输数据，并将它们显示出来。
`glEnableVertexAttribArray(0)` 表示绑定我们编写的GLSL中的第一个参数。
`glDrawArrays(GL_TRIANGLES, 0, 3)` 以三角形的方式画3个点。
`glDrawArrays(GL_TRIANGLE_FAN, 0, 4)` 以三角形射线的方式画4个点，画了两个三角形。
![几种画图方式](https://upload-images.jianshu.io/upload_images/3277096-3313acfff8c1e4d0.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

```objc
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    GLKView *glView = (GLKView *)self.view;
    [EAGLContext setCurrentContext:glView.context];
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [_triangleShader prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _triangleVBO);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_rectangleShader prepareToDraw];
    glBindBuffer(GL_ARRAY_BUFFER, _rectangleVBO);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}
```
运行项目，可以看到一个三角形和一个矩形，它们都是红色的。
[Github地址](https://github.com/zhonglaoban/OpenGL002)



