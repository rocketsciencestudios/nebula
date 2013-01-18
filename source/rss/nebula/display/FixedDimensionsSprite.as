package rss.nebula.display {
	import flash.display.Sprite;

	/**
	 * @author epologee
	 */
	public class FixedDimensionsSprite extends Sprite {
		private var _width : Number;
		private var _height : Number;

		public function FixedDimensionsSprite(width : Number, height : Number) {
			if (!isNaN(width)) this.width = width;
			if (!isNaN(height)) this.height = height;
		}

		override public function set width(value : Number) : void {
			_width = value;
		}

		override public function get width() : Number {
			return _width;
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(value : Number) : void {
			_height = value;
		}
	}
}
