package rss.nebula.video.dependencies {
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;

	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public class StageVideoController extends BaseVideoController {
		public function StageVideoController(width : Number = 320, height : Number = 240) {
			super(width, height, new StageVideo());
			video.addEventListener(StageVideoEvent.RENDER_STATE, handleRenderState);
		}

		public function get video() : StageVideo {
			return _videoObject as StageVideo;
		}

		private function handleRenderState(event : StageVideoEvent) : void {
			video.viewPort = new Rectangle(x, y, width, height);
		}
	}
}
