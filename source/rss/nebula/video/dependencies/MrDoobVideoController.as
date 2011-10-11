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
 * 										Added jupmTime() method
 *  08.01.26		1.1		Mr.doob		Dispatching VideoController.METADATA when its loaded
 * 										Also videoWidth and videoHeight updates onMetaData :S
 * 										Status variable from private to public :S :S
 *  07.12.13		1.0		Mr.doob		First version
 **/
package rss.nebula.video.dependencies {
	import org.osflash.signals.Signal;

	import flash.display.Sprite;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class MrDoobVideoController extends Sprite {
		public static var PLAYING : Number = 0;
		public static var PAUSED : Number = 1;
		public static var STOPPED : Number = 2;
		//
		public var videoWidth : Number = 0;
		public var videoHeight : Number = 0;
		public var videoFPS : Number;
		public var videoDuration : Number;
		public var loop : Boolean = false;
		public var autoSize : Boolean = false;
		//
		private var video : Video;
		private var connection : NetConnection;
		private var stream : NetStream;
		private var listener : Object;
		//
		public var status : Number;
		//
		// signals
		public var playbackStarted : Signal = new Signal();
		public var progress : Signal = new Signal(Number);
		public var bufferFull : Signal = new Signal();
		public var metaReceived : Signal = new Signal();
		public var playbackCompleted : Signal = new Signal();

		/**
		 * Creates a Video Controller
		 *
		 * @param		width				width of the VideoController
		 * @param		height				height of the VideoController
		 * @param		(last param)		Object containing the specified parameters in any order
		 * @param		.loop				Boolean				If ture the video will loop once finished
		 * @param		.autoSize			Boolean				If true the container will resize to the video size
		 */
		public function MrDoobVideoController(width : Number = 320, height : Number = 240, initObj : Object = null) {
			video = new Video(width, height);

			videoWidth = width;
			videoHeight = height;

			video.smoothing = true;

			// applying all the initObj values to the class
			if (initObj)
				for (var param:String in initObj)
					this[param] = initObj[param];

			addChild(video);

			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.connect(null);

			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			video.attachNetStream(stream);

			listener = new Object();
			listener.onMetaData = onMetaData;
			stream.client = listener;
		}

		// .. CONTROL METHODS .............................................................................
		public function load(file : String = null) : void {
			stream.play(file);
			status = MrDoobVideoController.STOPPED;
		}

		public function play(percent : Number = 0) : void {
			var position : Number = percent * videoDuration;
			stream.seek(position);
			// stream.play(file);
			status = MrDoobVideoController.PLAYING;
		}
		
		public function seek(percent : Number) : void {
			var position : Number = percent * videoDuration;
			stream.seek(position);
		}

		public function resume() : void {
			if (stream.time >= videoDuration) {
				stream.seek(0);
			}
			
			stream.resume();
			status = MrDoobVideoController.PLAYING;
		}

		public function pause() : void {
			stream.pause();
			status = MrDoobVideoController.PAUSED;
		}

		public function close() : void {
			stream.close();
			status = MrDoobVideoController.STOPPED;
		}

		public function jumpTime(amount : Number) : void {
			stream.seek(stream.time + amount);
		}

		public function set volume(volume : Number) : void {
			stream.soundTransform = new SoundTransform(volume);
		}

		public function get volume() : Number {
			return stream.soundTransform.volume;
		}

		public function isPlaying() : Boolean {
			return status == PLAYING;
		}

		// .. GET DATA METHODS .............................................................................
		public function getPercentLoaded() : Number {
			return stream.bytesLoaded / stream.bytesTotal;
		}

		public function getPercentPlayed() : Number {
			return stream.time / videoDuration;
		}

		// .. PROPERTIES ..........................................................................................
		public function get smoothing() : Boolean {
			return video.smoothing;
		}

		public function set smoothing(value : Boolean) : void {
			video.smoothing = value;
		}

		public function setSize(width : Number, height : Number) : void {
			video.width = width;
			video.height = height;
		}

		// .. EVENTS ..............................................................................................
		public function onMetaData(metadata : Object) : void {
			/*
			for (var i:String in metadata)
			trace(i + ": " + metadata[i]);
			 */
			videoDuration = metadata.duration;
			videoFPS = metadata.framerate;

			// Stoping the video once loaded
			if (status == MrDoobVideoController.STOPPED)
				stream.pause()

			if (!autoSize) {
				setSize(videoWidth, videoHeight);
			} else {
				videoWidth = metadata.width;
				videoHeight = metadata.height;
			}

			metaReceived.dispatch();
		}

		public function netStatusHandler(event : NetStatusEvent) : void {
			debug("event.info.code: "+event.info.code);
			switch(event.info.code) {
				case "NetStream.Play.Start":
					playbackStarted.dispatch();
					break;
				case "NetStream.Play.Stop":
					if (loop) {
						stream.seek(0);
					} else {
						status = MrDoobVideoController.STOPPED;
						playbackCompleted.dispatch();
					}
					break;
				case "NetStream.Buffer.Full":
					bufferFull.dispatch();
					break;
			}
		}
	}
}