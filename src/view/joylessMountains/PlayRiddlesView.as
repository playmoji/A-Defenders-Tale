package view.joylessMountains
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import assets.fonts.Caslon224;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class PlayRiddlesView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _couldText:TextField;
		private var _couldntText:TextField;
		private var _submitBtn:MovieClip;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _start:MovieClip;
		private var _retry:MovieClip;
		private var _gameLost:MovieClip;
		private var _gameWon:MovieClip;
		private var _hints:MovieClip;
		private var _hintBtn:MovieClip;
		private var _hintCount:int = 1;
		private var _retryCount:int = 0;
		private var _bgSound:Track;
		private var _gameSound:Track;
		
		public function PlayRiddlesView()
		{
			_SAL = new SWFAssetLoader("joyless.PlayRiddlesMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_hintBtn.removeEventListener(MouseEvent.CLICK, hintClick);
			_retry.cta_btn.removeEventListener(MouseEvent.CLICK, retryClick);
			_gameLost.history_btn.removeEventListener(MouseEvent.CLICK, lostClick);
			_gameLost.back_btn.removeEventListener(MouseEvent.CLICK, lostClick);
			_gameWon.cta_btn.removeEventListener(MouseEvent.CLICK, wonClick);
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
			
			_couldText.removeEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_couldText.removeEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			_couldntText.removeEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_couldntText.removeEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			
			_couldntText = null;
			_couldText = null;
			_submitBtn = null;
			_start = null;
			_retry = null;
			_gameLost = null;
			_gameWon = null;
			_hints = null;
			_hintBtn = null;
//			
			_pageInfo = null;
			
			_frame.destroy();
			_frame = null;
			
			_decisions.destroy();
			_mc.removeChild(_decisions);
			_decisions = null;
			
			EventController.getInstance().removeEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			EventController.getInstance().removeEventListener(ViewEvent.PAGE_ON, pageOn); 
			
			//!IMPORTANT
			DataModel.getInstance().removeAllChildren(_mc);
			_dragVCont.removeChild(_mc);
			_SAL.destroy();
			_SAL = null;
			_mc = null;
			
			_dragVCont.dispose();
			removeChild(_dragVCont);
			_dragVCont = null; 
			
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
		}
		
		protected function mcAdded(event:Event):void
		{
			_mc.removeEventListener(Event.ADDED_TO_STAGE, mcAdded);
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.MC_READY));
		}
		
		private function init(e:ViewEvent) : void {
			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, init);
			_mc = _SAL.assetMC;
			
			_mc.addEventListener(Event.ADDED_TO_STAGE, mcAdded);
			
			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
			
			_nextY = 110;
			
			var tf:TextFormat = new TextFormat();
			tf.size = 38;
			tf.color = 0x000000;
			tf.align = "left";
			tf.font = new Caslon224().fontName;
			
//			_couldText = _mc.could_txt;
			_couldText = new TextField();
			_couldText.type = TextFieldType.INPUT;
			_couldText.antiAliasType = AntiAliasType.ADVANCED;
			_couldText.embedFonts = true;
			_couldText.width = 225;
			_couldText.x = 291;
			_couldText.y = 171;
			_couldText.defaultTextFormat = tf;
			_mc.addChild(_couldText);
			
//			_couldntText = _mc.couldnt_txt;
			_couldntText = new TextField();
			_couldntText.type = TextFieldType.INPUT;
			_couldntText.antiAliasType = AntiAliasType.ADVANCED;
			_couldntText.embedFonts = true;
			_couldntText.width = 225;
			_couldntText.x = 444;
			_couldntText.y = 259;
			_couldntText.defaultTextFormat = tf;
			_mc.addChild(_couldntText);
			
			_couldText.addEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_couldText.addEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			_couldntText.addEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_couldntText.addEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			
			_submitBtn = _mc.submit_btn;
			
			_start = _mc.startGame_mc;
			_start.cta_btn.addEventListener(MouseEvent.CLICK, startClick);
			
			_retry = _mc.tryAgain_mc;
			_retry.stop();
			_retry.retry_mc.stop();
			_retry.visible = false;
			_retry.cta_btn.addEventListener(MouseEvent.CLICK, retryClick);
			
			_gameLost = _mc.gameLost_mc;
			_gameLost.visible = false;
			_gameLost.history_btn.addEventListener(MouseEvent.CLICK, lostClick);
			_gameLost.back_btn.addEventListener(MouseEvent.CLICK, lostClick);
			
			_gameWon = _mc.gameWon_mc;
			_gameWon.visible = false;
			_gameWon.cta_btn.addEventListener(MouseEvent.CLICK, wonClick);
			
			_hintBtn = _mc.hint_btn;
			_hintBtn.addEventListener(MouseEvent.CLICK, hintClick); 
			
			_hints = _mc.hints_mc;
			_hints.stop();
			
			_pageInfo = DataModel.appData.getPageInfo("playRiddles");
			_bodyParts = _pageInfo.body;
			
