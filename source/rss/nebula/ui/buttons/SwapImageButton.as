package rss.nebula.ui.buttons {
	import com.epologee.ui.buttons.DrawnStateButtonBehavior;
	import com.epologee.ui.buttons.IHasDrawnStates;

	import flash.display.Sprite;




	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public class SwapImageButton extends Sprite implements IHasDrawnStates {
		public var dsb : DrawnStateButtonBehavior;
		private var _iconNormal : Sprite;
		private var _iconOver : Sprite;

		public function SwapImageButton(iconNormal : Sprite, iconOver : Sprite) {
			_iconOver = iconOver;
			_iconNormal = iconNormal;
			
			dsb = new DrawnStateButtonBehavior(this);
			
			addChild(_iconNormal);
			addChild(_iconOver);
		}

		public function drawUpState() : void {
			_iconOver.visible = false;
			_iconNormal.visible = true;
		}

		public function drawOverState() : void {
			_iconOver.visible = true;
			_iconNormal.visible = false;
		}
	}
}
