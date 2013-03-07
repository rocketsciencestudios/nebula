package rss.nebula.video.dependencies {
	import flash.display.Stage;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;

	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public class StageVideoController extends BaseVideoController {
		private var _stageVideoScale : Number;
		private var _x : Number = 0;
		private var _y : Number = 0;

		public function StageVideoController(width : Number, height : Number, stage : Stage, stageVideoScale : Number = 1.0, videoIndex : int = 0) {
			_stageVideoScale = stageVideoScale;
			super(width, height, stage.stageVideos[videoIndex]);
			video.addEventListener(StageVideoEvent.RENDER_STATE, handleRenderState);
		}

		public function get video() : StageVideo {
			return _videoObject as StageVideo;
		}

		private function handleRenderState(...ignore) : void {
			video.viewPort = new Rectangle(_x * _stageVideoScale, _y * _stageVideoScale, width * _stageVideoScale, height * _stageVideoScale);
			debug("height * _stageVideoScale: " + (height * _stageVideoScale));
			debug("width * _stageVideoScale: " + (width * _stageVideoScale));
			debug("video.viewPort: " + video.viewPort);
		}

		override public function set x(value : Number) : void {
			_x = value;
			handleRenderState();
		}

		override public function set y(value : Number) : void {
			_y = value;
			handleRenderState();
		}
	}
}
