package  {	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class Main extends Sprite {
		private const TILE_SIZE:uint = 70;			
		private const TILES_PER_ROW:uint = 5;
		private const PX_BETWEEN_ROWS:uint = 7;
		private const BOARD_START_X:uint = 160;
		private const BOARD_START_Y:uint = 70;		
		private const NUMBER_OF_TILES:uint = 20;
		
		private var pickedTiles:Array = new Array();
		private var bubbles:Array = new Array();
		private var pauseGame:Timer;
		private var bubbleTimer:Timer;
		private var canPick:Boolean = true;
		private var backgroundImage:background_movieclip;
		private var bigBubble:bigBubble_movieclip;
		private var tilesLeft:uint;

		public function Main() {
			// Adding title screen
			backgroundImage = new background_movieclip();
			backgroundImage.gotoAndStop(1);
			addChild(backgroundImage);
			
			// Adding left frog bubble
			var leftFrogBubble:leftFrogBubble_movieclip = new leftFrogBubble_movieclip();
			leftFrogBubble.gotoAndStop(1);
			leftFrogBubble.x = 37;
			leftFrogBubble.y = 409;
			leftFrogBubble.visible = false;
			bubbles.push(leftFrogBubble);
			addChild(leftFrogBubble);
			
			// Adding right frog bubble
			var rightFrogBubble:right2_movieclip = new right2_movieclip();
			rightFrogBubble.gotoAndStop(1);
			rightFrogBubble.x = 185;
			rightFrogBubble.y = 418;
			rightFrogBubble.visible = false;
			bubbles.push(rightFrogBubble);			
			addChild(rightFrogBubble);	
			
			// Adding 3 x Kitty bubbles
			for (var i:uint=1; i<4; i++) {
				var kittyBubble:kittyBubble_movieclip = new kittyBubble_movieclip();				
				kittyBubble.gotoAndStop(i);
				kittyBubble.x = 580;
				kittyBubble.y = 317;
				kittyBubble.visible = false;				
				bubbles.push(kittyBubble);		
				addChild(kittyBubble);				
			}
			
			// Adding big bubble
			bigBubble = new bigBubble_movieclip();
			bigBubble.gotoAndStop(1);
			bigBubble.x = 349;
			bigBubble.y = 214;
			bigBubble.visible = false;			
			addChild(bigBubble);				

			addPlayButton();
		}
		
		private function addPlayButton() {
			var playButton:play_button_movieclip = new play_button_movieclip();
			playButton.x = 270;
			playButton.y = 270;			
			playButton.buttonMode = true;
			playButton.gotoAndStop(1);
			playButton.addEventListener(MouseEvent.MOUSE_OVER, onPlayButtonHover);
			playButton.addEventListener(MouseEvent.MOUSE_OUT, onPlayButtonOut);
			playButton.addEventListener(MouseEvent.CLICK, onPlayButtonClick);			
			addChild(playButton);			
		}
		
		private function addTiles() {
			var tiles:Array = new Array();
			
			// Create tiles
			for (var i:uint=0; i<NUMBER_OF_TILES; i++) {
				tiles.push(Math.floor(i/2));
			}

			// Shuffle tiles
			var swap:uint;
			var tmp:uint;
			for (i=NUMBER_OF_TILES-1; i>0; i--) {
				swap = Math.floor(Math.random() * i);
				tmp = tiles[i];
				tiles[i] = tiles[swap];
				tiles[swap] = tmp;
			}
			
			// Place tile gfx
			for (i=0; i<NUMBER_OF_TILES; i++) {
				var tile:tile_movieclip = new tile_movieclip();
				tile.cardType = tiles[i];
				var x:uint = BOARD_START_X + (TILE_SIZE + PX_BETWEEN_ROWS) * (i % TILES_PER_ROW);
				var y:uint = BOARD_START_Y + (TILE_SIZE + PX_BETWEEN_ROWS) * (Math.floor(i / TILES_PER_ROW));
				tile.x = x;
				tile.y = y;
				tile.gotoAndStop(NUMBER_OF_TILES/2+1);
				// Set hand when hover
				tile.buttonMode = true;
				tile.addEventListener(MouseEvent.CLICK, onTileClicked);	
				addChild(tile);
			}			
			
			tilesLeft = NUMBER_OF_TILES;
		}

		private function onPlayButtonHover(e:MouseEvent) {
			var button:play_button_movieclip = e.currentTarget as play_button_movieclip;
			button.gotoAndStop(2);
		}
		
		private function onPlayButtonOut(e:MouseEvent) {
			var button:play_button_movieclip = e.currentTarget as play_button_movieclip;
			button.gotoAndStop(1);
		}
		
		private function onPlayButtonClick(e:MouseEvent) {
			var button:play_button_movieclip = e.currentTarget as play_button_movieclip;
			button.removeEventListener(MouseEvent.MOUSE_OVER, onPlayButtonHover);
			button.removeEventListener(MouseEvent.MOUSE_OUT, onPlayButtonOut);
			button.removeEventListener(MouseEvent.CLICK, onPlayButtonClick);			
			removeChild(button);
			backgroundImage.gotoAndStop(2);
			addTiles();
		}
		
		private function showRandomBubble() {
			var random:uint = Math.random() * bubbles.length;
			bubbles[random].visible = true;			
		}
		
		private function onTileClicked(e:MouseEvent) {
			if (canPick) {
				var picked:tile_movieclip = e.currentTarget as tile_movieclip;
				// Checking if current tiles has already been picked
				if (pickedTiles.indexOf(picked) == -1) {
					pickedTiles.push(picked);
					picked.gotoAndStop(picked.cardType + 1);
				}
				// Checking if we picked 2 tiles
				if (pickedTiles.length == 2) {
					// So you can't cheat!
					canPick = false;
					// Pause XXX ms before removing tiles
					pauseGame = new Timer(850, 1);
					pauseGame.start();					
					// Remove tiles if match
					if (pickedTiles[0].cardType == pickedTiles[1].cardType) {
						showRandomBubble();
						tilesLeft -= 2;
						pauseGame.addEventListener(TimerEvent.TIMER_COMPLETE, removeTiles);
					} else {
						// Otherwise reset picked tiles after XXX ms
						pauseGame.addEventListener(TimerEvent.TIMER_COMPLETE, resetTiles);					
					}
				}
			}
		}
		
		private function maybeShowEnd() {
			if (tilesLeft == 0) {
				bigBubble.visible = true;
				// Show end 3 seconds, then show title screen and play button
				pauseGame = new Timer(3000, 1);
				pauseGame.start();					
				pauseGame.addEventListener(TimerEvent.TIMER_COMPLETE, resetGame);			
			}
		}
		
		private function resetGame(e:TimerEvent) {
			pauseGame.removeEventListener(TimerEvent.TIMER_COMPLETE, resetGame);
			// Show title screen
			backgroundImage.gotoAndStop(1);
			// Add play button again
			addPlayButton();
			// Hide end bubble
			bigBubble.visible = false;			
		}
		
		private function removeTiles(e:TimerEvent) {
			pauseGame.removeEventListener(TimerEvent.TIMER_COMPLETE, removeTiles);
			pickedTiles[0].removeEventListener(MouseEvent.CLICK, onTileClicked);
			pickedTiles[1].removeEventListener(MouseEvent.CLICK, onTileClicked);
			removeChild(pickedTiles[0]);
			removeChild(pickedTiles[1]);
			pickedTiles = new Array();
			canPick = true;
			// Hide all speech bubbles
			for (var i:uint=0; i<bubbles.length; i++) {
				bubbles[i].visible = false;
			}
			
			maybeShowEnd();
		}
		
		private function resetTiles(e:TimerEvent) {
			pauseGame.removeEventListener(TimerEvent.TIMER_COMPLETE, resetTiles);			
			pickedTiles[0].gotoAndStop(NUMBER_OF_TILES / 2 + 1);
			pickedTiles[1].gotoAndStop(NUMBER_OF_TILES / 2 + 1);
			pickedTiles = new Array();
			canPick = true;
		}		
	}
}