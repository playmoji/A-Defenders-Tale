package view
{
	import com.adobe.utils.StringUtil;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import control.EventController;
	
	import events.ApplicationEvent;
	import events.ViewEvent;
	
	import model.ContentPanelInfo;
	import model.DataModel;
	import model.PageInfo;
	import model.StoryPart;
	
	import util.fpmobile.controls.DraggableVerticalContainer;
	
	public class ContentsPanelView extends MovieClip 
	{
		public var dragVCont:DraggableVerticalContainer;
		private var _nextY:int;
		private var _pageArray:Vector.<ContentsPageView>;
		private var _pageInfoArray:Vector.<PageInfo>;
		private var _cpv:ContentsPageView;
		private var _pi:PageInfo;
		private var _selectedNamespace:String;
		private var _tempArray:Array;
		private var _restoring:Boolean;
		private var _loaderMax:LoaderMax;
		private var _loadMultiple:Boolean;
		private var _dm:DataModel;
		
		public function ContentsPanelView()
		{
			EventController.getInstance().addEventListener(ViewEvent.ADD_CONTENTS_PAGE, addContentsPage); 
//			EventController.getInstance().addEventListener(ViewEvent.DECISION_CLICK, decisionMade);
//			EventController.getInstance().addEventListener(ViewEvent.MAP_SELECT_ISLAND, resetSelectedIsland);
			EventController.getInstance().addEventListener(ApplicationEvent.RESTART_BOOK, resetPanel);
			EventController.getInstance().addEventListener(ApplicationEvent.GOD_MODE_ON, godModeOn);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_nextY = 0;
			
			dragVCont = new DraggableVerticalContainer(0, 0x000000, 0);
			dragVCont.SCROLL_INDICATOR_RIGHT_PADDING = 0;
			dragVCont.width = Math.floor(this.parent.parent.width) - 2;
			dragVCont.height = Math.floor(this.parent.parent.height) - 13; 
			dragVCont.refreshView(true);
			addChild(dragVCont);
			
			_loaderMax = new LoaderMax({name:"mainQueue", onProgress:progressHandler, onComplete:completeHandler, onError:errorHandler});
			
			
			_dm = DataModel.getInstance();

			_pageArray = new Vector.<ContentsPageView>();
			_pageInfoArray = new Vector.<PageInfo>();

		}
		
		public function restorePrevious():void {
			_pageArray = new Vector.<ContentsPageView>();
			_pageInfoArray = DataModel.PAGE_ARRAY;
			_restoring = true;
			addPreviousPages();
		}
		
		private function progressHandler(event:LoaderEvent):void { 
//			trace("progress: " + event.target.progress);
		}
		
		private function completeHandler(event:LoaderEvent):void {
//			trace(event.target + " is complete!");
		}
		
		private function errorHandler(event:LoaderEvent):void {
			trace("_loaderMax ++++++ error occured with " + event.target + ": " + event.text);
		}
		
		public function addImageLoader(imgLdr:ImageLoader):void {
			_loaderMax.append(imgLdr);
		}
		
		protected function resetPanel(event:ApplicationEvent):void
		{
			removeOldPages();
		}
		
		protected function godModeOn(event:Event):void
		{
			_loadMultiple = true;
			var cpiVect:Vector.<ContentPanelInfo> = DataModel.appData.parseContentsForGod();
			
			for (var i:int = 0; i < cpiVect.length; i++) 
			{
				var pgInf:PageInfo = new PageInfo();
				pgInf.contentPanelInfo = cpiVect[i];
				addPage(pgInf);
			}
			//LOAD THE IMAGES
			_loaderMax.load(true);
			
			_loadMultiple = false;
		}
		
		protected function addPreviousPages():void
		{
			_loadMultiple = true;
//			trace("addPreviousPages");
//			trace(_pageInfoArray.length);
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				addPage(_pageInfoArray[i]);
			}
			
			//LOAD THE IMAGES
			_loaderMax.load(true);
			
			_restoring = false;
			_loadMultiple = false;
		}
		
		protected function addContentsPage(event:ViewEvent):void
		{
			
			if (DataModel.GOD_MODE) return;
			
			var pgInf:PageInfo = event.data as PageInfo;
			
			if (checkForPage(pgInf)) return;
			
//			trace("CP!!!! addContentsPage: "+pgInf.contentPanelInfo.pageID);
			
			addPage(pgInf);
		}
		
		private function checkForPage(pgInf:PageInfo):Boolean {
			var pageFound:Boolean = false;
			
			for (var i:int = 0; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (pgInf.contentPanelInfo.pageID == _cpv.pgInfo.contentPanelInfo.pageID) {
					
//					if (pgInf.contentPanelInfo.pageID == "MapView" && i < _pageArray.length - 1 ) {
//						
//					} else {
//						pageFound = true;
//					}
					pageFound = true;
				}
			}
			
			return pageFound;
		}
		
		
		public function pageVisited(pageID:String):Boolean {
//			trace("pageVisited DataModel.CURRENT_PAGE_ID:"+DataModel.CURRENT_PAGE_ID);
			var pageFound:Boolean = false;
			
			for (var i:int = 0; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (pageID == _cpv.pgInfo.contentPanelInfo.pageID) {
					pageFound = true;
				}
			}
			
			return pageFound;
		}

		public function changingPath(nextSelectedID:String):Boolean {
//			trace("changingPath nextSelectedID: "+nextSelectedID);
			var nextPageNew:Boolean = false;
			var currentPageIndex:int;
			var nextVisited:String;
			
			if (_pageInfoArray.length <= 1) {
				nextPageNew = false;
				return nextPageNew;
			}
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				_pi = _pageInfoArray[i];
				if (DataModel.CURRENT_PAGE_ID == _pi.contentPanelInfo.pageID) {
					currentPageIndex = i;
					//if the next one is new i.e. beyond _pageInfoArray
					if ((currentPageIndex+1) >= _pageInfoArray.length) {
						return false;
					}
					nextVisited = _pageInfoArray[currentPageIndex+1].contentPanelInfo.pageID;
					break;
				}
			}
//			trace("currentPageIndex: "+currentPageIndex);
//			trace("next visited page: " + nextVisited);
//			trace("next CLICKED page: "+nextSelectedID);
			//without null check returned true on TitleScreen "CONTINUE STORY"
			if (nextSelectedID != nextVisited && nextVisited != null) {
				nextPageNew = true;
			}
//			trace("nextPageNew: "+nextPageNew);
			
			return nextPageNew;
		}
		
		public function backSteps(numSteps:int=1):String {
			var currentPageIndex:int;
			var previousVisited:String;
			
			for (var i:int = 0; i < _pageInfoArray.length; i++) 
			{
				_pi = _pageInfoArray[i];
				if (DataModel.CURRENT_PAGE_ID == _pi.contentPanelInfo.pageID) {
					currentPageIndex = i;
					//if the next one is less than
					if ((currentPageIndex-numSteps) < 0) {
						trace("YOU'VE GONE BACK TOO FAR IN TIME!!!!");
						return DataModel.CURRENT_PAGE_ID;
					}
					previousVisited = _pageInfoArray[currentPageIndex-numSteps].contentPanelInfo.pageID;
					break;
				}
			}
			return previousVisited;
		}
		
		public function scrollToBottom():void {
			dragVCont.scrollY = dragVCont.maxScroll;
		}
		
		public function addPage(pgInf:PageInfo):void {
			var newPage:ContentsPageView = new ContentsPageView(pgInf,this);
			
			dragVCont.addChild(newPage);
			dragVCont.refreshView(true);
			
			_pageArray.push(newPage);
			
			if (!_restoring) {
				//IMPORTANT FOR RESTORE
				_pageInfoArray.push(pgInf);
				DataModel.PAGE_ARRAY = _pageInfoArray;
			}
			
			if (!_loadMultiple) {
//				trace("load CPV image");
				_loaderMax.load(true);
			}
			
			_nextY += newPage.pageHeight;
//			trace("++++addPage: "+ pgInf.contentPanelInfo.pageID);
			scrollToBottom();
		}
		
