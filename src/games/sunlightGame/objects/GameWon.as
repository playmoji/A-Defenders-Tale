package games.sunlightGame.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.sunlightGame.core.Game;
	
	public class GameWon extends MovieClip
	{
		private var _game:Game;
		private var _mc:MovieClip;
		
		public function GameWon(game:Game, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			trace("GameWon");
			
			MovieClip(_mc.cta_btn).addEventListener(MouseEvent.CLICK, ctaClick);
//			MovieClip(_mc.cta_btn).alpha = .5;
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			_game.gameCompleted();
		}
		
		public function destroy():void {
			MovieClip(_mc.cta_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
		}
	}
}