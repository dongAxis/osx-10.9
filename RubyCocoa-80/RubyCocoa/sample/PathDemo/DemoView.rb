#
#  DemoView.rb
#  PathDemo
#
#  Created by Laurent Sansonetti on 1/3/07.
#  Copyright (c) 2007 Apple Computer. All rights reserved.
#

class NSRect
  def to_cgrect
    OSX::CGRect.new(
      OSX::CGPoint.new(origin.x, origin.y),
      OSX::CGSize.new(size.width, size.height))
  end
end

class DemoView < NSView

  attr_accessor :demoNumber

  def initWithFrame(frameRect)
    if super_initWithFrame(frameRect)
      @demoNumber = 0
      return self
    end
  end

  def drawRect(rect)
    r = rect.to_cgrect
	context = NSGraphicsContext.currentContext.graphicsPort
	
    CGContextSetGrayFillColor(context, 1.0, 1.0)
    CGContextFillRect(context, r)

    case @demoNumber
    when 0 then rectangles(context, r)
    when 1 then circles(context, r)
    when 2 then bezierPaths(context, r)
    when 3 then circleClipping(context, r)
    else
      NSLog("Invalid demo number #{@demoNumber}")
    end
	
	unless NSGraphicsContext.currentContextDrawingToScreen
	  # Cocoa's printing mechanism assumes that the current context object
	  # has a retain count of 1 during the printing.
	  # RubyCocoa retains the context object until the next Ruby garbage
	  # collection, which is unfortunately not predictable.
	  # So we need to manually release the object.
	  context.release
	end
  end

  def knowsPageRange(range)
	# The range is passed by reference.
	range.location = 1
	range.length = 1
    true
  end

  def rectForPage(page)
    bounds
  end

  private

  # The various demo functions

  RAND_MAX = 2147483647.0
  def randf(min, max)
    min + (max - min) * rand(RAND_MAX) / RAND_MAX
  end
  
  def setRandomFillColor(context)
    CGContextSetRGBFillColor(context, randf(0, 1), randf(0, 1),
        randf(0, 1), randf(0, 1)) 
  end

  def setRandomStrokeColor(context)
    CGContextSetRGBStrokeColor(context, randf(0, 1), randf(0, 1),
        randf(0, 1), randf(0, 1))
  end

  def randomPointInRect(rect)
    x = randf(rect.origin.x, rect.origin.x + rect.size.width)
    y = randf(rect.origin.y, rect.origin.y + rect.size.height)
    CGPoint.new(x, y)
  end
  
  def randomRectInRect(rect)
    p = randomPointInRect(rect)
    q = randomPointInRect(rect)
    CGRect.new(CGPoint.new(p.x, p.y), CGSize.new(q.x - p.x, q.y - p.y))
  end

  def rectangles(context, rect)
    20.times do |k|
      if (k % 2) == 0
        setRandomFillColor(context)
        CGContextFillRect(context, randomRectInRect(rect))
      else
        setRandomStrokeColor(context)
        CGContextSetLineWidth(context, 2 + rand(10))
        CGContextStrokeRect(context, randomRectInRect(rect))
      end
    end
  end

  def circles(context, rect)
    # Draw random circles (some stroked, some filled).
    
    20.times do |k|
      r = randomRectInRect(rect)
      w, h = r.size.width, r.size.height
      CGContextBeginPath(context)
      CGContextAddArc(context, r.origin.x + (w / 2.0), r.origin.y + (h / 2.0),
          (w < h) ? w : h, 0, 2 * Math::PI, false)
      CGContextClosePath(context)
      if (k % 2) == 0
  	    setRandomFillColor(context)
        CGContextFillPath(context)
      else
        setRandomStrokeColor(context)
        CGContextSetLineWidth(context, 2 + rand(10))
        CGContextStrokePath(context)
      end
    end
  end

  def bezierPaths(context, rect)
    20.times do |k|
      numberOfSegments = 1 + rand(8)
      CGContextBeginPath(context)
      p = randomPointInRect(rect)
      CGContextMoveToPoint(context, p.x, p.y)
      numberOfSegments.to_i.times do |j|
        p = randomPointInRect(rect)
        if (j % 2) == 0
          CGContextAddLineToPoint(context, p.x, p.y)
        else
          c1, c2 = randomPointInRect(rect), randomPointInRect(rect)
          CGContextAddCurveToPoint(context, c1.x, c1.y,
              c2.x, c2.y, p.x, p.y)
        end
      end
      if (k % 2) == 0
        setRandomFillColor(context)
        CGContextClosePath(context)
        CGContextFillPath(context)
      else
        setRandomStrokeColor(context)
        CGContextSetLineWidth(context, 2 + rand(10))
        CGContextStrokePath(context)
      end
    end
  end

  def circleClipping(context, rect)
    w, h = rect.size.width, rect.size.height

    # Draw a random path through a circular clip.
    CGContextBeginPath(context)
    CGContextAddArc(context, rect.origin.x + (w / 2.0), rect.origin.y + (h / 2.0),
		    ((w < h) ? w : h) / 2.0, 0, 2 * Math::PI, false)
    CGContextClosePath(context)
    CGContextClip(context)
    
    # Draw something into the clip.
    bezierPaths(context, rect)
    
    # Draw a clip path on top as a black stroked circle.
    CGContextBeginPath(context)
    CGContextAddArc(context, rect.origin.x + (w / 2.0), rect.origin.y + (h / 2.0),
		    ((w < h) ? w : h) / 2.0, 0, 2 * Math::PI, false)
    CGContextClosePath(context)
    CGContextSetLineWidth(context, 1)
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1)
    CGContextStrokePath(context)
  end

end
