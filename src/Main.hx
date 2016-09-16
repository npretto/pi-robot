package;

import haxe.Timer;
import haxe.io.Float32Array;
import js.Browser;
import js.Lib;
import js.html.WebSocket;

using StringTools;

/**
 * ...
 * @author npretto
 */

 class Point
 {
	public var x:Float;
	public var y:Float;
	
	public var length(get, null):Float;
	
	public function new (x:Float, y:Float)
	{
		set(x, y);
	}
	
	public function set (?x:Float=0, ?y:Float=0):Point
	{
		this.y = y;
		this.x = x;
		return this;
	}
	
	public function normalize()
	{
		var l = length;
		if (l == 0)
			return;
		x = x / l;
		y = y / l;
	}
	
	public function get_length():Float
	{
		return Math.sqrt(x * x + y * y);
	}
	
	public function applyDeadZone(dz:Float) 
	{
		x = x > dz ? x : (x < -dz ? x : 0);
		y = y > dz ? y : y < -dz ? y : 0;
		return this;
		
	}
 }
 
class Main 
{
	
	static var input:Point;
	static var keys = new Map<String,Bool>();
	static private var socket:js.html.WebSocket;
	static private var gamepad:Dynamic;
	
	static function main() 
	{
		input = new Point(0,0);
		socket = new WebSocket('ws://'+Browser.window.location.host);
		//socket = new WebSocket("ws://192.168.0.103:8000");
		Browser.window.addEventListener("keydown", function(key)
		{
			keys.set(key.code, true);
		});
		Browser.window.addEventListener("keyup", function(key)
		{
			keys.set(key.code, false);
		});
		
		Browser.window.addEventListener("gamepadconnected", function(e) {
			trace("Gamepad connected at index %d: %s. %d buttons, %d axes.",
			e.gamepad.index, e.gamepad.id,
			e.gamepad.buttons.length, e.gamepad.axes.length);
			
			if (! cast(e.gamepad.id, String).startsWith("XiaoMi"))
			{
				trace('gamepad ${e.gamepad.id} connected and being used for the robot');
				gamepad = e.gamepad;
				(cast Browser.window).gamepad= gamepad;
			}
		});
		
		Browser.window.addEventListener("gamepaddisconnected", function(e) {
			if (e.gamepad == gamepad)
			{
				trace("disconnected gamepad");
				gamepad == null;
			}
		});
		
		Browser.window.setInterval(loop,200);
	}
	
	public static function loop()
	{
		getInput();
		var motors = getMotors(input);
		var gamepad = getGamepad();
		if (gamepad != null && (gamepad.x != 0 || gamepad.y != 0))
		{
			motors = gamepad;
			trace(gamepad);
		}
		//trace(motors);
		
		socket.send('m:${motors.x}|${motors.y}');
		
	}
	
	static private function getGamepad() :Point
	{
		for (gamepad in Browser.navigator.getGamepads())
		{
			if ( gamepad != null && ! cast(gamepad.id, String).startsWith("XiaoMi"))
			{
				//trace('gamepad ${gamepad.id} found and being used for the robot');
				return new Point(-gamepad.axes[1], -gamepad.axes[3]).applyDeadZone(0.1);
			}
		}
		return null;
	}
	
	static private function getMotors(input:Point):Point
	{
		var motors = new Point(0, 0);
		if (input.x == 0)
		{
			motors.set(input.y, input.y);
		}else if (input.y == 0)
		{
			if (input.x > 0)
			{
				motors.set(input.x, - input.x);
			}else
			{
				motors.set(input.x, - input.x);
			}
		}
				
		return motors;
		
	}
	
	static private function getInput() 
	{
		input.set(0, 0);
		if (keys.get("ArrowUp"))
		{
			input.y += 1;
		}
		if (keys.get("ArrowDown"))
		{
			input.y -= 1;
		}		
		if (keys.get("ArrowRight"))
		{
			input.x += 1;
		}
		if (keys.get("ArrowLeft"))
		{
			input.x -= 1;
		}
		//input.normalize();
	}
	
}