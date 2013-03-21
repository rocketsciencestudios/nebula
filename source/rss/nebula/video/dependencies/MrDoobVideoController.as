/**
 * Hi-ReS! VideoController v1.3
 * Copyright (c) 2008 Mr.doob @ hi-res.net
 * 
 * Released under MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 * 
 * How to use:
 * 
 * 	var vc:VideoController = new VideoController( 320, 240, { smoothing:true, loop:true, autoSize:true } );
 * 	vc.load( "video.flv" );
 * 	vc.play();		
 * 
 * version log:
 * 
 *
 *  08.03.17		1.3		Mr.doob		VideoController.BUFFER_FULL
 *  08.01.27		1.2		Mr.doob		Added getPercentLoaded() method
 * 										Added getPercentPlayed() method
 * 										Added jumpTime() method
 *  08.01.26		1.1		Mr.doob		Dispatching VideoController.METADATA when its loaded
 * 										Also videoWidth and videoHeight updates onMetaData :S
 * 										Status variable from private to public :S :S
 *  07.12.13		1.0		Mr.doob		First version
 **/
package rss.nebula.video.dependencies {
	import flash.media.Video;

	public class MrDoobVideoController extends BaseVideoController {
		public function MrDoobVideoController(width : Number = 320, height : Number = 240) {
			super(width, height, new Video(width, height));

			addChild(video);
			video.smoothing = true;
		}

		override public function get video() : * {
			return _videoObject as Video;
		}

		// .. PROPERTIES ..........................................................................................
		override public function get smoothing() : Boolean {
			return video.smoothing;
		}

		override public function set smoothing(value : Boolean) : void {
			video.smoothing = value;
		}
	}
}