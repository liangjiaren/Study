### Page
//  Quartz2D 在图像中使用了绘画者模型。在绘画者模型中，每个连续的绘制操作都是将一个绘制层放置于一个画布，我们通常称这个画布为 Page。


### Graphics Context
//  Graphics Context 是一个数据类型(CGContextRef)，用于封装 Quartz 绘制图像到输出设备的信息。设备可以是PDF文件、bitmap或者显示器的窗口。 CGContextRef 对应绘画者模式中的 Page。
//  当用 Quartz 绘图时，所有设备相关的特性都包含在我们所使用的Graphics Context 中。我们可以简单地给 Quartz 绘图序列指定不同的 Graphics Context，就可将相同的图像绘制到不同的设备上。
// Quartz提供了 5 种类型的 Graphics Context。Bitmap Graphics Context、PDF Graphics Context、Window Graphics Context、Layer Context、Post Graphics Context。

### 数据类型
//  CGPathRef：用于向量图，可创建路径，并进行填充或描画(stroke)
//  CGImageRef：用于表示bitmap图像和基于采样数据的bitmap图像遮罩
//  CGLayerRef：用于表示可用于重复绘制(如背景)和幕后 (offscreen)绘制的绘画层
//  CGPatternRef：用于重绘图
//  CGShadingRef、CGGradientRef：用于绘制渐变
//  CGFunctionRef：用于定义回调函数，该函数包含一个随机的浮点值参数。当为阴影创建渐变时使用该类型
//  CGColorRef, CGColorSpaceRef：用于告诉Quartz如何解释颜色
//  CGImageSourceRef,CGImageDestinationRef：用于在Quartz中移入移出数据
//  CGFontRef：用于绘制文本
//  CGPDFDictionaryRef, CGPDFObjectRef, CGPDFPageRef, CGPDFStream, CGPDFStringRef, and CGPDFArrayRef：用于访问PDF的元数据
//  CGPDFScannerRef, CGPDFContentStreamRef：用于解析PDF元数据
//  CGPSConverterRef：用于将PostScript转化成PDF。在iOS中不能使用。

### 图形状态
//  可使用函数CGContextSaveGState来保存图形状态，CGContextRestoreGState来还原图形状态。

//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGContextSaveGState(context);
//  CGContextRestoreGState(context);

### 内存管理
//  如果使用含有”Create”或“Copy”单词的函数获取一个对象，当使用完后必须释放(CFRetain 和 CFRelease)
//  如果使用不含有”Create”或“Copy”单词的函数获取一个对象，你将不会拥有对象的引用，不需要释放它。

