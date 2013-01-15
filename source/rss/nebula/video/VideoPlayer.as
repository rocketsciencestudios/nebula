package rss.nebula.video {
	import rss.nebula.video.dependencies.MrDoobVideoController;
	import rss.nebula.video.plugins.IVideoControl;
	import rss.nebula.video.plugins.IVideoMuteToggle;
	import rss.nebula.video.plugins.IVideoPanel;
	import rss.nebula.video.plugins.IVideoPlaybackToggle;
	import rss.nebula.video.plugins.IVideoScrubSlider;
	import rss.nebula.video.plugins.IVideoVolumeControl;

	import com.epologee.time.TimeDelay;
	import com.epologee.util.drawing.Draw;

	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public class VideoPlayer extends Sprite {
		public var videoPlayed : Signal = new Signal();
		public var videoPaused : Signal = new Signal();
		public var videoLoaded : Signal = new Signal();
		public var videoMetaReceived : Signal = new Signal();
		public var playbackFinished : Signal = new Signal();
		public var playbackStarted : Signal = new Signal();
		public var panelShown : Signal = new Signal();
		public var panelHidden : Signal = new Signal();
		//
		private var _video : MrDoobVideoController;
		private var _muted : Boolean;
		private var _timeout : TimeDelay;
		private var _controls : Array;
		//
		private var _width : Number;	
		private var _height : Number;
		private var _autoHideControls : Boolean;

		/**
		 * Construct the video player with a desired width and height:
		 * 
		 * 	_player = new VideoPlayer();
		 * 
		 * And make a collection of controls that look the way your project demands:
		 * 
		 * 	_controlBar = new VideoControlBar(_player.width - 10);
		 * 
		 * Every control implements interfaces from the video.plugin package.
		 * You can then add them to the video player while adhering your project's looks.
		 * 
		 * 	_player.plugInControl(_controlBar);					// Implements IVideoPanel, will hide after inactivity.
		 * 	_player.plugInControl(_controlBar.playbackToggle);	// Implements IVideoPlaybackToggle, pause and play at will.
		 * 	_player.plugInControl(_controlBar.playbackSlider);	// Implements IVideoScrubSlider, buffer, scrub and play head display.
		 * 	_player.plugInControl(_controlBar.muteToggle);		// Implements IVideoMuteToggle, mutes and unmutes the video's sound.
		 */
		public function VideoPlayer(width : Number = 960, height : Number = 400, autoHideControls : Boolean = true) {
			_autoHideControls = autoHideControls;
			_height = height;
			_width = width;

			_controls = [];

			_video = new MrDoobVideoController(width, height);
			Draw.rectangle(_video, width, height, 0);

			_video.playbackStarted.add(handlePlaybackStarted);
			_video.playbackCompleted.add(updateButtons);
			_video.playbackCompleted.add(playbackFinished.dispatch);
			_video.loaded.add(videoLoaded.dispatch);
			_video.bufferFull.add(debug);
			_video.metaReceived.add(videoMetaReceived.dispatch);
			if (_autoHideControls) {
				_video.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToShow);
				_video.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToHide);
			}

			addChild(_video);

			_timeout = new TimeDelay(hideControls, 2500, null, false, false);
		}

		public function plugInControl(control : IVideoControl) : void {
			_controls.push(control);
			var addTriggers : Boolean = false;

			switch(interfaceOfControl(control)) {
				case IVideoScrubSlider:
					IVideoScrubSlider(control).scrubbed.add(handleScrubbed);
					addTriggers = true;
					break;
				case IVideoPlaybackToggle:
					IVideoPlaybackToggle(control).playbackToggled.add(togglePlayback);
					addTriggers = true;
					break;
				case IVideoMuteToggle:
					IVideoMuteToggle(control).muteToggled.add(toggleMute);
					addTriggers = true;
					break;
				case IVideoVolumeControl:
					IVideoVolumeControl(control).volumeChanged.add(handleVolumeChanged);
					addTriggers = true;
					break;
			}

			if (addTriggers && _autoHideControls) {
				control.addEventListener(MouseEvent.ROLL_OVER, triggerControlsToShow);
				control.addEventListener(MouseEvent.ROLL_OUT, triggerControlsToHide);
				control.addEventListener(FocusEvent.FOCUS_IN, triggerControlsToShow);
				control.addEventListener(FocusEvent.FOCUS_OUT, triggerControlsToHide);
			}
		}
		
		public function set loop(value : Boolean) : void {
			_video.loop = value;
		}

		public function get inactivityTimeout() : int {
			return _timeout.delay;
		}

		public function set inactivityTimeout(inactivityTimeout : int) : void {
			_timeout.delay = inactivityTimeout;
		}

