package rss.nebula.socialmedia.sharing.vo {
	import rss.nebula.socialmedia.sharing.SocialEnvironmentNames;
	/**
	 * @author Michiel van der Plas @ Rocket Science Studios
	 */
	public class TwitterShareVO extends AbstractSocialShareVO implements ISocialShare {
		private var _hashtags : Array;
		
		public function get hashtags() : Array {
			return _hashtags;
		}

		public function setHashtags(...hashtags : Array) : void {
			_hashtags = hashtags;
		}
		
		public function urlVariables () : Object{
			var obj : Object = new Object();
			
			var hashString : String = '';
			for each (var item : String in _hashtags) {
				hashString += ' ' + item;
			}
			
			obj.text = '';
			if(shareText) obj.text = (shareText + ' ');
			if(url) obj.text += url;
			if(_hashtags) obj.text += hashString;
			
			return obj;
		}

		public function get platform() : String {
			return SocialEnvironmentNames.TWITTER_SHARE;
		}
	}
}
