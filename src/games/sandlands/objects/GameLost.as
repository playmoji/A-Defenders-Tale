package games.sandlands.objects
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import games.sandlands.GameSandstone;
	
	public class GameLost extends MovieClip
	{
		private var _game:GameSandstone;
		private var _mc:MovieClip;
		
		public function GameLost(game:GameSandstone, mc:MovieClip)
		{
			_game = game;
			_mc = mc;
			
			MovieClip(_mc.map_btn).addEventListener(MouseEvent.CLICK, ctaClick);
			MovieClip(_mc.restart_btn).addEventListener(MouseEvent.CLICK, ctaClick);
		}
		
		protected function ctaClick(event:MouseEvent):void
		{
			var tempObj:Object = new Object();
			if (event.currentTarget.name == "map_btn"){
				tempObj.id = "MapView";
			} else {
				tempObj.id = "ApplicationView";
			}
			_game.gameCompleted(tempObj);
		}
		
		public function destroy():void {
			MovieClip(_mc.map_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
			MovieClip(_mc.restart_btn).removeEventListener(MouseEvent.CLICK, ctaClick);
			_game = null;
			_mc = null;
		}
	}
}