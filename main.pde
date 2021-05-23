// Libraries external
import ddf.minim.*;

// Record the screen property.
int[] screen_property = new int[] {displayWidth, displayHeight};

// Initialization globally
EnetityFactory eFactory;
ResourceLibraries rLibrary;
Minim minim;
SystemAI sysAI;
// Help document
Help help;
// Game properties
StartMenu sMenu;
InGameMenu iMenu;
Game game;
// Game statement
String currentBGM = "";
String currentBGS = "";
String topMenu = "";
// Game attributes
PVector focusing;   // Focusing position by user
PVector targeting; // Attack focusing position by user
boolean isTargetingVisiable, isUsingAI;    // The visibility of targeting
Player currentPlayer;   // Current playing player
// Concurrent flag
boolean aiInProgress;


// The set up function of the game
void setup() {
    // Predefine
    isUsingAI = true;
    isTargetingVisiable = false;
    // Initialize files
    minim = new Minim(this);
    eFactory = new EnetityFactory();
    rLibrary = new ResourceLibraries();
    // Initialize display content
    game = new Game();
    help = new Help();
    sMenu = new StartMenu();
    iMenu = new InGameMenu();
    //Initialize AI contents
    sysAI = new SystemAI();
    sysAI.reset();
    // Game properties initialization
    fullScreen(P2D);
    frameRate(60);
    // Game appearance attribute
    noCursor();
    this.currentBGM = "menu";
    this.aiInProgress = false;
    // DIsplay the start menu
    sMenu.display();
    // Debugger
    //println(eFactory.getCharacterMap().keySet());
}

// Draw for each movement
void draw() {
    background(255);
    sMenu.draw();
    iMenu.draw();
    game.draw();
    help.draw();
    if(frameCount % 30 == 0) {
        thread("useAI");
        thread("checkWinningCondition");
        thread("soundControl");
    }
}

void keyPressed() {
    //println(keyCode); //<>//
    sMenu.keyPressed();
    game.keyPressed();
    iMenu.keyPressed();
    help.keyPressed();
}

void keyReleased() {
    sMenu.keyReleased();
    game.keyReleased();
    iMenu.keyReleased();
    help.keyReleased();
}

// A new thread handles sound effect - By modifying the global variable soundProc and effectProc
// RLibrary will automatically handle the playing statement of the sound and effect
// Two aims: smoothly change the sound and effect / fasten game
// Considering the situation that BGM and BGS only play once
void soundControl() {
    switch (this.currentBGM) {
        case "menu": {
            rLibrary.playBGM("BGM_1_THM");
            break;
        }
        case "s1": {
            rLibrary.playBGM("BGM_5_THM");
            break;
        }
        case "s2": {
            rLibrary.playBGM("BGM_8_THM");
            break;
        }
        case "s3": {
            rLibrary.playBGM("BGM_2_THM");
            break;
        }
        case "s4": {
            rLibrary.playBGM("BGM_7_THM");
            break;
        }
        case "s5": {
            rLibrary.playBGM("BGM_10_THM");
            break;
        }
        case "bt1": {
            rLibrary.playBGM("BGM_0_BAT");
            break;
        }
        case "bt2": {
            rLibrary.playBGM("BGM_4_BAT");
            break;
        }
        case "bt3": {
            rLibrary.playBGM("BGM_6_BAT");
            break;
        }
        case "bt4": {
            rLibrary.playBGM("BGM_9_BAT");
            break;
        }
        case "fail": {
            rLibrary.playBGM("BGM_3_FAL");
            break;
        }
        default: {
            rLibrary.playBGM("");
            break;
        }
    }
    switch (this.currentBGS) {
        case "wt": {
            rLibrary.playBGS("BGS_1_windthunder");
            break;
        }
        case "w": {
            rLibrary.playBGS("BGS_0_wind");
            break;
        }
        default : {
            rLibrary.playBGS("");
            break;
        }
    }
}

void useAI() {
    if (aiInProgress == true) {
        return;
    }
    aiInProgress = true;
    // Pretend to be atom area
    if (currentPlayer != null) {
        if (isUsingAI) {
            if (currentPlayer.getPlayerName().equals("ai")) {
                sysAI.predictPlayerAI();
            }
        }
        if (currentPlayer.getPlayerName().equals("sys")) {
            sysAI.predictSysAI();
        }
    }
    aiInProgress = false;
}

// Three condition of winning: 1. Starvation; 2: Spawner is being destroyed; 3: Only one gender available
void checkWinningCondition() {
    if (currentPlayer != null && !aiInProgress) {
        game.checkWinningCondition();
    }
}
