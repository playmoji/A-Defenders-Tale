package view.prologue
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.StringUtil;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class NegotiateView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _almsGiven:int = 0;;
		private var _frame:FrameView;
		private var _singleStart:Array;
		private var _doubleStart:Array;
		private var _scrolling:Boolean;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _notesPlayed:Object;
		private var _bgSound:Track;
		private var _instrumentInt:int;
		private var _coinDone:Boolean;
		
		public function NegotiateView()
		{
			_SAL = new SWFAssetLoader("prologue.NegotiateMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn); 
		}
		
		public function destroy() : void {
//			
			_mc.instrument_mc.removeEventListener(MouseEvent.CLICK, clickToShine);
			_notesPlayed = null;
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
			
			if (DataModel.coinCount < 1) {
				_almsGiven = 1;
			}
			
			_instrumentInt = DataModel.defenderInfo.instrument;
			
			_mc.instrument_mc.gotoAndStop(_instrumentInt+1);
			_mc.instrument_mc.glows_mc.gotoAndStop(_instrumentInt+1);
			_mc.instrument_mc.glows_mc.visible = false;
			_mc.instrument_mc.shine_mc.visible = false;
			
			_nextY = 110;
			
			_pageInfo = DataModel.appData.getPageInfo("negotiate");
			_bodyParts = _pageInfo.body;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.instrument_mc.noteSingle_mc);
			DataModel.getInstance().setGraphicResolution(_mc.instrument_mc.noteDouble_mc);
			DataModel.getInstance().setGraphicResolution(_mc.instrument_mc.instrument_mc);
			DataModel.getInstance().setGraphicResolution(_mc.instrument_mc.glows_mc.instrument_mc);
			DataModel.getInstance().setGraphicResolution(_mc.coin_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[coins]", _pageInfo.coins[_almsGiven]);
					copy = StringUtil.replace(copy, "[instrument1]", _pageInfo.instrument1[_instrumentInt]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					
					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_tf.mouseEnabled = false;
					
					_mc.addChild(_tf);
					_nextY += Math.round(_tf.height + part.top);
					
				} else if (part.type == "image") {
					
					if (part.id == "coinImage") {
						_mc.coin_mc.y = Math.round(_nextY+part.top)+15;
					}
					
					if (part.id == "instrumentImage") {
						_mc.instrument_mc.y = Math.round(_nextY+part.top)-130;
					}
					
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier, onComplete:onImageLoad});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
					
				}
			}
			
			function onImageLoad(event:LoaderEvent):void { 
				event.target.content.mouseEnabled = false;
			}
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			_decisions = new DecisionsView(_pageInfo.decisions);
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc);
			var frameSize:int = _decisions.y + 210;
//			EXCEPTION FOR SCREENSHOT - PREVENTS WHITE FROM SHOWING UP
// 			size black BG
			_mc.bg_mc.height = frameSize;
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
			
			_mc.instrument_mc.noteSingle_mc.alpha = 0;
			_singleStart = [_mc.instrument_mc.noteSingle_mc.x, _mc.instrument_mc.noteSingle_mc.y];
			_mc.instrument_mc.noteDouble_mc.alpha = 0;
			_doubleStart = [_mc.instrument_mc.noteDouble_mc.x, _mc.instrument_mc.noteDouble_mc.y];
			
			_mc.instrument_mc.glows_mc.cacheAsBitmap = true;
			_mc.instrument_mc.shine_mc.cacheAsBitmap = true;
			_mc.instrument_mc.glows_mc.mask = _mc.instrument_mc.shine_mc;
			_mc.instrument_mc.glows_mc.visible = true;
			_mc.instrument_mc.shine_mc.visible = true;
			
			// load sound
			_bgSound = new Track("assets/audio/prologue/prologue_docks.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
		}
		
		private function pageOn(e:ViewEvent):void {
			
			TweenMax.delayedCall(3, stopCoin);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			_mc.instrument_mc.addEventListener(MouseEvent.CLICK, clickToShine);
		}
		
		private function clickToShine(e:MouseEvent):void {
			showNotes();
		}
		
		private function stopCoin():void {
			_mc.coin_mc.coin_mc.gotoAndStop(5);
			_coinDone = true;
		}
		
		protected function showNotes():void
		{
			TweenMax.to(_mc.instrument_mc.shine_mc, 1.4, {y:520, ease:Quad.easeIn, onComplete:function():void {_mc.instrument_mc.shine_mc.y = -400}}); 
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, .4, {alpha:1});
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, 2, {bezierThrough:[{x:-12, y:70}, {x:20, y:-10}, {x:-2, y:-40}],
				onComplete:function():void {
					_mc.instrument_mc.noteSingle_mc.x = _singleStart[0];
					_mc.instrument_mc.noteSingle_mc.y = _singleStart[1];
				}}); 
			TweenMax.to(_mc.instrument_mc.noteSingle_mc, .4, {alpha:0, delay:1});
			
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, .4, {alpha:1, delay:.4});
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, 2, {bezierThrough:[{x:50, y:72}, {x:100, y:32}, {x:40, y:-30}], delay:.4,
				onComplete:function():void {
					_mc.instrument_mc.noteDouble_mc.x = _doubleStart[0];
					_mc.instrument_mc.noteDouble_mc.y = _doubleStart[1];
				}}); 
			TweenMax.to(_mc.instrument_mc.noteDouble_mc, .4, {alpha:0, delay:1.8});
			
			DataModel.getInstance().instrumentSound();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if (_dragVCont.scrollY > 2200 && !_notesPlayed) {
				showNotes();
				_notesPlayed = true;
			}
			
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
				_mc.coin_mc.coin_mc.stop();
			} else {
				if (!_scrolling) return;
				if (!_coinDone) {
					_mc.coin_mc.coin_mc.play();
				}
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_dragVCont.stopTween();
			if (hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameLoop);
			}
			TweenMax.killAll();
			_mc.stopAllMovieClips();
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.SHOW_PAGE, event.data));
		}
		
	}
}