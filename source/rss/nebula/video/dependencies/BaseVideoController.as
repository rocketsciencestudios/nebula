package rss.nebula.video.dependencies {
	import flash.media.StageVideo;
	import org.osflash.signals.Signal;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public class BaseVideoController extends Sprite {
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
		public var status : Number;
		//
		// signals
		public var playbackStarted : Signal = new Signal();
		public var progress : Signal = new Signal(Number);
		public var bufferFull : Signal = new Signal();
		public var metaReceived : Signal = new Signal();
		public var playbackCompleted : Signal = new Signal();
		public var loaded : Signal = new Signal();
		//
		protected var _videoObject : Video;
		private var _connection : NetConnection;
		private var _stream : NetStream;
		private var _listener : Object;
		//

		/**
		 * Creates a Video Controller
		 *
		 * @param		width				width of the VideoController
		 * @param		height				height of the VideoController
		 * @param		(last param)		Object containing the specified parameters in any order
		 * @param		.loop				Boolean				If ture the video will loop once finished
		 * @param		.autoSize			Boolean				If true the container will resize to the video size
		 */
		public function BaseVideoController(videoObject : *, width : Number, height : Number, initObj : Object = null) {
			_videoObject = videoObject;
			setSize(width, height);

			// applying all the initObj values to the class
			if (initObj)
				for (var param:String in initObj)
					this[param] = initObj[param];

			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_connection.connect(null);

			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_videoObject.attachNetStream(_stream);

			_listener = new Object();
			_listener.onMetaData = onMetaData;
			_stream.client = _listener;
		}

		// .. CONTROL METHODS .............................................................................
		public function load(file : String = null) : void {
			addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			_stream.play(file);
			status = BaseVideoController.STOPPED;
		}

		public function play(percent : Number = 0) : void {
			var position : Number = percent * videoDuration;
			_stream.seek(position);
			// stream.play(file);
			status = BaseVideoController.PLAYING;
		}
		
		public function seek(percent : Number) : void {
			var position : Number = percent * videoDuration;
			_stream.seek(position);
		}

		public function resume() : void {
			if (_stream.time >= videoDuration) {
				_stream.seek(0);
			}
			
			_stream.resume();
			status = BaseVideoController.PLAYING;
		}

		public function pause() : void {
			_stream.pause();
			status = BaseVideoController.PAUSED;
		}

		public function close() : void {
			_stream.close();
			status = BaseVideoController.STOPPED;
		}

		public function jumpTime(amount : Number) : void {
			_stream.seek(_stream.time + amount);
		}

		public function set volume(volume : Number) : void {
			_stream.soundTransform = new SoundTransform(volume);
		}

		public function get volume() : Number {
			return _stream.soundTransform.volume;
		}

		public function isPlaying() : Boolean {
			return status == PLAYING;
		}

		// .. GET DATA METHODS .............................................................................
		public function getPercentLoaded() : Number {
			return _stream.bytesLoaded / _stream.bytesTotal;
		}

		public function getPercentPlayed() : Number {
			return _stream.time / videoDuration;
		}

		// .. PROPERTIES ..........................................................................................
		public function get smoothing() : Boolean {
			return false;
		}

		public function set smoothing(value : Boolean) : void {
		}

		public function setSize(width : Number, height : Number) : void {
			videoWidth = width;
			videoHeight = height;
		}

		// .. EVENTS ..............................................................................................
		protected function onMetaData(metadata : Object) : void {
			/*
			for (var i:String in metadata)
			trace(i + ": " + metadata[i]);
			 */
			debug("metadata: " + metadata.duration);
			videoDuration = metadata.duration;
			videoFPS = metadata.framerate;

			// Stoping the video once loaded
			if (status == BaseVideoController.STOPPED)
				_stream.pause();

			if (!autoSize) {
				setSize(videoWidth, videoHeight);
			} else {
				videoWidth = metadata.width;
				videoHeight = metadata.height;
			}

			metaReceived.dispatch();
		}

		protected function netStatusHandler(event : NetStatusEvent) : void {
//			debug("event.info.code: "+event.info.code);
			switch(event.info.code) {
				case "NetStream.Play.Start":
					playbackStarted.dispatch();
					break;
				case "NetStream.Play.Stop":
					if (loop) {
						_stream.seek(0);
					} else {
						status = BaseVideoController.STOPPED;
						playbackCompleted.dispatch();
					}
					break;
				case "NetStream.Buffer.Full":
					bufferFull.dispatch();
					break;
			}
		}
		
		private function handleEnterFrame(event : Event) : void {
			if (getPercentLoaded() == 1) {
				loaded.dispatch();
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
		}

	}
}
