package rss.nebula.video.plugins {
	import com.epologee.ui.buttons.IHasSelectedState;

	import org.osflash.signals.Signal;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public interface IVideoPlaybackToggle extends IVideoControl, IHasSelectedState {
		function get playbackToggled() : Signal;
	}
}
