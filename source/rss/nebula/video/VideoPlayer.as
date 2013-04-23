package rss.nebula.video {
	import rss.nebula.display.FixedDimensionsSprite;
	import rss.nebula.video.dependencies.BaseVideoController;
	import rss.nebula.video.dependencies.MrDoobVideoController;
	import rss.nebula.video.dependencies.StageVideoController;
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
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.media.StageVideoAvailability;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public class VideoPlayer extends FixedDimensionsSprite {
		public var videoPlayed : Signal = new Signal();
		public var videoPaused : Signal = new Signal();
		public var videoLoaded : Signal = new Signal();
		public var videoMetaReceived : Signal = new Signal();
		public var playbackFinished : Signal = new Signal();
		public var playbackStarted : Signal = new Signal();
		public var panelShown : Signal = new Signal();
		public var panelHidden : Signal = new Signal();
		//
		private var _videoController : BaseVideoController;
		private var _muted : Boolean;
		private var _timeout : TimeDelay;
		private var _controls : Array;
		//
		private var _autoHideControls : Boolean;
		private var _callbackVideoPlayerReady : Function;
		private var _stageVideoScale : Number;
		private var _stageVideoIndex : int;
		private var _disabled : Boolean;

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
		public function VideoPlayer(width : Number = 960, height : Number = 400, autoHideControls : Boolean = true, useStageVideo : Boolean = false, onVideoPlayerReady : Function = null, stageVideoScale : Number = 1.0, stageVideoIndex : int = 0) {
			_stageVideoIndex = stageVideoIndex;
			super(width, height);
			_autoHideControls = autoHideControls;

			_controls = [];
			_callbackVideoPlayerReady = onVideoPlayerReady;
			_stageVideoScale = stageVideoScale;

			if (useStageVideo) {
				addEventListener(Event.ADDED_TO_STAGE, function(event : Event) : void {
					stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, handleStageVideoAvailabilityEvent);
				});
			} else {
				initializeVideo("disabled");
			}

			_timeout = new TimeDelay(hideControls, 2500, null, false, false);
		}

		override public function set x(value : Number) : void {
			super.x = value;
			_videoController.x = value;
		}

		override public function set y(value : Number) : void {
			super.y = value;
			_videoController.y = value;
		}

		override public function set width(value : Number) : void {
			super.width = value;
			if (_videoController) _videoController.width = value;
		}

		override public function set height(value : Number) : void {
			super.height = value;
			if (_videoController) _videoController.height = value;
		}

		private function handleStageVideoAvailabilityEvent(event : StageVideoAvailabilityEvent) : void {
			var stageObject : Stage = event.target as Stage;
			initializeVideo(event.availability, stageObject);
		}

		private function initializeVideo(stageVideoAvailability : String, stageObject : Stage = null) : void {
			var stageVideoUsed : Boolean;
			if (stageVideoAvailability == StageVideoAvailability.AVAILABLE) {
				fatal("use stage video");
				stageVideoUsed = true;
				_videoController = new StageVideoController(width, height, stageObject, _stageVideoScale, _stageVideoIndex);
			} else {
				fatal("NOT using stage video: " + stageVideoAvailability);
				stageVideoUsed = false;
				_videoController = new MrDoobVideoController(width, height);
				Draw.rectangle(_videoController, width, height, 0);
			}

			_videoController.playbackStarted.add(handlePlaybackStarted);
			_videoController.playbackCompleted.add(updateButtons);
			_videoController.playbackCompleted.add(playbackFinished.dispatch);
			_videoController.loaded.add(videoLoaded.dispatch);
//			_videoController.bufferFull.add(debug);
			_videoController.metaReceived.add(videoMetaReceived.dispatch);
			if (_autoHideControls) {
				_videoController.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToShow);
				_videoController.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToHide);
			}

			addChild(_videoController);

			if (_callbackVideoPlayerReady != null) {
				_callbackVideoPlayerReady(stageVideoUsed);
			}
		}

		public function plugInControl(control : IVideoControl) : void {
			_controls.push(control);
			var addTriggers : Boolean = false;

			switch(interfaceOfControl(control)) {
				case IVideoPanel:
					if (_autoHideControls) {
						control.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToShow);
						control.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToHide);
					}
					break;
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
			
			updateButtons();
		}

		public function set loop(value : Boolean) : void {
			_videoController.loop = value;
		}

		public function get inactivityTimeout() : int {
			return _timeout.delay;
		}

		public function set inactivityTimeout(inactivityTimeout : int) : void {
			_timeout.delay = inactivityTimeout;
		}

		public function loadAndPlay(url : String) : void {
			_videoController.load(url);
			_videoController.play();
		}

		public function load(url : String) : void {
			_videoController.load(url);
		}

		public function stopAndClear() : void {
			_videoController.seek(0);
			_videoController.pause();
			_videoController.close();
		}

		public function resetAndPause() : void {
			_videoController.seek(0);
			_videoController.pause();
			videoPaused.dispatch();
		}

		public function pause() : void {
			pauseVideoController();
			// if (_videoController.netstreamStarted) {
			// } else {
			// _videoController.playbackStarted.addOnce(pauseVideoController);
			// }
		}

		private function pauseVideoController() : void {
			_videoController.pause();
			videoPaused.dispatch();
			updateButtons();
		}

		public function resume() : void {
			_videoController.resume();
			videoPlayed.dispatch();
			updateButtons();
		}

		public function seek(value : Number) : void {
			_videoController.seek(value);
			updateButtons();
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
			if (_disabled) return;
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
			return _videoController.isPlaying();
		}

		private function toggleMute() : void {
			_muted = !_muted;
			_videoController.volume = _muted ? 0 : 1;

			updateButtons();
		}

		private function handleVolumeChanged(value : Number) : void {
			_videoController.volume = value;

			updateButtons();
		}

		private function togglePlayback() : void {
			if (_videoController.isPlaying()) {
				_videoController.pause();
				videoPaused.dispatch();
			} else if (_videoController.status >= BaseVideoController.STOPPED) {
				// replay
				_videoController.play(0);
				videoPlayed.dispatch();
			} else {
				_videoController.resume();
				videoPlayed.dispatch();
			}

			updateButtons();
		}

		private function handleScrubbed(percent : Number) : void {
			if (_videoController.status >= BaseVideoController.STOPPED) {
				_videoController.status = BaseVideoController.PLAYING;
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}
			_videoController.seek(percent);
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

			if (_videoController.isPlaying()) {
				
				addEventListener(Event.ENTER_FRAME, handleEnterFrame);
			} else {
				removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			}

			var playbackToggles : Array = controlsWithInterface(IVideoPlaybackToggle);
			for each (var playbackToggle : IVideoPlaybackToggle in playbackToggles) {
				if (_videoController.isPlaying()) {
					playbackToggle.select();
				} else {
					playbackToggle.deselect();
				}
			}
		}

		private function handleEnterFrame(event : Event) : void {
			var slider : IVideoScrubSlider = IVideoScrubSlider(controlsWithInterface(IVideoScrubSlider, 1)[0]);
			if (!slider) return;
			slider.buffer = _videoController.getPercentLoaded();
			slider.position = _videoController.getPercentPlayed();
		}

		private function interfaceOfControl(control : IVideoControl) : Class {
			if (control is IVideoMuteToggle) return IVideoMuteToggle;
			if (control is IVideoPlaybackToggle) return IVideoPlaybackToggle;
			if (control is IVideoScrubSlider) return IVideoScrubSlider;
			if (control is IVideoVolumeControl) return IVideoVolumeControl;
			if (control is IVideoPanel) return IVideoPanel;
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
		
		public function enable() : void {
			_disabled = false;
		}
		
		public function disable() : void {
			_disabled = true;
		}

		public function set volume(volume : Number) : void {
			_videoController.volume = volume;
		}

		public function get volume() : Number {
			return _videoController.volume;
		}

		public function get videoDuration() : Number {
			return _videoController.videoDuration;
		}

		public function percentLoaded() : Number {
			return _videoController.getPercentLoaded();
		}

		public function percentPlayed() : Number {
			return _videoController.getPercentPlayed();
		}

		public function get timePlayed() : Number {
			return videoDuration * percentPlayed();
		}

		public function get videoObject() : DisplayObject {
			return _videoController;
		}
	}
}