//		override public function get width() : Number {
//			return _width;
//		}
//
//		override public function get height() : Number {
//			return _height;
//		}

		public function loadAndPlay(url : String) : void {
			_video.load(url);
			_video.play();
		}
		
		public function load(url : String) : void {
			_video.load(url);
		}

		public function stopAndClear() : void {
			_video.seek(0);
			_video.pause();
			_video.close();
		}
		
		public function resetAndPause() : void {
			_video.seek(0);
			_video.pause();
			videoPaused.dispatch();
		}
		
		public function pause() : void {
			_video.pause();
			videoPaused.dispatch();
			updateButtons();
		}
		
		public function resume() : void {
			_video.resume();
			videoPlayed.dispatch();
			updateButtons();
		}
		
		public function seek(value : Number) : void {
			_video.seek(value);
		}

		private function handlePlaybackStarted() : void {
			updateButtons();
			playbackStarted.dispatch();
		}

		public function showControls() : void {
			_timeout.reset();

			var panels : Array = controlsWithInterface(IVideoPanel);
			for each (var panel : IVideoPanel in panels) {
				panel.show();
			}
			panelShown.dispatch();
		}

		public function hideControlsDelayed() : void {
			_timeout.resetAndStart();
		}

		private function hideControls() : void {
			_timeout.reset();

			var panels : Array = controlsWithInterface(IVideoPanel);
			for each (var panel : IVideoPanel in panels) {
				panel.hide();
			}
			panelHidden.dispatch();
		}

		private function triggerControlsToShow(e : Event) : void {
			var p : DisplayObject = e.target as DisplayObject;
			var s : String = "+ ";
			while (p) {
				s += p + ".";
				p = p.parent;
			}
			showControls();
		}

		private function triggerControlsToHide(e : Event) : void {
			var p : DisplayObject = e.target as DisplayObject;
			var s : String = "- ";
			while (p) {
				s += p + ".";
				p = p.parent;
			}
			hideControlsDelayed();
		}

		public function get isPlaying() : Boolean {
			return _video.isPlaying();
		}

		private function toggleMute() : void {
			_muted = !_muted;
			_video.volume = _muted ? 0 : 1;

			updateButtons();
		}
		
		private function handleVolumeChanged(value : Number) : void {
			_video.volume = value;
			
			updateButtons();
		}

		private function togglePlayback() : void {
			if (_video.isPlaying()) {
				_video.pause();
				videoPaused.dispatch();
			} else if (_video.status >= MrDoobVideoController.STOPPED) {
				// replay
				_video.play(0);
				videoPlayed.dispatch();
			} else {
				_video.resume();
				videoPlayed.dispatch();
			}

			updateButtons();
		}

		private function handleScrubbed(percent : Number) : void {
			if(_video.status >= MrDoobVideoController.STOPPED) {
				_video.status = MrDoobVideoController.PLAYING;
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			_video.seek(percent);
			updateButtons();
		}

		private function updateButtons() : void {
			var muteToggles : Array = controlsWithInterface(IVideoMuteToggle);
			for each (var muteToggle : IVideoMuteToggle in muteToggles) {
				if (_muted) {
					muteToggle.select();
				} else {
					muteToggle.deselect();
				}
			}

			if (_video.isPlaying()) {
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			} else {
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}

			var playbackToggles : Array = controlsWithInterface(IVideoPlaybackToggle);
			for each (var playbackToggle : IVideoPlaybackToggle in playbackToggles) {
				if (_video.isPlaying()) {
					playbackToggle.select();
				} else {
					playbackToggle.deselect();
				}
			}
		}

		private function handleEnterFrame(event : Event) : void {
			var slider : IVideoScrubSlider = IVideoScrubSlider(controlsWithInterface(IVideoScrubSlider, 1)[0]);
			if(!slider) return;
			slider.buffer = _video.getPercentLoaded();
			slider.position = _video.getPercentPlayed();
		}

		private function interfaceOfControl(control : IVideoControl) : Class {
			if (control is IVideoMuteToggle) return IVideoMuteToggle;
			if (control is IVideoPlaybackToggle) return IVideoPlaybackToggle;
			if (control is IVideoScrubSlider) return IVideoScrubSlider;
			if (control is IVideoVolumeControl) return IVideoVolumeControl;
			return null;
		}

		private function controlsWithInterface(desiredInterface : Class, limit : int = 0) : Array {
			var matching : Array = [];

			for each (var control : IVideoControl in _controls) {
				if (control is desiredInterface) {
					matching.push(control);
					if (limit && matching.length == limit) return matching;
				}
			}

			return matching;
		}
		
		public function set volume(volume : Number) : void {
			_video.volume = volume;
		}
		
		public function get volume() : Number {
			return _video.volume;
		}
		
		public function videoDuration() : Number{
			return _video.videoDuration;
		}
		
		public function percentLoaded() : Number{
			return _video.getPercentLoaded();
		}
		
		public function percentPlayed() : Number{
			return _video.getPercentPlayed();
		}
		
		public function get timePlayed() : Number {
			return videoDuration() * percentPlayed();
		}
	}
}
