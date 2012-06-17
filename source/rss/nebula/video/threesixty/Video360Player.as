package rss.nebula.video.threesixty {
	import away3d.cameras.HoverCamera3D;
	import away3d.containers.View3D;
	import away3d.primitives.Sphere;

	import rss.nebula.video.plugins.IVideoControl;
	import rss.nebula.video.plugins.IVideoMuteToggle;
	import rss.nebula.video.plugins.IVideoPanel;
	import rss.nebula.video.plugins.IVideoPlaybackToggle;
	import rss.nebula.video.plugins.IVideoReplayControl;
	import rss.nebula.video.plugins.IVideoScrubSlider;
	import rss.nebula.video.plugins.IVideoVolumeControl;

	import com.epologee.time.TimeDelay;
	import com.epologee.util.drawing.Draw;
	import com.epologee.util.drawing.SpriteDrawings;

	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;

	/**
	 * @author Ralph Kuijpers @ Rocket Science Studios
	 */
	public class Video360Player extends Sprite {
		public var playbackFinished : Signal = new Signal();
		public var playbackStarted : Signal = new Signal();
		public var panelShown : Signal = new Signal();
		public var panelHidden : Signal = new Signal();
		//
		private var _videoController : VideoMaterialController;
		private var _muted : Boolean;
		private var _timeout : TimeDelay;
		private var _controls : Array;
		//
		private var _sourceWidth : Number;
		private var _sourceHeight : Number;
		private var _videoWidth : Number;
		private var _videoHeight : Number;
		private var _sphereSegmentsWidth : Number;
		private var _sphereSegmentsHeight : Number;
		private var _autoHideControls : Boolean;
		
		/**
		 * To use this class, make sure you have away3d-core-fp10 as linked library in your project
		 * https://github.com/away3d/away3d-core-fp10
		 */
		private var _camera : HoverCamera3D;
		private var _view : View3D;
		private var _sphere : Sphere;
		private var _data : Video360VO;
		private var _viewOffsetY : Number;
		

		/**
		 * Construct the video player with a desired width and height, 
		 * next to that also add the source (total 360 video) width and height and how many segments the sphere should contain:
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
		public function Video360Player(data : Video360VO, videoWidth : Number = 960, videoHeight : Number = 400, viewOffsetY : Number = 0, sphereSegmentsWidth : Number = 28, sphereSegmentsHeight : Number = 28, autoHideControls : Boolean = true) {
			_viewOffsetY = viewOffsetY;
			_data = data;
			_sphereSegmentsHeight = sphereSegmentsHeight;
			_sphereSegmentsWidth = sphereSegmentsWidth;
			_videoHeight = videoHeight;
			_videoWidth = videoWidth;
			_autoHideControls = autoHideControls;
			_sourceWidth = Number(_data.sourceWidth);
			_sourceHeight = Number(_data.sourceHeight);

			_controls = [];

			_videoController = new VideoMaterialController(_sourceWidth, _sourceHeight);
			Draw.rectangle(_videoController.sprite, _sourceWidth, _sourceHeight, 0);

			create3DScene();
			_videoController.playbackStarted.add(handlePlaybackStarted);
			_videoController.playbackCompleted.add(updateButtons);
			_videoController.playbackCompleted.add(playbackFinished.dispatch);
			_videoController.bufferFull.add(debug);
			_videoController.metaReceived.add(debug);

			if (_autoHideControls) {
				_view.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToShow);
				_view.addEventListener(MouseEvent.MOUSE_MOVE, triggerControlsToHide);
			}

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
				case IVideoReplayControl:
					IVideoReplayControl(control).replay.add(handleReplay);
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

		public function resetAndPause() : void {
			_videoController.seek(0);
			_videoController.pause();
		}
		
		public function stopAndClear() : void {
			_videoController.seek(0);
			_videoController.pause();
			_videoController.close();
		}

		public function pause() : void {
			_videoController.pause();
		}

		public function resume() : void {
			_videoController.resume();
			updateButtons();
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

		public function update3DView() : void {
			_camera.hover();
			try{
				_view.render();		
			}catch(e:Error){
				error(e.message);
			}
			
		}
		
		// SHOULD BE SET IN VIDEO STARTED
		public function setupCamera(fov : Number = 54, zoom : Number = 3, panAngle : Number = 0, tiltAngle : Number = 0) : void {
			_camera.fov = fov;
			_camera.panAngle = panAngle;
            _camera.tiltAngle = tiltAngle;
            _camera.zoom = zoom;
            _camera.hover(true);
		}

		private function create3DScene() : void {
            var material : VideoMaterialController = _videoController;
            material.smooth = true;

            _camera = new HoverCamera3D();
            _camera.z = -_sourceWidth/2;

            _view = new View3D({camera:_camera, x:_videoWidth / 2, y:_videoHeight / 2 + _viewOffsetY});
            addChild(_view);
            
            _view.mask = addChild(SpriteDrawings.rectangle(_videoWidth, _videoHeight));

            _sphere = new Sphere({radius:_sourceWidth*2, material:material, segmentsW:_sphereSegmentsWidth, segmentsH:_sphereSegmentsHeight});
            _sphere.scaleX = -1;
            _view.scene.addChild(_sphere);
        }

        private function handlePlaybackStarted() : void {
            updateButtons();
            playbackStarted.dispatch();
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
			} else if (_videoController.status >= VideoMaterialController.STOPPED) {
				// replay
				_videoController.play(0);
				playbackStarted.dispatch();
			} else {
				_videoController.resume();
			}

			updateButtons();
		}
		
		
		private function handleReplay() : void {
			_videoController.play(0);
			resume();
			playbackStarted.dispatch();
		}

		private function handleScrubbed(percent : Number) : void {
			if (_videoController.status >= VideoMaterialController.STOPPED) {
				_videoController.status = VideoMaterialController.PLAYING;
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
			update3DView();
			
			var slider : IVideoScrubSlider = IVideoScrubSlider(controlsWithInterface(IVideoScrubSlider, 1)[0]);
			if (!slider) return;
			slider.buffer = _videoController.getPercentLoaded();
			slider.position = _videoController.getPercentPlayed();
			
		}

		private function interfaceOfControl(control : IVideoControl) : Class {
			if (control is IVideoMuteToggle) return IVideoMuteToggle;
			if (control is IVideoPlaybackToggle) return IVideoPlaybackToggle;
			if (control is IVideoReplayControl) return IVideoReplayControl;
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
			_videoController.volume = volume;
		}

		public function videoDuration() : Number {
			return _videoController.videoDuration;
		}

		public function percentPlayed() : Number {
			return _videoController.getPercentPlayed();
		}

		public function get timePlayed() : Number {
			return videoDuration() * percentPlayed();
		}

		public function get camera() : HoverCamera3D {
			return _camera;
		}
		
		public function get isPlaying() : Boolean {
			return _videoController.isPlaying();
		}
	}
}
