package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import flixel.math.FlxPoint;

using StringTools;

class Boyfriend extends Character
{
	//static inline var speed:Float = 200;

	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char, true);
	}

	/*function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;

		up = FlxG.keys.anyPressed([UP]);
		down = FlxG.keys.anyPressed([DOWN]);
		left = FlxG.keys.anyPressed([LEFT]);
		right = FlxG.keys.anyPressed([RIGHT]);

		if (up && down)	up = down = false;
		if (left && right)	left = right = false;

		if (up || down || left || right)
		{
		    velocity.x = speed;
 			velocity.y = speed;
		}

		var newAngle:Float = 0;
		if (up)
		{
			newAngle = -90;
			if (left)
				newAngle -= 45;
			else if (right)
				newAngle += 45;
		}
		else if (down)
		{
			newAngle = 90;
			if (left)
				newAngle += 45;
			else if (right)
				newAngle -= 45;
		}
		else if (left)
			newAngle = 180;
		else if (right)
			newAngle = 0;

		velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), newAngle);
	}*///Shitty thing (it works lmao)

	override function update(elapsed:Float)
	{
		//updateMovement();
		
		if (!debugMode && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}
			else
				holdTimer = 0;

			if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
			{
				playAnim('idle', true, false, 10);
			}

			if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished && startedDeath)
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
