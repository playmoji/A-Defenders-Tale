package view
{
	
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import control.EventController;
	
	import events.ViewEvent;
	
	import model.DataModel;
	
	public class SocialSignInSelectView extends MovieClip
	{
		private var _mc:MovieClip;
		private var _closeBtn:MovieClip;
		private var _facebookBtn:MovieClip;
		private var _twitterBtn:MovieClip;
		private var _submitBtn:MovieClip;
		private var _nameTF:TextField; 
		private var _nameHit:MovieClip;
		
		public function SocialSignInSelectView(mc:MovieClip)
		{
			_mc = mc;
//			super();
			init();
		}
		
		private function init() : void {
			_closeBtn = _mc.getChildByName("x_btn") as MovieClip;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeClick);
			
			_facebookBtn = _mc.getChildByName("facebook_btn") as MovieClip;
			_facebookBtn.addEventListener(MouseEvent.CLICK, facebookClick);

			_twitterBtn = _mc.getChildByName("twitter_btn") as MovieClip;
			_twitterBtn.addEventListener(MouseEvent.CLICK, twitterClick);
			
			_nameTF = _mc.getChildByName("name_txt") as TextField;
			_nameTF.maxChars = 100;
			_nameTF.addEventListener(FocusEvent.FOCUS_OUT, capFirst); 
			
			_submitBtn = _mc.getChildByName("submit_btn") as MovieClip;
			_submitBtn.addEventListener(MouseEvent.CLICK, submitClick);
			
			_nameHit = _mc.nameHit_mc;
			setHitForText(_nameTF, _nameHit);
			
			//GRAPHICS
			DataModel.getInstance().setGraphicResolution(_mc);
		}
		
		private function setHitForText(thisTF:TextField, thisMC:MovieClip) : void {
			thisMC.thisTF = thisTF;
			thisMC.addEventListener(MouseEvent.CLICK, focusText);
		}
		
		protected function focusText(e:MouseEvent):void
		{
			var thisMC:MovieClip = e.target as MovieClip;
			var theTF:TextField = thisMC.thisTF;
			_mc.stage.focus = theTF;
			theTF.requestSoftKeyboard();
		}	
		
		protected function submitClick(event:MouseEvent):void
		{
			if (_nameTF.text != "") {
				var fullName:Array = _nameTF.text.split(" ");
				var firstName:String = fullName[0];
				
				DataModel.defenderInfo.contact = firstName; 
				DataModel.defenderInfo.contactFullName = _nameTF.text; 
				DataModel.SOCIAL_CONNECTED = false;
				EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CONTACT_SELECTED));
			}
		}
		
		protected function capFirst(event:FocusEvent):void
		{
			var thisTF:TextField = event.target as TextField;
			var str:String = thisTF.text;
			var firstChar:String = str.substr(0, 1);
			var restOfString:String = str.substr(1, str.length);
			thisTF.text = firstChar.toUpperCase()+restOfString.toLowerCase();
		}
		
		protected function facebookClick(event:MouseEvent):void
		{
			if (!DataModel.getInstance().networkConnection()) return;
			
			DataModel.SOCIAL_CONNECTED = true;
			DataModel.SOCIAL_PLATFORM = DataModel.SOCIAL_FACEBOOK;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.LOGIN_FACEBOOK));	
		}
		
		protected function twitterClick(event:MouseEvent):void
		{
			if (!DataModel.getInstance().networkConnection()) return;
			
			DataModel.SOCIAL_CONNECTED = true;
			DataModel.SOCIAL_PLATFORM = DataModel.SOCIAL_TWITTER;
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.LOGIN_TWITTER));	
		}
		
		private function closeClick(e:MouseEvent) : void {
			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.CLOSE_EMERGENCY_OVERLAY));
		}
		
		public function destroy():void
		{
			_closeBtn.removeEventListener(MouseEvent.CLICK, closeClick);
			_facebookBtn.removeEventListener(MouseEvent.CLICK, facebookClick);
			_twitterBtn.removeEventListener(MouseEvent.CLICK, twitterClick);
			_nameTF.removeEventListener(FocusEvent.FOCUS_OUT, capFirst); 
			_submitBtn.removeEventListener(MouseEvent.CLICK, submitClick);
			
			_closeBtn = null;
			_facebookBtn = null;
			_twitterBtn = null;
			_submitBtn = null;
			
			_nameHit.removeEventListener(MouseEvent.CLICK, setHitForText);
			_nameHit = null;
		}
	}
}