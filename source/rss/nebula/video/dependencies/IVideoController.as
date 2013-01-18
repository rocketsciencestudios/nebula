package rss.nebula.video.dependencies {
	/**
	 * @author Ralph Kuijpers (c) RocketScienceStudios.com
	 */
	public interface IVideoController {
		function load(file : String = null) : void;
		function play(percent : Number = 0) : void;
		function seek(percent : Number) : void;
		function resume() : void;
		function pause() : void;
		function close() : void;
		function set volume(volume : Number) : void;
		function get volume() : Number;
		function isPlaying() : Boolean;
		function getPercentPlayed() : Number;
	}
}
