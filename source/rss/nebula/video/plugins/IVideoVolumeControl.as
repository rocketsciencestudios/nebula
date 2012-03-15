package rss.nebula.video.plugins {
	import org.osflash.signals.Signal;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public interface IVideoVolumeControl extends IVideoControl {
		function get volumeChanged() : Signal;
	}
}
