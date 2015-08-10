/*
 
 File: CoreTextArcView.m (iOS version)
 
 Abstract: Defines and implements the CoreTextArcView custom UIView subclass to
 draw text on a curve.
 
 Based on CoreTextArcView provided by Apple for Mac OS X https://developer.apple.com/library/mac/#samplecode/CoreTextArcCocoa/Introduction/Intro.html
 
 Ported to iOS (& added color, arcsize features) August 2011 by Alec Vance, Juggleware LLC http://juggleware.com/
 
 
 */

#import "CoreTextArcView.h"
#import <AssertMacros.h>
#import <QuartzCore/QuartzCore.h>

#define ARCVIEW_DEBUG_MODE          NO

#define ARCVIEW_DEFAULT_FONT_NAME	@"Helvetica"
#define ARCVIEW_DEFAULT_FONT_SIZE	64.0
#define ARCVIEW_DEFAULT_RADIUS		150.0
#define ARCVIEW_DEFAULT_ARC_SIZE    180.0



@implementation CoreTextArcView

- (id)initWithFrame:(CGRect)frame font:(UIFont *)font text:(NSString *)text color:(UIColor *)color{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.font = font;
        self.text = text;
        self.radius = -1 * (frame.size.width > frame.size.height ? frame.size.height / 2 : frame.size.width / 2);
        _arcSize = 2* M_PI;
        self.showsGlyphBounds = NO;
        self.showsLineMetrics = NO;
        self.dimsSubstitutedGlyphs = NO;
        self.color = color;
        self.shiftH = self.shiftV = 0.0f;
        
    }
    return self;
}

typedef struct GlyphArcInfo {
	CGFloat			width;
	CGFloat			angle;	// in radians
} GlyphArcInfo;


// this constants come from a single case ( fontSize = 22 | circle diameter = 250px | lower circle diameter 50px | 0.12f is a proportional acceptable value of 250px diameter | 0.18f is a proportional acceptable value of 50px | 0.035f is a proportional acceptable value of "big" chars
#define kReferredCharSpacing 0.12f
#define kReferredFontSize 22.f
#define kReferredMajorDiameter 250.f
#define kReferredMinorDiameter 50.f
#define kReferredMinorSpacingFix 0.18f
#define kReferredBigCharSpacingFix  0.035f

static void PrepareGlyphArcInfo(UIFont* font,CGFloat containerRadius,CTLineRef line, CFIndex glyphCount, GlyphArcInfo *glyphArcInfo, CGFloat arcSizeRad)
{
    NSArray *runArray = (NSArray *)CTLineGetGlyphRuns(line);
    
    CGFloat curMaxTypoWidth = 0.f;
    CGFloat curMinTypoWidth = 0.f;
    
    // Examine each run in the line, updating glyphOffset to track how far along the run is in terms of glyphCount.
    CFIndex glyphOffset = 0;
    for (id run in runArray) {
        CFIndex runGlyphCount = CTRunGetGlyphCount((CTRunRef)run);
        
        // Ask for the width of each glyph in turn.
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            glyphArcInfo[runGlyphIndex + glyphOffset].width = CTRunGetTypographicBounds((CTRunRef)run, CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
            
            if (curMaxTypoWidth < glyphArcInfo[runGlyphIndex + glyphOffset].width)
                curMaxTypoWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            
            if (curMinTypoWidth > glyphArcInfo[runGlyphIndex + glyphOffset].width || curMinTypoWidth == 0)
                curMinTypoWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            
        }
        
        glyphOffset += runGlyphCount;
    }
    
    //double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
    
    glyphArcInfo[0].angle = M_PI_2; // start at the bottom circle
    
    CFIndex lineGlyphIndex = 1;
    
    // based on font size. (supposing that with fontSize = 22 we could use 0.12)
    CGFloat maxCharSpacing = font.pointSize * kReferredCharSpacing / kReferredFontSize;
    
    // for diameter minor than referred 250
    if ((fabs(containerRadius)*2) < kReferredMajorDiameter)
        maxCharSpacing = maxCharSpacing + kReferredMinorSpacingFix * kReferredMinorDiameter / (fabs(containerRadius)*2);
    
    CGFloat startAngle = fabs(glyphArcInfo[0].angle);
    CGFloat endAngle = startAngle;
    
    for (; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
        
        CGFloat deltaWidth = curMaxTypoWidth - glyphArcInfo[lineGlyphIndex].width;
        
        // fix applied to large characters like uppercase letters or symbols
        CGFloat bigCharFix = (glyphArcInfo[lineGlyphIndex-1].width == curMaxTypoWidth || (glyphArcInfo[lineGlyphIndex-1].width+2) >= curMaxTypoWidth ? kReferredBigCharSpacingFix : 0 );
        
        glyphArcInfo[lineGlyphIndex].angle = - (maxCharSpacing * (glyphArcInfo[lineGlyphIndex].width + deltaWidth ) / curMaxTypoWidth) - bigCharFix;
        
        endAngle += fabs(glyphArcInfo[lineGlyphIndex].angle);
    }
    
    // center text to bottom
    glyphArcInfo[0].angle = glyphArcInfo[0].angle + (endAngle - startAngle ) / 2;
    
}

// ensure that redraw occurs.
-(void)setText:(NSString *)text{
    _string = text;
    
    [self setNeedsDisplay];
}

//set arc size in degrees (180 = half circle)
-(void)setArcSize:(CGFloat)degrees{
    _arcSize = degrees * M_PI/180.0;
}

//get arc size in degrees
-(CGFloat)arcSize{
    return _arcSize * 180.0/M_PI;
}

