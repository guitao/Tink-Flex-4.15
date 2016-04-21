/*
Copyright (c) 2010 Tink Ltd - http://www.tink.ws

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package ws.tink.spark.layouts
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IInvalidating;
	import mx.core.ILayoutElement;
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.mx_internal;
	import mx.effects.EffectInstance;
	import mx.effects.IEffect;
	import mx.effects.IEffectInstance;
	import mx.events.EffectEvent;
	
	import spark.components.supportClasses.GroupBase;
	import spark.effects.Fade;
	import spark.effects.Move;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;
	import spark.utils.BitmapUtil;
	
	import ws.tink.spark.effects.StackEffect;
	import ws.tink.spark.effects.effectInstances.StackEffectInstance;
	import ws.tink.spark.layouts.supportClasses.NavigatorLayoutBase;
	
	use namespace mx_internal;
	
	/**
	 *  An StackLayout class shows a single element at a time..
	 * 
	 *  <p>The horizontal position of the shown element is determined by the layout's
	 *  <code>horizontalAlign</code> property.</p>
	 * 
	 *  <p>The vertical position of the shown element is determined by the layout's
	 *  <code>verticalAlign</code> property.</p>
	 * 
	 *  <p>The width of each element is calculated according to the following rules,
	 *  listed in their respective order of precedence (element's minimum width and
	 *  maximum width are always respected):</p>
	 *  <ul>
	 *    <li>If <code>horizontalAlign</code> is <code>"justify"</code>, 
	 *    then set the element's width to the container width.</li>
	 *
	 *    <li>If <code>horizontalAlign</code> is <code>"contentJustify"</code>,
	 *    then set the element's width to the maximum between the container's width 
	 *    and all elements' preferred width.</li>
	 *
	 *    <li>If the element's <code>percentWidth</code> is set, then calculate the element's
	 *    width as a percentage of the container's width.</li>
	 *
	 *    <li>Set the element's width to its preferred width.</li>
	 *  </ul>
	 *
	 *  <p>The height of each element is calculated according to the following rules,
	 *  listed in their respective order of precedence (element's minimum height and
	 *  maximum height are always respected):</p>
	 *  <ul>
	 *    <li>If the <code>verticalAlign</code> property is <code>"justify"</code>,
	 *   then set the element's height to the container height.</li>
	 *
	 *    <li>If the <code>verticalAlign</code> property is <code>"contentJustify"</code>, 
	 *    then set the element's height to the maximum between the container's height 
	 *    and all elements' preferred height.</li>
	 *
	 *    <li>If the element's <code>percentHeight</code> property is set, 
	 *    then calculate the element's height as a percentage of the container's height.</li>
	 *
	 *    <li>Set the element's height to its preferred height.</li>
	 *  </ul>
	 * 
	 *  @mxml
	 *
	 *  <p>The <code>&lt;st:StackLayout&gt;</code> tag inherits all of the
	 *  tag attributes of its superclass, and adds the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;st:StackLayout
	 *    <strong>Properties</strong>
	 *    horizontalAlign="center|contentJustify|justify|left|right"
	 *    verticalAlign="contentJustify|bottom|justify|middle|top"
	 *  /&gt;
	 *  </pre>
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public class StackLayout extends NavigatorLayoutBase
	{
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function StackLayout()
		{
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private var _bitmapFrom		: BitmapData;
		
		/**
		 *  @private
		 */
		private var _bitmapTo		: BitmapData
		
		/**
		 *  @private
		 */
		private var _stackIndex		: int = -2;
		
		/**
		 *  @private
		 */		
		public var effect			: StackEffect;
		
		/**
		 *  @private
		 */
		private var _effectInstance		: StackEffectInstance;
		
		/**
		 *  @private
		 */
		private var _selectedElement		: IVisualElement;
		
		/**
		 *  @private
		 */
		private var _elementMaxDimensions		: ElementMaxDimensions;
		
		/**
		 *  @private
		 */
		private var _numElementsInLayout		: int;
		
		/**
		 *  @private
		 */
		private var _numElementsNotInLayout		: int;
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  The storage property is in the NavigatorLayoutBase.
		 */
		
		[Inspectable(category="General", enumeration="false,true", defaultValue="false")]
		
		/**
		 *  If <code>true</code>, an item must always be selected in the layout.
		 *  If the value is <code>true</code>, the <code>selectedIndex</code> property 
		 *  is always set to a value between 0 and (<code>dataProvider.length</code> - 1).
		 *
		 *  @default true
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get requireSelection():Boolean
		{ 
			return _requireSelection;
		}
		/**
		 *  @private
		 */
		public function set requireSelection( value:Boolean ):void
		{
			if (_requireSelection == value)
				return;
			_requireSelection = value;
		}
		
		
		//----------------------------------
		//  verticalAlign
		//----------------------------------    
		
		/**
		 *  @private
		 *  Storage property for verticalAlign.
		 */
		private var _verticalAlign:String = VerticalAlign.JUSTIFY;
		
		[Inspectable(category="General", enumeration="top,bottom,middle,justify,contentJustify", defaultValue="justify")]
		/** 
		 *  The vertical alignment of layout elements.
		 * 
		 *  <p>If the value is <code>"bottom"</code>, <code>"middle"</code>, 
		 *  or <code>"top"</code> then the layout elements are aligned relative 
		 *  to the container's <code>contentHeight</code> property.</p>
		 * 
		 *  <p>If the value is <code>"contentJustify"</code> then the actual
		 *  height of the layout element is set to 
		 *  the container's <code>contentHeight</code> property. 
		 *  The content height of the container is the height of the largest layout element. 
		 *  If all layout elements are smaller than the height of the container, 
		 *  then set the height of all the layout elements to the height of the container.</p>
		 * 
		 *  <p>If the value is <code>"justify"</code> then the actual height
		 *  of the layout elements is set to the container's height.</p>
		 *
		 *  <p>This property does not affect the layout's measured size.</p>
		 *  
		 *  @default "justify"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}
		/**
		 *  @private
		 */
		public function set verticalAlign(value:String):void
		{
			if( value == _verticalAlign ) return;
			
			_verticalAlign = value;
			
			invalidateTargetDisplayList();
		}
		
		
		//----------------------------------
		//  horizontalAlign
		//----------------------------------  
		
		/**
		 *  @private
		 *  Storage property for horizontalAlign.
		 */
		private var _horizontalAlign:String = HorizontalAlign.JUSTIFY;
		
		[Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="justify")]
		/** 
		 *  The horizontal alignment of layout elements.
		 * 
		 *  <p>If the value is <code>"left"</code>, <code>"right"</code>, or <code>"center"</code> then the 
		 *  layout element is aligned relative to the container's <code>contentWidth</code> property.</p>
		 * 
		 *  <p>If the value is <code>"contentJustify"</code>, then the layout element's actual
		 *  width is set to the <code>contentWidth</code> of the container.
		 *  The <code>contentWidth</code> of the container is the width of the largest layout element. 
		 *  If all layout elements are smaller than the width of the container, 
		 *  then set the width of all layout elements to the width of the container.</p>
		 * 
		 *  <p>If the value is <code>"justify"</code> then the layout element's actual width
		 *  is set to the container's width.</p>
		 *
		 *  <p>This property does not affect the layout's measured size.</p>
		 *  
		 *  @default "justify"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}
		/**
		 *  @private
		 */
		public function set horizontalAlign(value:String):void
		{
			if( value == _horizontalAlign ) return;
			
			_horizontalAlign = value;
			
			invalidateTargetDisplayList();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  target
		//----------------------------------    
		
		/**
		 *  @private
		 */
		override public function set target(value:GroupBase):void
		{
			if( target == value ) return;
			
			super.target = value;
			
			_numElementsInLayout = 0;
			_elementMaxDimensions = new ElementMaxDimensions();
		}
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override public function measure():void
		{
			super.measure();
			//TODO need to implement measure and add ASDocs
		}
		
		/**
		 *  @private
		 */
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if( _effectInstance ) _effectInstance.end();
			
			super.updateDisplayList( unscaledWidth, unscaledHeight );
			
			var i:int;
			
			if( !renderingData )
			{
				if( _numElementsInLayout != numElementsInLayout )
				{
					_numElementsInLayout = numElementsInLayout;
					for( i = 0; i < _numElementsInLayout; i++ )
					{
						elements[ indicesInLayout[ i ] ].visible = ( i == selectedIndex );
					}
				}
				
				if( _numElementsNotInLayout != numElementsNotInLayout )
				{
					_numElementsNotInLayout = numElementsNotInLayout;
					for( i = 0; i < _numElementsNotInLayout; i++ )
					{
						elements[ indicesInLayout[ i ] ].visible = true;
					}
				}
			}
			
			if( _stackIndex != selectedIndex )
			{
				if( effect && _bitmapFrom && unscaledWidth && unscaledHeight )
				{
					// Validate the selectedElement before drowing.
					if( _selectedElement is IInvalidating )
						IInvalidating( _selectedElement ).validateNow();
					
					_bitmapTo = new BitmapData( unscaledWidth, unscaledHeight, true, 0x00ffffff );
					_bitmapTo.draw( target );
					
					Object( effect ).bitmapTo = _bitmapTo;
					Object( effect ).bitmapFrom = _bitmapFrom;
					
					_effectInstance = StackEffectInstance( effect.play( [ target ] )[ 0 ] );
					_effectInstance.addEventListener( EffectEvent.EFFECT_END, onEffectEnd, false, 0, true );
				}
				
				_stackIndex = selectedIndex;
			}
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListVirtual():void
		{
			super.updateDisplayListVirtual();
			
			if( target.numElements == 0 ) return;
			
			// Hide the last selectedElement.
			if( _selectedElement && _selectedElement != selectedElement ) _selectedElement.visible = false;
			// Update the selectedElement.
			_selectedElement = selectedElement;
			if( !_selectedElement ) return;
			
			_elementMaxDimensions.update( _selectedElement );
			
			updateSelectedElementSizeAndPosition( _selectedElement );
			_selectedElement.visible = true;
			
			updateDepths( null );
		}
		
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListReal():void
		{
			super.updateDisplayListReal();
			
			if( target.numElements == 0 ) return;
			
			var i:int;
			var element:IVisualElement;
			for( i = 0; i < numElementsInLayout; i++ )
			{
				element = target.getElementAt( indicesInLayout[ i ] );
				if( element != selectedElement ) 
				{
					element.visible = false;
				}
				
				_elementMaxDimensions.update( element );
			}
			
			_selectedElement = selectedElement;
			
			if( _selectedElement )
			{
				updateSelectedElementSizeAndPosition( _selectedElement );
				_selectedElement.visible = true;
			}
			
			updateDepths( null );
		}
		
		/**
		 *  @private
		 */
		private function updateSelectedElementSizeAndPosition( element:IVisualElement ):void
		{
			var w:Number = calculateElementWidth( element, unscaledWidth, _elementMaxDimensions.width );
			var h:Number = calculateElementHeight( element, unscaledHeight, _elementMaxDimensions.height );
			
			element.setLayoutBoundsSize( w, h );
			element.setLayoutBoundsPosition( calculateElementX( w ), calculateElementY( h ) );
		}
		
		/**
		 *	@private
		 * 
		 *	Sets the depth of elements inlcuded in the layout at depths
		 *	to display correctly for the z position set with transformAround.
		 * 
		 *	Also sets the depth of elements that are not included in the layout.
		 *	The depth of these is dependent on whether their element index is before
		 *	or after the index of the selected element.
		 */
		private function updateDepths( depths:Vector.<int> ):void
		{
//			var element:IVisualElement;
//			var i:int;
//			var numElementsNotInLayout:int = indicesNotInLayout.length;
//			for( i = 0; i < numElementsNotInLayout; i++ )
//			{
//				element = target.getElementAt( indicesNotInLayout[ i ] );
//				element.depth = indicesNotInLayout[ i ];
//			}
//			
//			//FIXME tink, -1 to allow for bug
//			_selectedElement.depth = ( indicesInLayout[ selectedIndex ] == 0 ) ? -1 : indicesInLayout[ selectedIndex ];
		}
		
		
		/**
		 *  @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		override protected function restoreElement( element:IVisualElement ):void
		{
			super.restoreElement( element );
			
			element.visible = true;
		}
		
		/**
		 *  @private
		 *  Used only for virtual layout.
		 */
		private function calculateElementWidth( element:ILayoutElement, targetWidth:Number, containerWidth:Number ):Number
		{
			switch( horizontalAlign )
			{
				case HorizontalAlign.JUSTIFY :
				{
					return targetWidth;
				}
				case HorizontalAlign.CONTENT_JUSTIFY : 
				{
					return Math.max( element.getPreferredBoundsWidth(), targetWidth );
				}
			}
			
			// If percentWidth is specified then the element's width is the percentage
			// of targetWidth clipped to min/maxWidth and to (upper limit) targetWidth.
			var percentWidth:Number = element.percentWidth;
			if( !isNaN( percentWidth ) )
			{
				var width:Number = targetWidth * ( percentWidth * 0.01 );
				return Math.min( targetWidth, Math.min( element.getMaxBoundsWidth(), Math.max( element.getMinBoundsWidth(), width ) ) );
			}
			
			return element.getPreferredBoundsWidth();  // not constrained
		}
		
		/**
		 *  @private
		 *  Used only for virtual layout.
		 */
		private function calculateElementHeight( element:ILayoutElement, targetHeight:Number, containerHeight:Number):Number
		{
			switch( verticalAlign )
			{
				case VerticalAlign.JUSTIFY :
				{
					return targetHeight;
				}
				case VerticalAlign.CONTENT_JUSTIFY : 
				{
					return Math.max( element.getPreferredBoundsHeight(), targetHeight );
				}
			}
			
			// If percentWidth is specified then the element's width is the percentage
			// of targetWidth clipped to min/maxWidth and to (upper limit) targetWidth.
			var percentHeight:Number = element.percentHeight;
			if( !isNaN( percentHeight ) )
			{
				var height:Number = targetHeight * ( percentHeight * 0.01 );
				return Math.min( targetHeight, Math.min( element.getMaxBoundsHeight(), Math.max( element.getMinBoundsHeight(), height ) ) );
			}
			
			return element.getPreferredBoundsHeight();  // not constrained
		}
		
		
		/**
		 *  @private
		 */
		private function calculateElementX( w:Number ):Number
		{
			switch( horizontalAlign )
			{
				case HorizontalAlign.RIGHT :
				{
					return unscaledWidth - w;
				}
				case HorizontalAlign.CENTER :
				{
					return ( unscaledWidth - w ) / 2;
				}
				default :
				{
					return 0;
				}
			}
		}
		
		/**
		 *  @private
		 */
		private function calculateElementY( h:Number ):Number
		{
			switch( verticalAlign )
			{
				case VerticalAlign.BOTTOM :
				{
					return unscaledHeight - h;
				}
				case VerticalAlign.MIDDLE :
				{
					return ( unscaledHeight - h ) / 2;
				}
				default :
				{
					return 0;
				}
			}
		}
		
		/**
		 *  @private
		 */
		protected function onEffectEnd( event:EffectEvent ):void
		{
			_effectInstance.removeEventListener( EffectEvent.EFFECT_END, onEffectEnd, false );
			_effectInstance = null;
			
			_bitmapTo.dispose();
			_bitmapFrom.dispose();
		}
		
		/**
		 *  @private
		 */
		override protected function invalidateSelectedIndex(index:int, offset:Number):void
		{
			if( selectedIndex == index ) return;
			
			if( effect )
			{
				var bitmapFrom:BitmapData;
				
				if( isNaN( unscaledWidth ) || isNaN( unscaledHeight ) ||
					unscaledWidth == 0 || unscaledHeight == 0 )
				{
					bitmapFrom = new BitmapData( 100, 100, true, 0x00000000 );
				}
				else
				{
					bitmapFrom = new BitmapData( unscaledWidth, unscaledHeight, true, 0x00000000 );
				}
				
				try
				{
					if( effect.isPlaying )
					{
						bitmapFrom.draw( effect.display );
						effect.stop();
					}
					else
					{
						// Validate the old selectedElement before drowing.
						if( _selectedElement is IInvalidating )
							IInvalidating( _selectedElement ).validateNow();
						bitmapFrom.draw( target );
					}
				}
				catch( e:Error )
				{
					bitmapFrom.fillRect( bitmapFrom.rect, 0xff000000 );
				}
				
				_bitmapFrom = bitmapFrom;
			}
			
			super.invalidateSelectedIndex( index, offset );
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayListBetween():void
		{
			super.updateDisplayListBetween();
			
			if( !target.numElements )
			{
				indicesInView( -1, 0 );
			}
			else
			{
				indicesInView( selectedIndex, 1 );
			}
		}
		
		
	}
}


import mx.core.ILayoutElement;

class ElementMaxDimensions
{
	
	private var _width	: Number;
	private var _height	: Number;
	
	public function ElementMaxDimensions()
	{
		
	}
	
	public function update( element:ILayoutElement ):void
	{
		var w:Number = Math.min( element.getPreferredBoundsWidth(), element.getLayoutBoundsWidth() );
		var h:Number = Math.min( element.getPreferredBoundsHeight(), element.getLayoutBoundsHeight() );
		if( w > _width ) w = _width;
		if( h > _height ) w = _height;
	}
	
	public function get width():Number
	{
		return _width;
	}
	
	public function get height():Number
	{
		return _height;
	}
	
	
}