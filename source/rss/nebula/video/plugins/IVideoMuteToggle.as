package rss.nebula.video.plugins {
	import com.epologee.ui.buttons.IHasSelectedState;

	import org.osflash.signals.Signal;

	/**
	 * @author Eric-Paul Lecluse (c) epologee.com
	 */
	public interface IVideoMuteToggle extends IVideoControl, IHasSelectedState {
		function get muteToggled() : Signal;
	}
}
