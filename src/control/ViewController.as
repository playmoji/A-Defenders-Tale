﻿package control {		import com.greensock.TweenMax;	import com.greensock.easing.Quad;	import com.neriksworkshop.lib.ASaudio.Track;		import flash.display.Loader;	import flash.display.LoaderInfo;	import flash.display.MovieClip;	import flash.display.Sprite;	import flash.events.Event;	import flash.net.URLRequest;	import flash.net.registerClassAlias;	import flash.system.ApplicationDomain;	import flash.system.Capabilities;	import flash.system.LoaderContext;	import flash.system.System;	import flash.utils.describeType;	import flash.utils.getDefinitionByName;	import flash.utils.getQualifiedClassName;		import assets.FadeToBlackMC;		import events.ApplicationEvent;	import events.ViewEvent;		import games.bopMice.BopMice;		import model.DataModel;	import model.DefenderApplicationInfo;		import view.ApplicationView;	import view.IPageView;	import view.JellyfishGameOGView;	import view.MapView;	import view.NavigationView;	import view.TitleScreenView;	import view.joylessMountains.AwakenSerpentView;	import view.joylessMountains.CaveView;	import view.joylessMountains.Climb1View;	import view.joylessMountains.Climb2View;	import view.joylessMountains.Climb3View;	import view.joylessMountains.Climb4View;	import view.joylessMountains.DinnerView;	import view.joylessMountains.ElevatorView;	import view.joylessMountains.Escalator1View;	import view.joylessMountains.Escalator2View;	import view.joylessMountains.ExploreView;	import view.joylessMountains.Impatience1View;	import view.joylessMountains.Impatience2View;	import view.joylessMountains.Impatience3View;	import view.joylessMountains.JoylessMountainsIntroView;	import view.joylessMountains.METS4EvaView;	import view.joylessMountains.PicnicView;	import view.joylessMountains.Platform3View;	import view.joylessMountains.Platform4View;	import view.joylessMountains.PlayRiddlesView;	import view.joylessMountains.PlaySongView;	import view.joylessMountains.RallyView;	import view.joylessMountains.RosesView;	import view.joylessMountains.SnowmonchView;	import view.joylessMountains.StealStoneView;	import view.joylessMountains.StoneView;	import view.joylessMountains.TalkView;	import view.joylessMountains.TreasureView;	import view.prologue.BelowDeckView;	import view.prologue.BoatIntroView;	import view.prologue.BoatView;	import view.prologue.Cellar1View;	import view.prologue.Cellar2View;	import view.prologue.CrossSeaView;	import view.prologue.DocksView;	import view.prologue.FightView;	import view.prologue.IntroAllIslandsView;	import view.prologue.NegotiateView;	import view.prologue.PrologueView;	import view.prologue.ReasonView;	import view.prologue.SeaMonsterView;	import view.prologue.StealView;	import view.prologue.SuppliesView;	import view.prologue.TravelerView;	import view.prologue.TruthView;	import view.prologue.coins.Coin1View;	import view.prologue.coins.Coin2View;	import view.prologue.coins.Coin3View;	import view.prologue.coins.Coin4View;	import view.prologue.coins.Coin5View;	import view.prologue.coins.Coin6View;	import view.prologue.coins.Coin7View;	import view.sandlands.ApprenticeView;	import view.sandlands.FindWizardView;	import view.sandlands.HutView;	import view.sandlands.Sand2View;	import view.sandlands.Sand3View;	import view.sandlands.SandView;	import view.sandlands.SandlandsView;	import view.sandlands.ShoreView;	import view.sandlands.StraightView;	import view.sandlands.WaitView;	import view.sandlands.Well2View;	import view.sandlands.Well3View;	import view.sandlands.Well4View;	import view.sandlands.WellView;	import view.sandlands.WindingView;	import view.shipwreck.CaptainView;	import view.shipwreck.CompanionView;	import view.shipwreck.FollowCommodoreView;	import view.shipwreck.Jellyfish1View;	import view.shipwreck.JellyfishGameView;	import view.shipwreck.JokeView;	import view.shipwreck.Pearl1View;	import view.shipwreck.Reef1View;	import view.shipwreck.Reef2View;	import view.shipwreck.Shark1View;	import view.shipwreck.Shark2View;	import view.shipwreck.ShipwreckCoveView;	import view.shipwreck.SmegView;	import view.shipwreck.Starfish1View;	import view.shipwreck.Starfish2View;	import view.shipwreck.Starfish3View;	import view.theCattery.AcceptOfferView;	import view.theCattery.BallView;	import view.theCattery.BopMiceView;	import view.theCattery.CatRanchShoreView;	import view.theCattery.CatlingAffairsView;	import view.theCattery.FollowView;	import view.theCattery.FourthDoorView;	import view.theCattery.GameLostView;	import view.theCattery.GameWonView;	import view.theCattery.Island1View;	import view.theCattery.LingerView;	import view.theCattery.MouseConsultationView;	import view.theCattery.NoTrespassingView;	import view.theCattery.PrivateAudienceView;	import view.theCattery.RefuseOfferView;	import view.theCattery.RendezvousView;	import view.theCattery.ReturnToBoatView;	import view.theCattery.ScratchEarsView;	import view.theCattery.ThirdDoorView;

	/**	 * @author Mark Grochowski	 */	public class ViewController 	{		private var _mc : MovieClip;		private var _titleScreen:TitleScreenView;		private var _applicationScreen:ApplicationView;		private var _goViral:GoViralService;		private var _sectionHolder:Sprite;		private var _navigation:NavigationView;		private var _currentPage:IPageView;		private var _newPageClass:Class;		private var _introSound:Track;		private var _fade:FadeToBlackMC;		//HACK - this is to force the compiler to include these clases into the build;//		COMMON		//		PROLOGUE		PrologueView, Coin1View, Coin2View, Coin3View, Coin4View, Coin5View, Coin6View, Coin7View, BelowDeckView, BoatIntroView,		BoatView, Cellar1View, Cellar2View, CrossSeaView, DocksView, FightView, IntroAllIslandsView, NegotiateView, ReasonView,		SeaMonsterView, StealView, SuppliesView, TravelerView, TruthView//		JOYLESS		AwakenSerpentView, CaveView, Climb1View, Climb2View, Climb3View, Climb4View, DinnerView, ElevatorView, Escalator1View, 		Escalator2View, ExploreView, Impatience1View, Impatience2View, Impatience3View, JoylessMountainsIntroView,		METS4EvaView, PicnicView, Platform3View, Platform4View, PlayRiddlesView, PlaySongView, RallyView, RosesView,		SnowmonchView, StealStoneView, TalkView, StoneView, TreasureView//		SANDLANDS		ApprenticeView, FindWizardView, HutView, Sand2View, Sand3View, SandlandsView, SandView, ShoreView, StraightView,		WaitView, Well2View, Well3View, Well4View, WellView, WindingView//		SHIPWRECK		CaptainView, CompanionView, FollowCommodoreView, Jellyfish1View, JellyfishGameView, JokeView, Pearl1View,		Reef1View, Reef2View, Shark1View, Shark2View, ShipwreckCoveView, SmegView, Starfish1View, Starfish2View, Starfish3View//		THE CATTERY		AcceptOfferView, BallView, BopMiceView, CatlingAffairsView, CatRanchShoreView, FollowView, FourthDoorView, GameWonView,		Island1View, LingerView, MouseConsultationView, NoTrespassingView, PrivateAudienceView, RefuseOfferView, RendezvousView,		ReturnToBoatView, ScratchEarsView, ThirdDoorView				public function ViewController( mc : MovieClip )		{			_mc = mc;						var myOS:String = Capabilities.os; 			var myOSLowerCase:String = myOS.toLowerCase();			if(myOSLowerCase.indexOf("ipad1,", 0) >= 0) {				DataModel.ipad1 = true;			} 			//			NEEDED FOR AOT COMPILING. OTHERWISE ASSET SWFS WON'T LOAD			DataModel.LoadContext = new LoaderContext(false, ApplicationDomain.currentDomain, null);						EventController.getInstance().addEventListener(ApplicationEvent.TITLE_DONE, showApplication);			EventController.getInstance().addEventListener(ApplicationEvent.APPLICATION_SUBMITTED, appSubmitted);			EventController.getInstance().addEventListener(ViewEvent.SHOW_PAGE, showPage);						// !!!! FOR TRANSITIONS OR GAMES, CONSIDER CHANGING FRAME RATE????			//			_titleScreen = new TitleScreenView;//			_mc.addChild(_titleScreen);//			//			_introSound = new Track("assets/audio/intro.mp3");//			_introSound.start(true);//			_introSound.loop = true;1						_sectionHolder = new Sprite(); 			_mc.addChild(_sectionHolder);						_navigation = new NavigationView();			_mc.addChild(_navigation);			TweenMax.to(_navigation, 0, {autoAlpha:0});						_fade = new FadeToBlackMC();			_mc.addChild(_fade);			TweenMax.to(_fade, 0, {autoAlpha:0});						// SKIP TO APPLICATION FOR TESTING!!!!//			showApplication(null);						testData();						addPage("theCattery.FollowView");//			addPage("theCattery.CatRanchShoreView"); !!!!!!! next page (CatAff) CRASHES ON iPad1//			addPage("shipwreck.Starfish3View");//			addPage("prologue.PrologueView");//			addPage("joylessMountains.StoneView");		}				protected function showPage(event:ViewEvent):void
		{
			TweenMax.to(_fade, 1, {autoAlpha:1, onComplete:addPage, onCompleteParams:[event.data.id]});		}						protected function appSubmitted(event:ApplicationEvent):void
		{			if (_introSound) {				_introSound.stop(true);				_introSound = null;			}						var infObj:Object = event.data as Object;						DataModel.defenderInfo.defender = infObj.defender;			DataModel.defenderInfo.age = infObj.age;			DataModel.defenderInfo.hair = infObj.hair;			DataModel.defenderInfo.beverage = infObj.beverage;			DataModel.defenderInfo.gender = infObj.gender;			DataModel.defenderInfo.romantic = infObj.romantic;			DataModel.defenderInfo.companion = infObj.companion;			DataModel.defenderInfo.weapon = infObj.weapon;			DataModel.defenderInfo.instrument = infObj.instrument;			DataModel.defenderInfo.wardrobe = infObj.wardrobe;
			DataModel.defenderInfo.contact = infObj.contact;			DataModel.defenderInfo.contactGender = int(infObj.contactGender);			DataModel.defenderInfo.applicationDate = new Date();						// TESTING !!!!!!			if (infObj.defender == "") {				testData();			}						var randNum:int;						if (DataModel.defenderInfo.gender == 2) {				// assign either male of female if undecided				randNum = Math.round(DataModel.getInstance().randomRange(0,1));				DataModel.defenderInfo.gender = randNum;			}			if (DataModel.defenderInfo.romantic == 2) {				// assign either male of female if undecided				randNum = Math.round(DataModel.getInstance().randomRange(0,1));				DataModel.defenderInfo.romantic = randNum;			}						if (_applicationScreen) {				TweenMax.to(_applicationScreen, 1, {y:-DataModel.APP_HEIGHT, ease:Quad.easeInOut, onComplete:showPrologue});			} else {				TweenMax.to(_currentPage, 1, {y:-DataModel.APP_HEIGHT, ease:Quad.easeInOut, onComplete:showPrologue});			}			
//			TweenMax.to(_applicationScreen, 0, {y:-DataModel.APP_HEIGHT, ease:Quad.easeInOut, onComplete:addPage, onCompleteParams:["theCattery.MouseConsultationView"]});
//			TweenMax.to(_applicationScreen, 0, {y:-DataModel.APP_HEIGHT, ease:Quad.easeInOut, onComplete:addPage, onCompleteParams:["joylessMountains.JoylessMountainsIntroView"]});
		}				private function testData():void {			if (!DataModel.defenderInfo) {				DataModel.defenderInfo = new DefenderApplicationInfo();			}//			DataModel.defenderInfo.defender = "Sarah";			DataModel.defenderInfo.defender = "Martha Mary Marlene May";			DataModel.defenderInfo.age = "30";			DataModel.defenderInfo.hair = "blond";			DataModel.defenderInfo.beverage = "Pinot Grigio";			DataModel.defenderInfo.gender = 1;			DataModel.defenderInfo.romantic = 0;			DataModel.defenderInfo.companion = 0;			DataModel.defenderInfo.weapon = 1;			DataModel.defenderInfo.instrument = 2;			DataModel.defenderInfo.wardrobe = 0;			DataModel.defenderInfo.contact = "Millicent";			//				DataModel.defenderInfo.contactFBID = "100004309001809";			DataModel.defenderInfo.contactFBID = null;			DataModel.defenderInfo.contactGender = 0;			DataModel.defenderInfo.applicationDate = new Date();		}				protected function showApplication(event:ApplicationEvent):void
		{			EventController.getInstance().removeEventListener(ApplicationEvent.TITLE_DONE, showApplication);			
			if (_titleScreen) {				_titleScreen.destroy();				_mc.removeChild(_titleScreen);			}			_applicationScreen = new ApplicationView();			_mc.addChild(_applicationScreen);			DataModel.defenderInfo = new DefenderApplicationInfo();		}					private function showPrologue() : void {			if (_applicationScreen) {				_applicationScreen.destroy();				_mc.removeChild(_applicationScreen);				_applicationScreen = null;			}//			PrologueView//			addPage("prologue.PrologueView");			//			TweenMax.to(_navigation, 0, {autoAlpha:1});//			TweenMax.from(_navigation, 1, {y:-100, ease:Quad.easeInOut});		}						private function removeCurrentPage() : void {			if (_applicationScreen) {				_applicationScreen.destroy();				_mc.removeChild(_applicationScreen);				_applicationScreen = null;			}						if (_currentPage != null) {				_currentPage.destroy();				_sectionHolder.removeChild(MovieClip(_currentPage));				_currentPage = null;				_newPageClass = null;			}					}		private function addPage(thisPage:String, thisPackage:String = "view.") : void {						removeCurrentPage();						//!GARBAGE COLLECT			System.gc();						if (thisPage == "theCattery.BopMiceView" || thisPage == "bopMice.BopMice") {				_mc.stage.frameRate = DataModel.BOP_MICE_FPS;			} else {				_mc.stage.frameRate = 60;			}						_newPageClass = getDefinitionByName(thisPackage+thisPage) as Class;						_currentPage = new _newPageClass();//			MovieClip(_currentPage).addEventListener(Event.ADDED_TO_STAGE, newPageOn);			_sectionHolder.addChild(MovieClip(_currentPage));						EventController.getInstance().addEventListener(ViewEvent.ASSET_LOADED, newPageOn);		}				protected function newPageOn(event:Event):void
		{			EventController.getInstance().removeEventListener(ViewEvent.ASSET_LOADED, newPageOn);//			trace("NEW PAGE ON@@@@@");
//			MovieClip(_currentPage).removeEventListener(Event.ADDED_TO_STAGE, newPageOn);			TweenMax.to(_fade, 1, {autoAlpha:0, onComplete:pageIn, delay:0});		}				private function pageIn():void {			EventController.getInstance().dispatchEvent(new ViewEvent(ViewEvent.PAGE_ON));		}			}}