//		protected function decisionMade(event:ViewEvent):void
//		{
//			var decisionID:String = event.data.id;
//			
//			var len:int = _pageArray.length;
//			
//			for (var i:int = 0; i < len; i++) 
//			{
//				_cpv = _pageArray[i] as ContentsPageView;
//				
//				
//				if (DataModel.CURRENT_PAGE_ID == _cpv.pgInfo.contentPanelInfo.pageID) {
////					_cpv.activate();
//					
//					if (DataModel.GOD_MODE) return;
//					
//					if (event.data.contentsPanelClick) return;
//					
////					removeOldPages(i+1);
//					return;
//				}
//			}
//		}
		
		public function overwriteHistory():void {
			var len:int = _pageArray.length;
						
			for (var i:int = 0; i < len; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				
				if (DataModel.CURRENT_PAGE_ID == _cpv.pgInfo.contentPanelInfo.pageID) {
					
					if (DataModel.GOD_MODE) return;
					
					removeOldPages(i+1);
					return;
				}
			}
			
		}
		
		private function removeOldPages(startIndex:int = 0):void {
			if (DataModel.GOD_MODE) return;
			
			trace("††††††††††† removeOldPages");
			for (var i:int = startIndex; i < _pageArray.length; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				
				resetVariable(_cpv.pgInfo.contentPanelInfo.pageID);
				
				_nextY -= _cpv.pageHeight;
				_cpv.destroy();
				dragVCont.removeChild(_cpv);
				dragVCont.refreshView(true);
			}
			_pageArray.length = startIndex;
			_pageInfoArray.length = startIndex;
			
			//IMPORTANT FOR RESTORE
			DataModel.PAGE_ARRAY = _pageInfoArray;
			
		}
		
		private function resetVariable(thisID:String):void {
			if (thisID == "theCattery.GameWonView") DataModel.STONE_CAT = false;
			if (thisID == "shipwreck.CompanionView") DataModel.STONE_PEARL = false;
			if (thisID == "sandlands.SandstoneWinView") DataModel.STONE_SAND = false;
			if (thisID == "joylessMountains.StoneView") DataModel.STONE_SERPENT = false;
			
			if (thisID == "theCattery.FourthDoorView") DataModel.bleujeanna = false;
			if (thisID == "theCattery.ThirdDoorView") DataModel.thirdDoor = false;
			if (thisID == "prologue.StealView") DataModel.captainBattled = false;
			if (thisID == "joylessMountains.Climb1View") DataModel.climbDone = false;
			if (thisID == "joylessMountains.Escalator1View") DataModel.escalator1 = false;
			if (thisID == "joylessMountains.RallyView") DataModel.rally = false;
			if (thisID == "prologue.SuppliesView") DataModel.supplies = false;
			if (thisID == "shipwreck.SmegView") DataModel.smegTalk = false;
			if (thisID == "sandlands.SandView") DataModel.sandpit = false;
			if (thisID == "sandlands.WellView") DataModel.well = false;
			if (thisID == "sandlands.Sand2View") DataModel.sand5Ft = false;
			if (thisID == "sandlands.Well4View") DataModel.dropsCorrect = false;
		}
		
		protected function resetSelectedIsland(event:ViewEvent):void
		{
			_selectedNamespace = DataModel.ISLAND_NAMESPACE[DataModel.CURRENT_ISLAND_INT];
			
			var len:int = _pageArray.length;
			var i:int;
			_tempArray = [];
			
			for (i = 0; i < len; i++) 
			{
				_cpv = _pageArray[i] as ContentsPageView;
				if (StringUtil.beginsWith(_cpv.pgInfo.contentPanelInfo.pageID, _selectedNamespace)) {
					_nextY -= _cpv.pageHeight;
					_cpv.destroy();
					_tempArray.push(i);
					
					dragVCont.removeChild(_cpv);
					dragVCont.refreshView(true);
				}
			}
			_pageArray.splice(_tempArray[0], _tempArray.length);
			_pageInfoArray.splice(_tempArray[0], _tempArray.length);
		}
		
		
	}
}