- (void)drawRect:(CGRect)rect {
    // Don't draw if we don't have a font or string
    if (self.font == NULL || self.text == NULL)
        return;
    
    // Initialize the text matrix to a known value
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Reset the transformation
    //Doing this means you have to reset the contentScaleFactor to 1.0
    CGAffineTransform t0 = CGContextGetCTM(context);
    
    CGFloat xScaleFactor = t0.a > 0 ? t0.a : -t0.a;
    CGFloat yScaleFactor = t0.d > 0 ? t0.d : -t0.d;
    t0 = CGAffineTransformInvert(t0);
    if (xScaleFactor != 1.0 || yScaleFactor != 1.0)
        t0 = CGAffineTransformScale(t0, xScaleFactor, yScaleFactor);
    
    CGContextConcatCTM(context, t0);
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    NSAttributedString *attStr = self.attributedString;
    CFAttributedStringRef asr = (__bridge CFAttributedStringRef)attStr;
    CTLineRef line = CTLineCreateWithAttributedString(asr);
    assert(line != NULL);
    
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    if (glyphCount == 0) {
        CFRelease(line);
        return;
    }
    
    GlyphArcInfo *  glyphArcInfo = (GlyphArcInfo*)calloc(glyphCount, sizeof(GlyphArcInfo));
    PrepareGlyphArcInfo(self.font, self.radius, line, glyphCount, glyphArcInfo, _arcSize);
    
    // Move the origin from the lower left of the view nearer to its center.
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, CGRectGetMidX(rect)+_shiftH, CGRectGetMidY(rect)+_shiftV);
    
    if(ARCVIEW_DEBUG_MODE){
        // Stroke the arc in red for verification.
        CGContextBeginPath(context);
        CGContextAddArc(context, 0.0, 0.0, self.radius, M_PI_2+_arcSize/2.0, M_PI_2-_arcSize/2.0, 1);
        CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextStrokePath(context);
    }
    
    // Rotate the context 90 degrees counterclockwise (per 180 degrees)
    CGContextRotateCTM(context, M_PI_2);
    
    // Now for the actual drawing. The angle offset for each glyph relative to the previous glyph has already been calculated; with that information in hand, draw those glyphs overstruck and centered over one another, making sure to rotate the context after each glyph so the glyphs are spread along a semicircular path.
    
    CGPoint textPosition = CGPointMake(0.0, self.radius);
    CGContextSetTextPosition(context, textPosition.x, textPosition.y);
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    
    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    for (; runIndex < runCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        Boolean drawSubstitutedGlyphsManually = false;
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        
        // Determine if we need to draw substituted glyphs manually. Do so if the runFont is not the same as the overall font.
        if (self.dimsSubstitutedGlyphs && ![self.font isEqual:(__bridge UIFont *)runFont]) {
            drawSubstitutedGlyphsManually = true;
        }
        
        CFIndex runGlyphIndex = 0;
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            CGContextRotateCTM(context, -(glyphArcInfo[runGlyphIndex + glyphOffset].angle));
            
            // Center this glyph by moving left by half its width.
            CGFloat glyphWidth = glyphArcInfo[runGlyphIndex + glyphOffset].width;
            CGFloat halfGlyphWidth = glyphWidth / 2.0;
            CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth, textPosition.y);
            
            // Glyphs are positioned relative to the text position for the line, so offset text position leftwards by this glyph's width in preparation for the next glyph.
            textPosition.x -= glyphWidth;
            
            CGAffineTransform textMatrix = CTRunGetTextMatrix(run);
            textMatrix.tx = positionForThisGlyph.x;
            textMatrix.ty = positionForThisGlyph.y;
            CGContextSetTextMatrix(context, textMatrix);
            
            CTRunDraw(run, context, glyphRange);
        }
        
        glyphOffset += runGlyphCount;
    }
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextSetAlpha(context,0.0);
    CGContextFillRect(context, rect);
    
    CGContextRestoreGState(context);
    
    free(glyphArcInfo);
    CFRelease(line);    
    
}

@synthesize font = _font;
@synthesize text = _string;
@synthesize radius = _radius;
@synthesize color = _color;
@synthesize arcSize = _arcSize;
@synthesize shiftH = _shiftH;
@synthesize shiftV = _shiftV;

@dynamic attributedString;
- (NSAttributedString *)attributedString {
	// Create an attributed string with the current font and string.
	assert(self.font != nil);
	assert(self.text != nil);
	
	// Create our attributes...
    
    // font
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    
    // color
	CGColorRef colorRef = self.color.CGColor;
    
    // pack it into attributes dictionary
    
	NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)fontRef, (id)kCTFontAttributeName,
                                    colorRef, (id)kCTForegroundColorAttributeName,
                                    nil];
	assert(attributesDict != nil);
    
	
	// Create the attributed string
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.text attributes:attributesDict];
    
    CFRelease(fontRef);
    
	return attrString;
}

@dynamic showsGlyphBounds;
- (BOOL)showsGlyphBounds {
	return _flags.showsGlyphBounds;
}

- (void)setShowsGlyphBounds:(BOOL)show {
	_flags.showsGlyphBounds = show ? 1 : 0;
}

@dynamic showsLineMetrics;
- (BOOL)showsLineMetrics {
	return _flags.showsLineMetrics;
}

- (void)setShowsLineMetrics:(BOOL)show {
	_flags.showsLineMetrics = show ? 1 : 0;
}

@dynamic dimsSubstitutedGlyphs;
- (BOOL)dimsSubstitutedGlyphs {
	return _flags.dimsSubstitutedGlyphs;
}

- (void)setDimsSubstitutedGlyphs:(BOOL)dim {
	_flags.dimsSubstitutedGlyphs = dim ? 1 : 0;
}

@end
