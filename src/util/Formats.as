package util {	import flash.text.TextFieldAutoSize;	import flash.text.TextFormat;		import assets.fonts.Caslon224;	import assets.fonts.Caslon224BookItalic;
		/**	 * @author iasseo	 */	public class Formats {				private static var _caslon:String = new Caslon224().fontName;		private static var _caslonItalic:String = new Caslon224BookItalic().fontName;		private static var _baskervilleBold:String = new BaskervilleBold().fontName;				public function Formats() {		}						public static function errorFormat() : TextFormat 		{			var format:TextFormat = new TextFormat();			format.font = "Arial";			format.size = 20;			format.color = 0xFFFFFF;						return format;		}				public static function storyTextFormat(size:Number=20, align:String="left", leading:int=8, color:int=0xFFFFFF) : TextFormat 		{			var format:TextFormat = new TextFormat();			format.font = _caslon;			format.align = align;			format.size = size;			format.color = color;			format.leading = leading;			format.letterSpacing = .2;						return format;		}				public static function businessCardFormat(size:Number=20, align:String="center", leading:int=-40, color:int=0xF8DC81) : TextFormat 		{			var format:TextFormat = new TextFormat();			format.font = _baskervilleBold;//			format.font = "BaskervilleBold";			format.align = align;			format.size = size;			format.color = color;			format.leading = leading;						return format;		}				public static function jokeFormat(size:Number=32, align:String="center", leading:int=-4, color:int=0x8D8D8D) : TextFormat 		{			var format:TextFormat = new TextFormat();			format.font = _caslonItalic;			format.align = align;			format.size = size;			format.color = color;			format.leading = leading;						return format;		}	}}