//			_pageInfo.contentPanelInfo.body = "The Play Riddles Game copy TBD";
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_start);
			DataModel.getInstance().setGraphicResolution(_gameLost);
			DataModel.getInstance().setGraphicResolution(_gameWon);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;

					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
//					if (!_tf) {
//						_pageInfo.contentPanelInfo.body = copy;
//						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
//					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			//EXCEPTION
			_decisions.visible = false;
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _mc.bg_mc.height;
			_frame.sizeFrame(frameSize);
			if (frameSize < DataModel.APP_HEIGHT) {
				_decisions.y += Math.round(DataModel.APP_HEIGHT - frameSize);
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_bgSound = new Track("assets/audio/joyless/joyless_05.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;

			_gameSound = new Track("assets/audio/joyless/joyless_game.mp3");
			_gameSound.loop = true;
			_gameSound.fadeAtEnd = true;
			_gameSound.volume = .8;
		}
		
		protected function hintClick(event:MouseEvent):void
		{
			_hintCount++;
			if (_hintCount > _hints.totalFrames-1) {
				_hintBtn.visible = false;
//				return;
			}
			TweenMax.to(_hints, .5, {alpha:0, onComplete:
				function():void{
					_hints.gotoAndStop(_hintCount);
					TweenMax.to(_hints, .5, {alpha:1});
				}
			});
		}
		
		private function pageOn(e:ViewEvent):void {
			_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_bgSound.volumeTo(1000, .5);
			_gameSound.start(true);
		}
		
		private function textFocusIn(event:FocusEvent) : void {
			//cuz of AIR bug with input text shifting down on input
			var thisTF:TextField = event.target as TextField;
			thisTF.y -= 30;
		}
		
		private function textFocusOut(event:FocusEvent) : void {
			//cuz of AIR bug with input text
			var thisTF:TextField = event.target as TextField;
			thisTF.y += 30;
		}
		
		private function startClick(e:MouseEvent):void {
			_start.cta_btn.removeEventListener(MouseEvent.CLICK, startClick);
			_start.visible = false;
		}
		private function retryClick(e:MouseEvent):void {
			_couldText.text = "";
			_couldntText.text = "";
			_retryCount++;
			_retry.visible = false;
		}
		
		protected function submitClick(event:MouseEvent):void
		{
			checkText();			
		}
		
		private function checkText():void {
			var i:int;
			var couldGood:Boolean = false;
			var couldntGood:Boolean = false;
			
			for (i = 1;  i< _couldText.length; i++) 
			{
				if (_couldText.text.charAt(i) == _couldText.text.charAt(i-1)) {
					couldGood = true;
					break;
				}
			}
			
			if (_couldntText.text.length == 1) couldntGood = true;
			for (i = 1;  i< _couldntText.length; i++) 
			{
				if (_couldntText.text.charAt(i) == _couldntText.text.charAt(i-1)) {
					couldntGood = false;
					break;
				} else {
					couldntGood = true;
				}
			}
			
			if (couldGood && couldntGood) {
				_gameWon.visible = true;
			} else if (_retryCount < 3) {
				_retry.gotoAndStop(_retryCount+1);
				DataModel.getInstance().setGraphicResolution(_retry.retry_mc);
				_retry.visible = true;
			} else {
				_gameLost.visible = true;
			}
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				
			} else {
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		private function wonClick(e:MouseEvent):void {
			var tempObj:Object = new Object();
			tempObj.id = "joylessMountains.StoneView";
			decisionClicked(tempObj);
		}
		
		private function lostClick(e:MouseEvent):void {
			var tempObj:Object = new Object();
			if (e.target.name == "history_btn") {
//				tempObj.id = "MapView";
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.OPEN_GLOBAL_NAV, tempObj));
			} else {
//				tempObj.id = "ApplicationView";
				tempObj.id = "BackOneStep";
				tempObj.backOneStep = true;
				decisionClicked(tempObj);
			}
			
		}
		
		private function decisionClicked(thisPageObj:Object):void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.DECISION_CLICK, thisPageObj));
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_dragVCont.stopTween();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			//for delayed calls
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
	}
}