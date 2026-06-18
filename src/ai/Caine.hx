package ai;

class CaineLine
{
	public var text:String;
	public var mood:String;
	public var weight:Float;

	public function new(text:String, mood:String = "neutral", weight:Float = 1.0)
	{
		this.text   = text;
		this.mood   = mood;
		this.weight = weight;
	}
}

class CaineTrigger
{
	public var keywords:Array<String>;
	public var lines:Array<CaineLine>;
	public var priority:Int;

	public function new(keywords:Array<String>, lines:Array<CaineLine>, priority:Int = 0)
	{
		this.keywords = keywords;
		this.lines    = lines;
		this.priority = priority;
	}
}

class Caine
{
	static var triggers:Array<CaineTrigger> = [];
	static var idleLines:Array<CaineLine>   = [];
	static var lastLine:String              = "";
	static var currentMood:String           = "neutral";
	static var rng:Float->Float->Float      = (min, max) -> min + Math.random() * (max - min);

	public static function init():Void
	{
		triggers  = [];
		idleLines = [];
		registerDefaults();
	}

	static function registerDefaults():Void
	{
		registerIdle([
			new CaineLine("Welcome back to the circus!", "happy"),
			new CaineLine("Step right up, step right up!", "happy"),
			new CaineLine("Isn't this just wonderful?", "neutral")
		]);

		registerTrigger(["quit", "leave", "exit"], [
			new CaineLine("Leaving so soon?", "sad"),
			new CaineLine("The circus isn't done with you yet!", "excited")
		]);

		registerTrigger(["win", "victory", "success"], [
			new CaineLine("Magnificent! Simply magnificent!", "excited"),
			new CaineLine("A star performer, right here!", "happy")
		]);

		registerTrigger(["lose", "fail", "defeat"], [
			new CaineLine("Oh dear, that didn't go as planned.", "sad"),
			new CaineLine("Don't worry, the show must go on!", "neutral")
		]);
	}

	public static function registerTrigger(keywords:Array<String>, lines:Array<CaineLine>, priority:Int = 0):Void
	{
		triggers.push(new CaineTrigger(keywords, lines, priority));
		triggers.sort((a, b) -> b.priority - a.priority);
	}

	public static function registerIdle(lines:Array<CaineLine>):Void
	{
		for (l in lines) idleLines.push(l);
	}

	public static function respond(input:String):String
	{
		var normalized = input.toLowerCase();
		var matched:CaineTrigger = null;

		for (trigger in triggers)
		{
			for (keyword in trigger.keywords)
			{
				if (normalized.indexOf(keyword) != -1)
				{
					matched = trigger;
					break;
				}
			}
			if (matched != null) break;
		}

		if (matched != null)
			return pickLine(matched.lines);

		return idle();
	}

	public static function idle():String
	{
		if (idleLines.length == 0) return "...";
		return pickLine(idleLines);
	}

	static function pickLine(lines:Array<CaineLine>):String
	{
		if (lines.length == 0) return "...";

		var available = lines.filter(l -> l.text != lastLine);
		if (available.length == 0) available = lines;

		var totalWeight = 0.0;
		for (l in available) totalWeight += l.weight;

		var roll = rng(0, totalWeight);
		var acc  = 0.0;

		for (l in available)
		{
			acc += l.weight;
			if (roll <= acc)
			{
				lastLine    = l.text;
				currentMood = l.mood;
				return l.text;
			}
		}

		var fallback = available[available.length - 1];
		lastLine    = fallback.text;
		currentMood = fallback.mood;
		return fallback.text;
	}

	public static function getMood():String
	{
		return currentMood;
	}

	public static function getLastLine():String
	{
		return lastLine;
	}

	public static function clearTriggers():Void
	{
		triggers = [];
	}

	public static function clearIdleLines():Void
	{
		idleLines = [];
	}

	public static function reset():Void
	{
		lastLine    = "";
		currentMood = "neutral";
		clearTriggers();
		clearIdleLines();
		registerDefaults();
	}
}
