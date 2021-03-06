package view.shipwreck
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
	import model.DecisionInfo;
	import model.PageInfo;
	import model.StoryPart;
	
	import org.flintparticles.twoD.renderers.DisplayObjectRenderer;
	
	import util.Formats;
	import util.SWFAssetLoader;
	import util.Text;
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	import view.Bubbles;
	import view.DecisionsView;
	import view.FrameView;
	import view.IPageView;
	
	public class Reef2View extends MovieClip implements IPageView
	{
		private var _mc:MovieClip;
		private var _dragVCont:DraggableVerticalContainer;
		private var _bodyParts:Vector.<StoryPart>; 
		private var _nextY:int;
		private var _tf:Text;
		private var _decisions:DecisionsView;
		private var _frame:FrameView;
		private var _scrolling:Boolean;
		private var _bubbles1:Bubbles;
		private var _renderer1:DisplayObjectRenderer;
		private var _bubbles2:Bubbles;
		private var _renderer2:DisplayObjectRenderer;
		private var _bubbles3:Bubbles;
		private var _renderer3:DisplayObjectRenderer;
		private var _bubbles4:Bubbles;
		private var _renderer4:DisplayObjectRenderer;
		private var _pageInfo:PageInfo;
		private var _lobster:MovieClip;
		private var _fish2:MovieClip;
		private var _fish3:MovieClip;
		private var _fish4:MovieClip;
		private var _correctText:TextField;
		private var _incorrectText:TextField;
		private var _dv:Vector.<DecisionInfo>;
		private var _passwordArray:Array = ["barnacle", "conch", "surf", "clam", "shell"];
		private var _SAL:SWFAssetLoader;
		private var _clawAnimating:Boolean;
		private var _bgSound:Track;
		private var _clawDone:Boolean;
		private var _passwordText:TextField;
		
		public function Reef2View()
		{
			_SAL = new SWFAssetLoader("shipwreck.Reef2MC", this);
			EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, init);
			
			EventController.getInstance().addEventListener(ViewEvent.PAGE_ON, pageOn);
		}
		
		public function destroy() : void {
//			
			_bubbles1.stop();
			_bubbles2.stop();
			_bubbles3.stop();
			_bubbles4.stop();
			
			_renderer1.removeEmitter(_bubbles1);
			_renderer2.removeEmitter(_bubbles2);
			_renderer3.removeEmitter(_bubbles3);
			_renderer4.removeEmitter(_bubbles4);
			
			_renderer1 = null;
			_renderer2 = null;
			_renderer3 = null;
			_renderer4 = null;
			
			_bubbles1 = null;
			_bubbles2 = null;
			_bubbles3 = null;
			_bubbles4 = null;
			
			_passwordText.removeEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_passwordText.removeEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			
			_passwordText = null;
			
			_lobster = null;
			_fish2 = null;
			_fish3 = null;
			_fish4 = null;
			
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
			
			_pageInfo = DataModel.appData.getPageInfo("reef2");
			_bodyParts = _pageInfo.body;
			
			_mc.end_mc.visible = false;
			
			//put these first so text can go on top
			_renderer1 = new DisplayObjectRenderer();
			_mc.addChild(_renderer1);
			_renderer2 = new DisplayObjectRenderer();
			_mc.addChild(_renderer2);
			_renderer3 = new DisplayObjectRenderer();
			_mc.addChild(_renderer3);
			_renderer4 = new DisplayObjectRenderer();
			_mc.addChild(_renderer4);
			
			
			DataModel.getInstance().setGraphicResolution(_mc.lobster_mc);
			_lobster = _mc.lobster_mc.lobster_mc;
			_lobster.stop();
			_fish2 = _mc.fish2_mc;
			_fish3 = _mc.fish3_mc;
			_fish4 = _mc.fish4_mc;
			
			//put fish back on top of bubbles
//			_mc.addChild(_mc.lobster_mc);
			_mc.addChild(_fish2);
			_mc.addChild(_fish3);
			_mc.addChild(_fish4);
			
			var tf:TextFormat = new TextFormat();
			tf.size = 60;
			tf.color = 0xFFFFFFF;
			tf.align = "center";
			tf.font = new Caslon224().fontName;
			
			_passwordText = new TextField();
			_passwordText.type = TextFieldType.INPUT;
			_passwordText.antiAliasType = AntiAliasType.ADVANCED;
//			_passwordText.background = true;
			_passwordText.embedFonts = true;
			_passwordText.width = 285;
			_passwordText.x = 80;
			_passwordText.y = 72;
			_passwordText.defaultTextFormat = tf;
			_mc.password_mc.addChild(_passwordText);
			_mc.password_mc.removeChild(_mc.password_mc.password_txt);
			
			_passwordText.addEventListener(FocusEvent.FOCUS_IN, textFocusIn);
			_passwordText.addEventListener(FocusEvent.FOCUS_OUT, textFocusOut);
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc.bg_mc);
			DataModel.getInstance().setGraphicResolution(_mc.end_mc);
			DataModel.getInstance().setGraphicResolution(_mc.password_mc);
			DataModel.getInstance().setGraphicResolution(_mc.reef_mc);
			DataModel.getInstance().setGraphicResolution(_fish2.f1_mc);
			DataModel.getInstance().setGraphicResolution(_fish2.f2_mc);
			DataModel.getInstance().setGraphicResolution(_fish2.f3_mc);
			DataModel.getInstance().setGraphicResolution(_fish3.f1_mc);
			DataModel.getInstance().setGraphicResolution(_fish3.f2_mc);
			DataModel.getInstance().setGraphicResolution(_fish3.f3_mc);
			DataModel.getInstance().setGraphicResolution(_fish4.f1_mc);
			DataModel.getInstance().setGraphicResolution(_fish4.f2_mc);
			DataModel.getInstance().setGraphicResolution(_fish4.f3_mc);
			
			// set the text
			for each (var part:StoryPart in _bodyParts) 
			{
				if (part.type == "text") {
					var copy:String = part.copyText;
					
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
					_mc.addChild(_tf);
					
					_nextY += _tf.height + part.top;
					
					if (part.id == "password") {
						_mc.password_mc.y = _nextY + 40;
					}
					
					if (part.id == "correct") {
						_correctText = _tf;
						_nextY = _correctText.y;
						_correctText.visible = false;
					}
					
					if (part.id == "incorrect") {
						_incorrectText = _tf;
						_incorrectText.visible = false;
						_mc.end_mc.y = _tf.y + _tf.height + 60;
						_nextY += _mc.end_mc.height + 140;
					}
					
					
				} else if (part.type == "image") {
					var loader:ImageLoader = new ImageLoader(part.file, {container:_mc, x:0, y:_nextY+part.top, scaleX:DataModel.scaleMultiplier, scaleY:DataModel.scaleMultiplier});
					//begin loading
					loader.load();
					loader.autoDispose = true;
					_nextY += part.height + part.top;
				}
			}
			
			// decision
