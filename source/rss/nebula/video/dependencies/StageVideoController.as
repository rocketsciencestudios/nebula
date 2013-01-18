package rss.nebula.video.dependencies {
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;

	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public class StageVideoController extends BaseVideoController {
		public function StageVideoController(width : Number = 320, height : Number = 240) {
			super(new StageVideo(), width, height);
			video.addEventListener(StageVideoEvent.RENDER_STATE, handleRenderState);
		}

		public function get video() : StageVideo {
			return _videoObject as StageVideo;
		}

		override public function setSize(width : Number, height : Number) : void {
			super.setSize(width, height);
		}

		private function handleRenderState(event : StageVideoEvent) : void {
			video.viewPort = new Rectangle(0, 0, videoWidth, videoHeight);
		}
	}
}
