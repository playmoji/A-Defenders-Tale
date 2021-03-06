package view.theCattery
{
	import com.greensock.TweenMax;
	import com.greensock.loading.ImageLoader;
	import com.neriksworkshop.lib.ASaudio.Track;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	import model.DecisionInfo;
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
	
	public class FollowView extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _vizier:MovieClip;
		private var _ball:MovieClip;
		private var _mouse:MovieClip;
		private var _scrolling:Boolean;
		private var _force:Number;
		private var _n:Number;
		private var _pageInfo:PageInfo;
		private var _SAL:SWFAssetLoader;
		private var _ballAnimating:Boolean;
		private var _bgSound:Track;
		private var _compTakenIndex:int;
		private var _secondSoundPlayed:Boolean;
		private var _secondSound:Track;
		
		public function FollowView()
		{
			_SAL = new SWFAssetLoader("theCattery.FollowMC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			!!!!			
			_mouse.removeEventListener(MouseEvent.CLICK, swingThis); 
			_mouse = null;
			
			_vizier = null;
			_ball = null;
			
			if (_compTakenIndex == 0) { 
				_mc.companions_mc.removeEventListener(MouseEvent.CLICK, companionClick);
			}
//			
			_pageInfo = null;
			_bodyParts = null;
			
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
			
			// companion take or not
			_compTakenIndex = DataModel.COMPANION_TAKEN ? 0 : 1;
			
			_nextY = 110;
			
			_vizier = _mc.vizier_mc;
			_ball = _vizier.ball_mc;
			_ball.visible = false;
			
			_mouse = _vizier.mouse_mc;
			
			_mc.entree_mc.visible = false;
			_mc.companions_mc.visible = false;
			_mc.companions_mc.gotoAndStop(DataModel.defenderInfo.companion+1);
			
			_pageInfo = DataModel.appData.getPageInfo("follow");
			_bodyParts = _pageInfo.body;
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.entree_mc);
			DataModel.getInstance().setGraphicResolution(_mc.companions_mc.companion_mc);
			DataModel.getInstance().setGraphicResolution(_vizier);
			DataModel.getInstance().setGraphicResolution(_vizier.mouse_mc);
			DataModel.getInstance().setGraphicResolution(_vizier.ball_mc.ball_mc);
			DataModel.getInstance().setGraphicResolution(_vizier.ball_mc.yarn_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
					copy = StringUtil.replace(copy, "[companionComing1]", _pageInfo.companionComing1[_compTakenIndex]);
					copy = StringUtil.replace(copy, "[companion2]", _pageInfo.companion2[DataModel.defenderInfo.companion]);
					copy = StringUtil.replace(copy, "[companion1]", _pageInfo.companion1[DataModel.defenderInfo.companion]);

					// set this last cuz some of these may be in the options above
					copy = DataModel.getInstance().replaceVariableText(copy);
					
					//set the contents panel
					if (!_tf) {
						_pageInfo.contentPanelInfo.body = copy;
						EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.ADD_CONTENTS_PAGE, _pageInfo));
					}
					
					// set the respective text
					_tf = new Text(copy, Formats.storyTextFormat(part.size, part.alignment, part.leading, 0x000000), part.width, true, true, true); 
					_tf.x = part.left; 
					_tf.y = _nextY + part.top;
					_mc.addChild(_tf);
					
					if (part.id == "vizier") {
						_vizier.y = _tf.y - 300;
					}
					
					if (part.id == "last") {
						if (_compTakenIndex == 0) {
							_mc.companions_mc.y = _tf.y + _tf.height + 20;
							_nextY += Math.round(_mc.companions_mc.height);
							_mc.companions_mc.visible = true;
						} else {
							var index0:int = copy.indexOf("main course", 0);
							var rect0:Rectangle = _tf.getCharBoundaries(index0);
							_mc.entree_mc.y = _tf.y + rect0.y + 45;
							_mc.entree_mc.visible = true;
						}
					}
					
					_nextY += Math.round(_tf.height + part.top);
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			//put vizier back on top
			_mc.addChild(_vizier);
			
			// decision
			_nextY += _pageInfo.decisionsMarginTop
			
			var dv:Vector.<DecisionInfo> = new Vector.<DecisionInfo>(); 
			
			if (_compTakenIndex == 0) {
				dv.push(_pageInfo.decisions[0]);
				dv.push(_pageInfo.decisions[1]);
			} else {
				dv.push(_pageInfo.decisions[2]);
				dv.push(_pageInfo.decisions[3]);
			}	
			_decisions = new DecisionsView(dv,0x000000,true);
			
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
			
			_frame = new FrameView(_mc.frame_mc); 
			var frameSize:int = _decisions.y + 210;
			//unique hack due to 2 diff size pages
			if(_compTakenIndex == 0) {
				// size bg
				_mc.bg_mc.height = _decisions.y + 207;
				_frame.sizeFrame(_decisions.y + 207);
			} else {
				// size bg
				_mc.bg_mc.height = frameSize;
				_frame.sizeFrame(frameSize);
			}
			
			_dragVCont = new DraggableVerticalContainer(0,0xFF0000,0,false,0,0,40,40);
			_dragVCont.width = DataModel.APP_WIDTH;
			_dragVCont.height = DataModel.APP_HEIGHT;
			_dragVCont.addChild(_mc);
			_dragVCont.refreshView(true);
			addChild(_dragVCont);
			
			_ball.gotoAndStop(1);
			
			_bgSound = new Track("assets/audio/cattery/cattery_08_waltz.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
			
			_secondSound = new Track("assets/audio/cattery/cattery_purring.mp3");

		}
		
//		protected function clipMC(thisMC:MovieClip, thisHeight:int):void
//		{
//			thisMC.scrollRect = new Rectangle(0, 0, 768, thisHeight);
//			_dragVCont.refreshView(true);
//		}
		
		private function pageOn(e:ViewEvent):void {
			
			_force = 45;
			_n = 0;
			_mouse.addEventListener(MouseEvent.CLICK, swingThis);
			
			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
			
			if (_compTakenIndex == 0) { 
				_mc.companions_mc.addEventListener(MouseEvent.CLICK, companionClick);
			}
		}
		
		private function companionClick(e:MouseEvent):void {
			DataModel.getInstance().companionSound();
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			if(_dragVCont.scrollY > _vizier.y + 110 && !_ball.visible) {
				_ball.play();
				_ball.visible = true;
				_ballAnimating = true;
				
			}
			
			if (_dragVCont.scrollY >= _dragVCont.maxScroll - 500 && !_secondSoundPlayed) {
				_secondSound.start();
				_secondSoundPlayed = true;
			}
			
			if (_ballAnimating) {
				if (_ball.currentFrame == _ball.totalFrames) {
					_ball.stop();
					_ball.shadow_mc.stop();
					_ballAnimating = false;
				}
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				_scrolling = true;
			} else {
				
				swing();
				
				if (!_scrolling) return;
				TweenMax.resumeAll();
				_scrolling = false;
			}
		}
		
		
		
		private function swing():void {
			if (_force <= 0) {
				_force = 0;
				return;
			}
			_n += .2;
			_mouse.rotation += ((Math.cos(_n)*_force) - _mouse.rotation) * .08;
			_force -= .2;
		}
		
		protected function swingThis(event:MouseEvent):void
		{
			_force = 45;
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