//			_nextY += _pageInfo.decisionsMarginTop
//			_decisions = new DecisionsView(_pageInfo.decisions,0xFFFFFF,true); //tint it white, showBG
//			_decisions.y = _nextY; 
//			_decisions.y = _mc.bg_mc.height - 520;
//			_mc.addChild(_decisions);
			
			//EXCEPTION
			var ogReefY:int = _mc.reef_mc.y;
			_mc.reef_mc.y = _mc.password_mc.y + _mc.password_mc.height + 40;
			_mc.bg_mc.height = _mc.reef_mc.y + _mc.reef_mc.height;
			
			var diff:int =  ogReefY - _mc.reef_mc.y; 
			_fish2.y -= diff;
			_mc.bubbles1_mc.y -= diff;
			_mc.bubbles2_mc.y -= diff;
			_mc.bubbles3_mc.y -= diff;
			_mc.bubbles4_mc.y -= diff;
			
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
			
			// bg sound
			_bgSound = new Track("assets/audio/shipwreck/shipwreck_04.mp3");
			_bgSound.start(true);
			_bgSound.loop = true;
			_bgSound.fadeAtEnd = true;
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
		
		private function submitClick(e:MouseEvent):void  {
			_dv = new Vector.<DecisionInfo>();
			_mc.password_mc.submit_btn.removeEventListener(MouseEvent.CLICK, submitClick);
			TweenMax.to(_mc.password_mc, .5, {autoAlpha:0});
			
			var passwordCorrect:Boolean = false;
			for (var i:int = 0; i < _passwordArray.length; i++) 
			{
				if (_passwordText.text == _passwordArray[i]) {
					passwordCorrect = true;
				}
			}
			
			if (passwordCorrect) {
				TweenMax.from(_correctText, .5, {autoAlpha:0});
				_dv.push(_pageInfo.decisions[0]);
				_nextY += 20;
			} else {
				TweenMax.from(_incorrectText, .5, {autoAlpha:0});
				TweenMax.from(_mc.end_mc, .5, {autoAlpha:0});
				_dv.push(_pageInfo.decisions[1]);
				_dv.push(_pageInfo.decisions[2]);
				DataModel.getInstance().endSound();
			}
			addDecision();
		}
		
		private function addDecision():void {
			_decisions = new DecisionsView(_dv,0xFFFFFF,true);
			
//			_nextY += _pageInfo.decisionsMarginTop;
			_decisions.y = _nextY;
			_mc.addChild(_decisions);
		}
		
		private function pageOn(e:ViewEvent):void {
			_mc.password_mc.submit_btn.addEventListener(MouseEvent.CLICK, submitClick);
			
			_lobster.play();
			_clawAnimating = true;
			TweenMax.delayedCall(1.8, turnOffClaw);
			
			_fish2.goLeft = true;
			_fish3.goLeft = true;
			_fish4.goLeft = false;  
			_fish4.orientRight = true; 
			
			_bubbles1 = new Bubbles();
			_renderer1.addEmitter( _bubbles1 );
			_renderer1.x = _mc.bubbles1_mc.x;
			_renderer1.y = _mc.bubbles1_mc.y; 
			_bubbles1.start();
			
			_bubbles2 = new Bubbles();
			_renderer2.addEmitter( _bubbles2 );
			_renderer2.x = _mc.bubbles2_mc.x; 
			_renderer2.y = _mc.bubbles2_mc.y;
			_bubbles2.start();
			
			_bubbles3 = new Bubbles(true, -150);
			_renderer3.addEmitter( _bubbles3 );
			_renderer3.x = _mc.bubbles3_mc.x; 
			_renderer3.y = _mc.bubbles3_mc.y;
			_bubbles3.start();
			
			_bubbles4 = new Bubbles(true, -150);
			_renderer4.addEmitter( _bubbles4 );
			_renderer4.x = _mc.bubbles4_mc.x; 
			_renderer4.y = _mc.bubbles4_mc.y;
			_bubbles4.start();

			addEventListener(Event.ENTER_FRAME, enterFrameLoop);
		}
		
		private function turnOffClaw():void {
			_clawDone = true;
		}
		
		protected function enterFrameLoop(event:Event):void
		{
			
			if (_clawDone && _clawAnimating) {
				if (_lobster.currentFrame == 1) {
					_lobster.stop();
					_clawAnimating = false;
				}
			}
			
			if (_dragVCont.isDragging || _dragVCont.isTweening) {
				TweenMax.pauseAll();
				
				if (_clawAnimating && ! _clawDone) {
					_lobster.stop();
				}
				
				_bubbles1.pause()
				_bubbles2.pause();
				_bubbles3.pause();
				_bubbles4.pause();
				_scrolling = true;
				
			} else {
				
				moveFish(_fish2, .8);
				moveFish(_fish3, .6);
				moveFish(_fish4, .4);
				
				if (!_scrolling) return;
				
				if (_clawAnimating && ! _clawDone) {
					_lobster.play();
				}

				TweenMax.resumeAll();
				_bubbles1.resume();
				_bubbles2.resume();
				_bubbles3.resume();
				_bubbles4.resume();
				_scrolling = false;
			}
			
		}
		
		private function moveFish(thisMC:MovieClip, thisAmt:Number):void {
			if (thisMC.goLeft) {
				thisMC.x -= thisAmt;
				if (thisMC.x < - (thisMC.width*2)) {
					thisMC.goLeft = false;
					if (thisMC.orientRight) {
						thisMC.scaleX = 1;
					} else {
						thisMC.scaleX = -1;
					}
					
				}
			} else {
				thisMC.x += thisAmt;
				if (thisMC.x > DataModel.APP_WIDTH + thisMC.width) {
					thisMC.goLeft = true;
					if (thisMC.orientRight) {
						thisMC.scaleX = -1;
					} else {
						thisMC.scaleX = 1;
					}
					
				}
			}
		}
		
		protected function decisionMade(event:ViewEvent):void
		{
			_bubbles1.pause()
			_bubbles2.pause();
			_bubbles3.pause();
			_bubbles4.pause();
			
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