package rss.nebula.video.plugins {
	import org.osflash.signals.Signal;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public interface IVideoScrubSlider extends IVideoControl {
		function get scrubbed() : Signal;

		function set buffer(percentageOfDuration : Number) : void;

		function set position(percentageOfDuration : Number) : void;
	}
}
