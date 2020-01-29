// Copyright 2019 Google LLC. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

'use strict';

import {
  mediaJSON
} from './media.js';
import {
  breakClipsJSON,
  breaksJSON
} from './ads.js';

/* 
   2020.01.23 change if (debug_console_log) { console.log to only occur if "debug_console_log" is true\, eg  } ;
              if (debug_if (debug_console_log) { console_log) { if (debug_console_log) { console.log("something"); }; }; } ;
*/
const debug_console_log = false;
// const debug_console_log = true;

/** Cleaner UI for demo purposes. */
const DEMO_MODE = false;

/** @const {string} Media source root URL */
// const MEDIA_SOURCE_ROOT = 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/';
// superseded by putting the full URLs in media.js

/**
 * Controls if Ads are enabled. Controlled by radio button.
 * @type {boolean}
 */
let ENABLE_ADS = false;

/**
 * Controls if Live stream is played. Controlled by radio button.
 * @type {boolean}
 */
let ENABLE_LIVE = false;

/**
 * Buffer to decide if the live indicator should be displayed to show that
 * playback is at the playback head.
 * @const {number}
 */
const LIVE_INDICATOR_BUFFER = 50;

/**
 * Width of progress bar in pixels.
 * @const {number}
 */
 /* this MUST EXACTLY MATCH the value in CastVideos.js */
const PROGRESS_BAR_WIDTH = 380; /* const PROGRESS_BAR_WIDTH = 700; */

/**
 * Time in milliseconds for minimal progress update.
 * @const {number}
 */
const TIMER_STEP = 1000;

/**
 * Cast volume upon initial connection.
 * @const {number}
 */
const DEFAULT_VOLUME = 1.0; /* 0.5; */

/**
 * Height, in pixels, of volume bar.
 * @const {number}
 */
const FULL_VOLUME_HEIGHT = 100;

const standard_video_thumb = "http://10.0.0.6/Pi4CC/imagefiles/free-boat_02.jpg"
// const standard_video_thumb = "/Pi4CC/imagefiles/free-boat_02.jpg"


/** @enum {string} Constants of states for media for both local and remote playback */
const PLAYER_STATE = {
  // No media is loaded into the player. For remote playback, maps to
  // the PlayerState.IDLE state.
  IDLE: 'IDLE',
  // Player is in PLAY mode but not actively playing content. For remote
  // playback, maps to the PlayerState.BUFFERING state.
  BUFFERING: 'BUFFERING',
  // The media is loaded but not playing.
  LOADED: 'LOADED',
  // The media is playing. For remote playback, maps to the PlayerState.PLAYING state.
  PLAYING: 'PLAYING',
  // The media is paused. For remote playback, maps to the PlayerState.PAUSED state.
  PAUSED: 'PAUSED'
};

/**
 * Cast player object
 * Main variables:
 *  - PlayerHandler object for handling media playback
 *  - Cast player variables for controlling Cast mode media playback
 *  - Current media variables for transition between Cast and local modes
 *  - Current ad variables for controlling UI based on ad playback
 *  - Current live variables for controlling UI based on ad playback
 * @struct @constructor
 */
var CastPlayer = function () {
  /** @type {PlayerHandler} Delegation proxy for media playback */
  var dCP;
  var tCP;
  dCP = new Date();
  tCP = dCP.toLocaleTimeString();
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Entered CastPlayer') ; } ;
  this.playerHandler = new PlayerHandler(this);

  /** @type {PLAYER_STATE} A state for media playback */
  this.playerState = PLAYER_STATE.IDLE;

  /**
   * @type {PLAYER_STATE} Player state before switching between local and
   * remote playback.
   */
  this.playerStateBeforeSwitch = null;

  /* Cast player variables */
  /** @type {cast.framework.RemotePlayer} */
  this.remotePlayer = null;
  /** @type {cast.framework.RemotePlayerController} */
  this.remotePlayerController = null;

  /* Local+Remote player variables */
  /** @type {number} A number for current time in seconds. Maintained in media time. */
  this.currentMediaTime = 0;
  /**
   * @type {?number} A number for current duration in seconds. Maintained in media time.
   * Null if duration should not be shown.
   */
  this.mediaDuration = -1;

  /** @type {?number} A timer for tracking progress of media */
  this.timer = null;
  /** @type {function()} Listener for handling current time increments */
  this.incrementMediaTimeHandler = this.incrementMediaTime.bind(this);
  /** @type {function()} Listener to be added/removed for the seek action */
  this.seekMediaListener = this.seekMedia.bind(this);

  /* Local player variables */
  /** @type {number} A number for current media index */
  this.currentMediaIndex = 0;
  /** @type {?Object} media contents from JSON */
  this.mediaContents = null;
  /** @type {boolean} Fullscreen mode on/off */
  this.fullscreen = false;

  /* Remote Player variables */
  /** @type {?chrome.cast.media.MediaInfo} Current mediaInfo */
  this.mediaInfo = null;
  /* Ad variables */
  /**
   * @type {?number} The time in seconds when the break clip becomes skippable.
   * 5 means that the end user can skip this break clip after 5 seconds. If
   * negative or not defined, it means that the current break clip is not skippable.
   */
  this.whenSkippable = null;

  /* Live variables */
  /** @type {?chrome.cast.media.LiveSeekableRange} Seekable range for live content */
  this.liveSeekableRange = null;
  /** @type {boolean} Remote player is playing live content. */
  this.isLiveContent = false;

  this.setupLocalPlayer();
  // this.addVideoThumbs(); // don't load anything into the carousel, use a plain long list instead
  this.addVideoList();
  this.initializeUI();
  
  dCP = new Date();
  tCP = dCP.toLocaleTimeString();
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
  if (debug_console_log) { console.log(tCP + ' **********  Exiting CastPlayer') ; } ;
};

CastPlayer.prototype.initializeCastPlayer = function () {
  var diCP;
  var tiCP;
  diCP = new Date();
  tiCP = diCP.toLocaleTimeString();
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '>>--- Entered CastPlayer.prototype.initializeCastPlayer ') ; } ;
  var options = {};

  // Set the receiver application ID to your own (created in the
  // Google Cast Developer Console), or optionally
  // use the chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID
  // options.receiverApplicationId = '4662E592';    // custom styled receiver app for walshdcw@gmail.com (is the vanilla google receiver)
  options.receiverApplicationId = chrome.cast.media.DEFAULT_MEDIA_RECEIVER_APP_ID;

  // Auto join policy can be one of the following three:
  // ORIGIN_SCOPED - Auto connect from same appId and page origin
  // TAB_AND_ORIGIN_SCOPED - Auto connect from same appId, page origin, and tab
  // PAGE_SCOPED - No auto connect
  options.autoJoinPolicy = chrome.cast.AutoJoinPolicy.ORIGIN_SCOPED;

  cast.framework.CastContext.getInstance().setOptions(options);

  this.remotePlayer = new cast.framework.RemotePlayer();
  this.remotePlayerController = new cast.framework.RemotePlayerController(this.remotePlayer);
  this.remotePlayerController.addEventListener(
    cast.framework.RemotePlayerEventType.IS_CONNECTED_CHANGED,
    function (e) {
      if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.initializeCastPlayer inline function RemotePlayerEventType IS_CONNECTED_CHANGED to do switchPlayer'); } ;
      this.switchPlayer(e.value);
      if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.initializeCastPlayer inline function RemotePlayerEventType IS_CONNECTED_CHANGED to do switchPlayer'); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );
  diCP = new Date();
  tiCP = diCP.toLocaleTimeString();
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
  if (debug_console_log) { console.log(tiCP + '<<--- Exiting CastPlayer.prototype.initializeCastPlayer ') ; } ;
};

/**
 * Switch between the remote and local players.
 */
CastPlayer.prototype.switchPlayer = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.switchPlayer ') ; } ;
  this.playerStateBeforeSwitch = this.playerState;

  this.stopProgressTimer();
  this.resetVolumeSlider();

  // Session is active
  if (cast && cast.framework && this.remotePlayer.isConnected) {
    // Pause local playback
    this.playerHandler.pause();
    this.setupRemotePlayer();
  } else {
    this.setupLocalPlayer();
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.switchPlayer ') ; } ;
};

/**
 * PlayerHandler
 *
 * This is a handler through which the application will interact
 * with both the RemotePlayer and LocalPlayer. Combining these two into
 * one interface is one approach to the dual-player nature of a Cast
 * Chrome application. Otherwise, the state of the RemotePlayer can be
 * queried at any time to decide whether to interact with the local
 * or remote players.
 *
 * To set the player used, implement the following methods for a target object
 * and call setTarget(target).
 *
 * Methods to implement:
 *  - play()
 *  - pause()
 *  - stop()
 *  - seekTo(time)
 *  - load(mediaIndex)
 *  - isMediaLoaded(mediaIndex)
 *  - prepareToPlay()
 *  - getMediaDuration()
 *  - getCurrentMediaTime()
 *  - setVolume(volumeSliderPosition)
 *  - mute()
 *  - unMute()
 *  - isMuted()
 *  - updateDisplay()
 *  - updateCurrentTimeDisplay()
 *  - updateDurationDisplay()
 *  - setTimeString(element, time)
 */
var PlayerHandler = function (castPlayer) {
  var dPH;
  var tPH;
  dPH = new Date();
  tPH = dPH.toLocaleTimeString();
  if (debug_console_log) { console.log(tPH + ' ---------- Entered PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Entered PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Entered PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Entered PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Entered PlayerHandler') ; } ;
  this.target = {};

  this.setTarget = function (target) {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.setTarget ') ; } ;
    this.target = target;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.setTarget ') ; } ;
  };

  this.play = function () {
    if (debug_console_log) { console.log('>>--- ++++++++++++++++++++++++++++  Entered PlayerHandler.play ') ; } ;
    if (castPlayer.playerState == PLAYER_STATE.IDLE || !this.target.isMediaLoaded(castPlayer.currentMediaIndex)) {
      if (debug_console_log) { console.log('*** PlayerHandler.play ABOUT TO CALL this.load') ; } ;
      this.load(castPlayer.currentMediaIndex);
      if (debug_console_log) { console.log('*** PlayerHandler.play RETURNED FROM TO CALL this.load') ; } ;
      if (debug_console_log) { console.log('<< *** ++++++++++++++++++++++++++++ Exiting PlayerHandler.play after immediate INLINE CALL to this.load ') ; } ;
      return;
    } else {
      if (debug_console_log) { console.log('*** in PlayerHandler.play --- BYPASSED immediate INLINE CALL to this.load and continuing inside PlayerHandler.play') ; } ;
    }

    if (debug_console_log) { console.log('*** PlayerHandler.play about to set castPlayer.playerState = PLAYER_STATE.PLAYING') ; } ;
    castPlayer.playerState = PLAYER_STATE.PLAYING;
    if (debug_console_log) { console.log('*** PlayerHandler.play ABOUT TO CALL this.target.play') ; } ;
    this.target.play();
    if (debug_console_log) { console.log('*** PlayerHandler.play RETURNED FROM CALL this.target.play') ; } ;

    if (debug_console_log) { console.log('*** PlayerHandler.play about to set play button .style.display=none') ; } ;
    document.getElementById('play').style.display = 'none';
    if (debug_console_log) { console.log('*** PlayerHandler.play about to set pause button .style.display=block') ; } ;
    document.getElementById('pause').style.display = 'block';
    if (debug_console_log) { console.log('<< *** ++++++++++++++++++++++++++++Exiting PlayerHandler.play at end of function') ; } ;
  };

  this.pause = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.pause ') ; } ;
    this.target.pause();
    castPlayer.playerState = PLAYER_STATE.PAUSED;
    document.getElementById('play').style.display = 'block';
    document.getElementById('pause').style.display = 'none';
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.pause ') ; } ;
  };

  this.stop = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.stop ') ; } ;
    castPlayer.playerState = PLAYER_STATE.IDLE;
    this.target.stop();
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.stop ') ; } ;
  };

  this.load = function (mediaIndex = null) {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.load ') ; } ;
    if (!mediaIndex) {
      mediaIndex = castPlayer.currentMediaIndex;
    }
    castPlayer.playerState = PLAYER_STATE.BUFFERING;
    this.target.load(mediaIndex);
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.load ') ; } ;
  };

  /**
   * Check if media has been loaded on the target player.
   * @param {number?} mediaIndex The desired media index. If null, verify if
   *  any media is loaded.
   */
  this.isMediaLoaded = function (mediaIndex) {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.isMediaLoaded and about to return a value from the middle of it') ; } ;
    return this.target.isMediaLoaded(mediaIndex);
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.isMediaLoaded and returned a value from the middle of it') ; } ;
  };

  /**
   * Called after media has been successfully loaded and is ready to start playback.
   * When local, will start playing the video, start the timer, and update the UI.
   * When remote, will set the UI to PLAYING and start the timer to update the
   *   UI based on remote playback.
   */
  this.prepareToPlay = function () {
    if (debug_console_log) { console.log('>>================== Entered PlayerHandler.prepareToPlay ==================') ; } ;
    castPlayer.mediaDuration = this.getMediaDuration();
    castPlayer.playerHandler.updateDurationDisplay();
    castPlayer.playerState = PLAYER_STATE.LOADED;

    if (debug_console_log) { console.log('  ================== PlayerHandler.prepareToPlay ABOUT TO CALL this.play INSIDE prepareToPlay() ') ; } ;
    this.play();
    if (debug_console_log) { console.log('  ================== PlayerHandler.prepareToPlay ABOUT TO CALL startProgressTimer INSIDE prepareToPlay()') ; } ;
    castPlayer.startProgressTimer();
    if (debug_console_log) { console.log('  ================== PlayerHandler.prepareToPlay ABOUT TO CALL this.updateDisplay INSIDE prepareToPlay()') ; } ;
    this.updateDisplay();
    if (debug_console_log) { console.log('<<================== Exiting PlayerHandler.prepareToPlay ==================') ; } ;
  };

  this.getCurrentMediaTime = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.getCurrentMediaTime and about to return a value from the middle of it') ; } ;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.getCurrentMediaTime and returned a value from a function call the middle of it') ; } ;
    return this.target.getCurrentMediaTime();
  };

  this.getMediaDuration = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.getMediaDuration and about to return a value from the middle of it') ; } ;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.getMediaDuration and returned a value from a function call the middle of it') ; } ;
    return this.target.getMediaDuration();
  };

  this.updateDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.updateDisplay ') ; } ;
    // Update local variables
    this.currentMediaTime = this.target.getCurrentMediaTime();
    this.mediaDuration = this.target.getMediaDuration();

    this.target.updateDisplay();
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.updateDisplay ') ; } ;
  };

  this.updateCurrentTimeDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.updateCurrentTimeDisplay ') ; } ;
    this.target.updateCurrentTimeDisplay();
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.updateCurrentTimeDisplay ') ; } ;
  };

  this.updateDurationDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.updateDurationDisplay ') ; } ;
    this.target.updateDurationDisplay();
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.updateDurationDisplay ') ; } ;
  };

  /**
   * Determines the correct time string (media or clock) and sets it for the given element.
   */
  this.setTimeString = function (element, time) {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.setTimeString ') ; } ;
    this.target.setTimeString(element, time);
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.setTimeString ') ; } ;
  };

  this.setVolume = function (volumeSliderPosition) {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.setVolume ') ; } ;
    this.target.setVolume(volumeSliderPosition);
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.setVolume ') ; } ;
  };

  this.mute = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.mute ') ; } ;
    this.target.mute();
    document.getElementById('audio_on').style.display = 'none';
    document.getElementById('audio_off').style.display = 'block';
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.mute ') ; } ;
  };

  this.unMute = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.unMute ') ; } ;
    this.target.unMute();
    document.getElementById('audio_on').style.display = 'block';
    document.getElementById('audio_off').style.display = 'none';
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.unMute ') ; } ;
  };

  this.isMuted = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.isMuted and about to return a value from the middle of it')  } ;
    return this.target.isMuted();
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.isMuted and returned a value from the middle of it')  } ;
  };

  this.seekTo = function (time) {
    var dseekTo;
    var tseekTo;
    dseekTo = new Date();
    tseekTo = dseekTo.toLocaleTimeString();
    if (debug_console_log) { console.log(tseekTo + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.seekTo: ' + time) ; } ;
    if (debug_console_log) { console.log(tseekTo + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.seekTo: ' + time) ; } ;
    this.target.seekTo(time);
    dseekTo = new Date();
    tseekTo = dseekTo.toLocaleTimeString();
    if (debug_console_log) { console.log(tseekTo + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.seekTo: ' + time) ; } ;
    if (debug_console_log) { console.log(tseekTo + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.seekTo: ' + time) ; } ;
  };
// 2020.01.23 Try to add RW FF functionality into PlayerHandler
  this.FF_RW_seekTo = function (number_of_seconds) {
	var seekTime
    var dFFRW;
    var tFFRW;
	var x_number_of_seconds;
	x_number_of_seconds = number_of_seconds;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ===== Entered PlayerHandler this.FF_RW_seekTo: ' + number_of_seconds) ; } ;
    if (debug_console_log) { console.log(tFFRW + '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ===== Entered PlayerHandler this.FF_RW_seekTo: ' + number_of_seconds) ; } ;
    this.currentMediaTime = this.target.getCurrentMediaTime();
	if ((this.currentMediaTime + x_number_of_seconds) > this.mediaDuration) {x_number_of_seconds = this.mediaDuration - this.currentMediaTime};
	if ((this.currentMediaTime + x_number_of_seconds) < 0) {x_number_of_seconds = 0 - this.currentMediaTime};
    seekTime = parseInt(this.currentMediaTime + x_number_of_seconds);
    this.currentMediaTime = seekTime
    this.seekTo(seekTime)
    if (debug_console_log) { console.log(tFFRW + '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ===== Exiting PlayerHandler this.FF_RW_seekTo: ' + number_of_seconds) ; } ;
    if (debug_console_log) { console.log(tFFRW + '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ===== Exiting PlayerHandler this.FF_RW_seekTo: ' + number_of_seconds) ; } ;
  };
  this.RW_5 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_5: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_5: ') ; } ;
    this.FF_RW_seekTo(-5)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_5: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_5: ') ; } ;
  };
  this.RW_15 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_15: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_15: ') ; } ;
    this.FF_RW_seekTo(-15)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_15: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_15: ') ; } ;
  };
  this.RW_30 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_30: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_30: ') ; } ;
    this.FF_RW_seekTo(-30)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_30: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_30: ') ; } ;
  };
  this.RW_60 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_60: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_60: ') ; } ;
    this.FF_RW_seekTo(-60)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_60: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_60: ') ; } ;
  };
  this.RW_120 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_120: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_120: ') ; } ;
    this.FF_RW_seekTo(-120)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_120: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_120: ') ; } ;
  };
  this.RW_180 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_180: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.RW_180: ') ; } ;
    this.FF_RW_seekTo(-180)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_180: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.RW_180: ') ; } ;
  };
  //
  this.FF_5 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_5: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_5: ') ; } ;
    this.FF_RW_seekTo(5)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_5: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_5: ') ; } ;
  };
  this.FF_15 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_15: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_15: ') ; } ;
    this.FF_RW_seekTo(15)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_15: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_15: ') ; } ;
  };
  this.FF_30 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_30: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_30: ') ; } ;
    this.FF_RW_seekTo(30)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_30: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_30: ') ; } ;
  };
  this.FF_60 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_60: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_60: ') ; } ;
    this.FF_RW_seekTo(60)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_60: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_60: ') ; } ;
  };
  this.FF_120 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_120: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_120: ') ; } ;
    this.FF_RW_seekTo(120)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_120: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_120: ') ; } ;
  };
  this.FF_180 = function () {
    var dFFRW;
    var tFFRW;
    dFFRW = new Date();
    tFFRW = dFFRW.toLocaleTimeString();
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_180: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Entered PlayerHandler this.FF_180: ') ; } ;
    this.FF_RW_seekTo(180)
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_180: ') ; } ;
    if (debug_console_log) { console.log(tFFRW + '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ===== Exiting PlayerHandler this.FF_180: ') ; } ;
  };
  //
  dPH = new Date();
  tPH = dPH.toLocaleTimeString();
  if (debug_console_log) { console.log(tPH + ' ---------- Exiting PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Exiting PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Exiting PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Exiting PlayerHandler') ; } ;
  if (debug_console_log) { console.log(tPH + ' ---------- Exiting PlayerHandler') ; } ;
}; // end of 

/**
 * Set the PlayerHandler target to use the video-element player
 */
CastPlayer.prototype.setupLocalPlayer = function () {
  var dsLP;
  var tsLP;
  dsLP = new Date();
  tsLP = dsLP.toLocaleTimeString();
  if (debug_console_log) { console.log(tsLP + '----- Entered CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Entered CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Entered CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Entered CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Entered CastPlayer.prototype.setupLocalPlayer ') ; } ;
  // Cleanup remote player UI
  document.getElementById('live_indicator').style.display = 'none';
  this.removeAdMarkers();
  document.getElementById('skip').style.display = 'none';

  var localPlayer = document.getElementById('video_element');
  localPlayer.addEventListener(
    'loadeddata', this.onMediaLoadedLocally.bind(this));

  // This object will implement PlayerHandler callbacks with localPlayer
  var playerTarget = {};

  playerTarget.play = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.play ') ; } ;
    localPlayer.play();
    var vi = document.getElementById('video_image');
    vi.style.display = 'none';
    localPlayer.style.display = 'block';
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.play ') ; } ;
  };

  playerTarget.pause = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.pause ') ; } ;
    localPlayer.pause();
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.pause ') ; } ;
  };

  playerTarget.stop = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.stop ') ; } ;
    localPlayer.stop();
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.stop ') ; } ;
  };

  playerTarget.load = function (mediaIndex) {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.load ') ; } ;
    if (debug_console_log) { console.log('Inside CastPlayer.prototype.playerTarget.load - about to set localPlayer.src=' + encodeURI(this.mediaContents[mediaIndex]['sources'][0])) ; } ;
    localPlayer.src = encodeURI(this.mediaContents[mediaIndex]['sources'][0]);
    if (debug_console_log) { console.log('Inside CastPlayer.prototype.playerTarget.load - about to CALL localPlayer.load') ; } ;
    localPlayer.load();
    if (debug_console_log) { console.log('Inside CastPlayer.prototype.playerTarget.load - RETURNED from localPlayer.load call') ; } ;
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.load ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.isMediaLoaded = function (mediaIndex) {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.isMediaLoaded ') ; } ;
    if (!mediaIndex) {
      if (debug_console_log) { console.log('>> exiting CastPlayer.prototype.playerTarget.isMediaLoaded upon (!mediaIndex)') ; } ;
      return (localPlayer.src !== null && localPlayer.src !== "");
    } else {
      if (debug_console_log) { console.log('>> exiting CastPlayer.prototype.playerTarget.isMediaLoaded upon else from test (!mediaIndex)') ; } ;
      return (localPlayer.src == encodeURI(this.mediaContents[mediaIndex]['sources'][0]));
    }
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.isMediaLoaded normally at end') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.getCurrentMediaTime = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.getCurrentMediaTime and about to return a value from the middle of it') ; } ;
    return localPlayer.currentTime;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.getCurrentMediaTime and returned a value from the middle of it') ; } ;
  };

  playerTarget.getMediaDuration = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.getMediaDuration and about to return a value from the middle of it') ; } ;
    return localPlayer.duration;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.getMediaDuration and returned a value from the middle of it') ; } ;
  };

  playerTarget.updateDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.updateDisplay ') ; } ;
    // playerstate view
    document.getElementById('playerstate').style.display = 'none';
    document.getElementById('playerstatebg').style.display = 'none';
    document.getElementById('video_image_overlay').style.display = 'none';

    // media_info view
    document.getElementById('media_title').innerHTML =
      castPlayer.mediaContents[castPlayer.currentMediaIndex]['title'];
    document.getElementById('media_subtitle').innerHTML =
      castPlayer.mediaContents[castPlayer.currentMediaIndex]['subtitle'];
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.updateDisplay ') ; } ;
  };

  playerTarget.updateCurrentTimeDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.updateCurrentTimeDisplay ') ; } ;
    // Increment for local playback
    this.currentMediaTime += 1;
    this.playerHandler.setTimeString(document.getElementById('currentTime'), this.currentMediaTime);
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.updateCurrentTimeDisplay ') ; } ;
  }.bind(this);  // yes the .bind(this); is attached to the closing brace

  playerTarget.updateDurationDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.updateDurationDisplay ') ; } ;
    this.playerHandler.setTimeString(document.getElementById('duration'), this.mediaDuration);
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.updateDurationDisplay ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.setTimeString = function (element, time) {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.setTimeString ') ; } ;
    let currentTimeString = this.getMediaTimeString(time);
    if (currentTimeString !== null) {
      element.style.display = '';
      element.innerHTML = currentTimeString;
    } else {
      element.style.display = 'none';
    }
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.setTimeString ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.setVolume = function (volumeSliderPosition) {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.setVolume ') ; } ;
    localPlayer.volume = volumeSliderPosition < FULL_VOLUME_HEIGHT ?
      volumeSliderPosition / FULL_VOLUME_HEIGHT : 1;
    var p = document.getElementById('audio_bg_level');
    p.style.height = volumeSliderPosition + 'px';
    p.style.marginTop = -volumeSliderPosition + 'px';
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.setVolume ') ; } ;
  };

  playerTarget.mute = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.mute ') ; } ;
    localPlayer.muted = true;
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.mute ') ; } ;
  };

  playerTarget.unMute = function () {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.playerTarget.unMute ') ; } ;
    localPlayer.muted = false;
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.playerTarget.unMute ') ; } ;
  };

  playerTarget.isMuted = function () {
    if (debug_console_log) { console.log('>>--- Entered PlayerHandler.isMuted and about to return a value from the middle of it') ; } ;
    return localPlayer.muted;
    if (debug_console_log) { console.log('<< Exiting PlayerHandler.isMuted and about to return a value from the middle of it') ; } ;
  };

  playerTarget.seekTo = function (time) {
    var dseekTo;
    var tseekTo;
    dseekTo = new Date();
    tseekTo = dseekTo.toLocaleTimeString();
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Entered CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Entered CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Entered CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Entered CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Entered CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
    localPlayer.currentTime = time;
    dseekTo = new Date();
    tseekTo = dseekTo.toLocaleTimeString();
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Exiting CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Exiting CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Exiting CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Exiting CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
	if (debug_console_log) { console.log(tseekTo + '$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Exiting CastPlayer.prototype playerTarget.seekTo: ' + time) ; } ;
  };

  // Now undertake some actions
  
  this.playerHandler.setTarget(playerTarget);

  this.playerHandler.setVolume(DEFAULT_VOLUME * FULL_VOLUME_HEIGHT);

  this.showFullscreenButton();

  this.enableProgressBar(true);

  if (this.currentMediaTime > 0) {
    this.playerHandler.load();
    this.playerHandler.play();
  }
  dsLP = new Date();
  tsLP = dsLP.toLocaleTimeString();
  if (debug_console_log) { console.log(tsLP + '----- Exiting CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Exiting CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Exiting CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Exiting CastPlayer.prototype.setupLocalPlayer ') ; } ;
  if (debug_console_log) { console.log(tsLP + '----- Exiting CastPlayer.prototype.setupLocalPlayer ') ; } ;
};

/**
 * Set the PlayerHandler target to use the remote player
 * Add event listeners for player changes which may occur outside sender app.
 */
CastPlayer.prototype.setupRemotePlayer = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.setupRemotePlayer ') ; } ;
  // Triggers when the media info or the player state changes
  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.MEDIA_INFO_CHANGED, 
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function MEDIA_INFO_CHANGED '); } ;
      let session = cast.framework.CastContext.getInstance().getCurrentSession();
      if (!session) {
        this.mediaInfo = null;
        this.isLiveContent = false;
        this.playerHandler.updateDisplay();
        if (debug_console_log) { console.log('RETURNING from Inside remotePlayerController.addEventListener inline function MEDIA_INFO_CHANGED RETURNING upon (!session)'); } ;
        return;
      }

      let media = session.getMediaSession();
      if (!media) {
        this.mediaInfo = null;
        this.isLiveContent = false;
        this.playerHandler.updateDisplay();
        if (debug_console_log) { console.log('RETURNING from Inside remotePlayerController.addEventListener inline function MEDIA_INFO_CHANGED RETURNING upon (!media)'); } ;
        return;
      }

      this.mediaInfo = media.media;

      if (this.mediaInfo) {
        this.isLiveContent = (this.mediaInfo.streamType == chrome.cast.media.StreamType.LIVE);
      } else {
        this.isLiveContent = false;
      }

      if (media.playerState == PLAYER_STATE.PLAYING && this.playerState !== PLAYER_STATE.PLAYING) {
        if (debug_console_log) { console.log('inside remotePlayerController.addEventListener about to call prepareToPlay'); } ;
        this.playerHandler.prepareToPlay();
        if (debug_console_log) { console.log('inside remotePlayerController.addEventListener finished calling prepareToPlay'); } ;
      }

      this.removeAdMarkers();
      this.updateAdMarkers();

      this.playerHandler.updateDisplay();
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function MEDIA_INFO_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.CAN_SEEK_CHANGED, 
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function CAN_SEEK_CHANGED '); } ;
      this.enableProgressBar(event.value);
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function CAN_SEEK_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.IS_PAUSED_CHANGED, 
    function () {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function IS_PAUSED_CHANGED '); } ;
      if (this.remotePlayer.isPaused) {
        this.playerHandler.pause();
      } else if (this.playerState !== PLAYER_STATE.PLAYING) {
        // If currently not playing, start to play.
        // This occurs if starting to play from local, but this check is
        // required if the state is changed remotely.
        this.playerHandler.play();
      }
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function IS_PAUSED_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.IS_MUTED_CHANGED, 
    function () {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function IS_MUTED_CHANGED '); } ;
      if (this.remotePlayer.isMuted) {
        this.playerHandler.mute();
      } else {
        this.playerHandler.unMute();
      }
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function IS_MUTED_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.VOLUME_LEVEL_CHANGED,
    function () {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function VOLUME_LEVEL_CHANGED '); } ;
      var newVolume = this.remotePlayer.volumeLevel * FULL_VOLUME_HEIGHT;
      var p = document.getElementById('audio_bg_level');
      p.style.height = newVolume + 'px';
      p.style.marginTop = -newVolume + 'px';
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function VOLUME_LEVEL_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.IS_PLAYING_BREAK_CHANGED,
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function IS_PLAYING_BREAK_CHANGED '); } ;
      this.isPlayingBreak(event.value);
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function IS_PLAYING_BREAK_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener( cast.framework.RemotePlayerEventType.WHEN_SKIPPABLE_CHANGED,
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function WHEN_SKIPPABLE_CHANGED '); } ;
      this.onWhenSkippableChanged(event.value);
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function WHEN_SKIPPABLE_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.CURRENT_BREAK_CLIP_TIME_CHANGED,
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function CURRENT_BREAK_CLIP_TIME_CHANGED '); } ;
      this.onCurrentBreakClipTimeChanged(event.value);
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function CURRENT_BREAK_CLIP_TIME_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.BREAK_CLIP_ID_CHANGED,
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function BREAK_CLIP_ID_CHANGED '); } ;
      this.onBreakClipIdChanged(event.value);
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function BREAK_CLIP_ID_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  this.remotePlayerController.addEventListener(cast.framework.RemotePlayerEventType.LIVE_SEEKABLE_RANGE_CHANGED,
    function (event) {
      if (debug_console_log) { console.log('>>--- Entered remotePlayerController.addEventListener inline function LIVE_SEEKABLE_RANGE_CHANGED '); } ;
      if (debug_console_log) { console.log('LIVE_SEEKABLE_RANGE_CHANGED'); } ;
      this.liveSeekableRange = event.value;
      if (debug_console_log) { console.log('<< Exiting remotePlayerController.addEventListener inline function LIVE_SEEKABLE_RANGE_CHANGED '); } ;
    }.bind(this) // yes the .bind(this); is attached to the closing brace
  );

  // This object will implement PlayerHandler callbacks with
  // remotePlayerController, and makes necessary UI updates specific
  // to remote playback.
  var playerTarget = {};

  playerTarget.play = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.play ') ; } ;
    if (this.remotePlayer.isPaused) {
      this.remotePlayerController.playOrPause();
    }

    var vi = document.getElementById('video_image');
    vi.style.display = '';
    var localPlayer = document.getElementById('video_element');
    localPlayer.style.display = 'none';
    if (debug_console_log) { console.log('<< Exiting playerTarget.play ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.pause = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.pause ') ; } ;
    if (!this.remotePlayer.isPaused) {
      this.remotePlayerController.playOrPause();
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.pause ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.stop = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.stop ') ; } ;
    this.remotePlayerController.stop();
    if (debug_console_log) { console.log('<< Exiting playerTarget.stop ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  // Load request for local -> remote
  playerTarget.load = function (mediaIndex) {
    // if (debug_console_log) { console.log('>>--- Entered playerTarget.load ') ; } ;
    // if (debug_console_log) { console.log('Loading to cast: ' + this.mediaContents[mediaIndex]['title'] + ' : ' + encodeURI(this.mediaContents[mediaIndex]['sources'][0])); } ;

    let mediaInfo = new chrome.cast.media.MediaInfo(encodeURI(this.mediaContents[mediaIndex]['sources'][0]), 'video/mp4');
    mediaInfo.streamType = chrome.cast.media.StreamType.BUFFERED;
    mediaInfo.metadata = new chrome.cast.media.TvShowMediaMetadata();
    mediaInfo.metadata.title = this.mediaContents[mediaIndex]['title'];
    mediaInfo.metadata.subtitle = this.mediaContents[mediaIndex]['subtitle'];
    // { 'url': MEDIA_SOURCE_ROOT + this.mediaContents[mediaIndex]['thumb'] }
    if (this.mediaContents[mediaIndex]['thumb'] !== '') {
      mediaInfo.metadata.images = [ { 'url': this.mediaContents[mediaIndex]['thumb'] }];
      // if (debug_console_log) { console.log('Set video CAST LOAD thumbnail address to ' + this.mediaContents[mediaIndex]['thumb']); } ;
    } else {
      mediaInfo.metadata.images = [ { 'url': standard_video_thumb }];
      // if (debug_console_log) { console.log('Set video CAST LOAD thumbnail address to ' + standard_video_thumb); } ;
    }
      
    let request = new chrome.cast.media.LoadRequest(mediaInfo);
    request.currentTime = this.currentMediaTime;

    if (ENABLE_ADS) {
      // Add sample breaks and breakClips.
      mediaInfo.breakClips = breakClipsJSON;
      mediaInfo.breaks = breaksJSON;
    } else if (ENABLE_LIVE) {
      // Change the streamType and add live specific metadata.
      mediaInfo.streamType = chrome.cast.media.StreamType.LIVE;
      // TODO: Set the metadata on the receiver side in your implementation.
      // startAbsoluteTime and sectionStartTimeInMedia will be set for you.
      // See https://developers.google.com/cast/docs/caf_receiver/live.

      // TODO: Start time, is a fake timestamp. Use correct values for your implementation.
      let currentTime = new Date();
      // Convert from milliseconds to seconds.
      currentTime = currentTime / 1000;
      let sectionStartAbsoluteTime = currentTime;

      // Duration should be -1 for live streams.
      mediaInfo.duration = -1;
      // TODO: Set on the receiver for your implementation.
      mediaInfo.startAbsoluteTime = currentTime;
      mediaInfo.metadata.sectionStartAbsoluteTime = sectionStartAbsoluteTime;
      // TODO: Set on the receiver for your implementation.
      mediaInfo.metadata.sectionStartTimeInMedia = 0;
      mediaInfo.metadata.sectionDuration = this.mediaContents[mediaIndex]['duration'];

      let item = new chrome.cast.media.QueueItem(mediaInfo);
      request.queueData = new chrome.cast.media.QueueData();
      request.queueData.items = [item];
      request.queueData.name = "Sample Queue for Live";
    }

    // Do not immediately start playing if the player was previously PAUSED.
    if (!this.playerStateBeforeSwitch || this.playerStateBeforeSwitch == PLAYER_STATE.PAUSED) {
       request.autoplay = false;
       // if (debug_console_log) { console.log('playerTarget.load Set request.autoplay = false; ') ; } ;
    } else {
       request.autoplay = true;
       // if (debug_console_log) { console.log('playerTarget.load Set request.autoplay = true; ') ; /// set autoplay if not already paused } ;
    }

    cast.framework.CastContext.getInstance().getCurrentSession().loadMedia(request).then(
      function () {
        if (debug_console_log) { console.log('>>--- Entered cast.framework.CastContext.getInstance().getCurrentSession().loadMedia(request).then inline function ()'); } ;
        if (debug_console_log) { console.log('Remote media loaded ' + encodeURI(this.mediaContents[mediaIndex]['sources'][0]) ); } ;
        if (debug_console_log) { console.log('<< Exiting cast.framework.CastContext.getInstance().getCurrentSession().loadMedia(request).then inline function ()'); } ;
      }.bind(this), // yes the .bind(this); is attached to the closing brace
      function (errorCode) {
        if (debug_console_log) { console.log('>>--- Entered cast.framework.CastContext.getInstance().getCurrentSession().loadMedia(request).then inline function (errorCode)'); } ;
        this.playerState = PLAYER_STATE.IDLE;
        if (debug_console_log) { console.log('Remote media load error: ' + CastPlayer.getErrorMessage(errorCode)); } ;
        this.playerHandler.updateDisplay();
        if (debug_console_log) { console.log('>>--- Entered cast.framework.CastContext.getInstance().getCurrentSession().loadMedia(request).then inline function (errorCode)'); } ;
      }.bind(this)); // yes the .bind(this); is attached to the closing brace
    if (debug_console_log) { console.log('<< Exiting playerTarget.load ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.isMediaLoaded = function (mediaIndex) {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.isMediaLoaded ') ; } ;
    let session = cast.framework.CastContext.getInstance().getCurrentSession();
    if (!session) return false;

    let media = session.getMediaSession();
    if (!media) return false;

    if (media.playerState == PLAYER_STATE.IDLE) {
      return false;
    }

    // No need to verify local mediaIndex content.
    if (debug_console_log) { console.log('<< Exiting playerTarget.isMediaLoaded with true') ; } ;
    return true;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  /**
   * @return {number?} Current media time for the content. Always returns
   *      media time even if in clock time (conversion done when displaying).
   */
  playerTarget.getCurrentMediaTime = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.getCurrentMediaTime ') ; } ;
    if (this.isLiveContent && this.mediaInfo.metadata && this.mediaInfo.metadata.sectionStartTimeInMedia) {
      return this.remotePlayer.currentTime - this.mediaInfo.metadata.sectionStartTimeInMedia;
    } else {
      // VOD and live scenerios where live metadata is not provided.
      if (debug_console_log) { console.log('<< Exiting playerTarget.getCurrentMediaTime with currentTime') ; } ;
      return this.remotePlayer.currentTime;
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.getCurrentMediaTime ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  /**
   * @return {number?} media time duration for the content. Always returns
   *      media time even if in clock time (conversion done when displaying).
   */
  playerTarget.getMediaDuration = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.getMediaDuration ') ; } ;
    if (this.isLiveContent) {
      // Scenerios when live metadata is not provided.
      if (this.mediaInfo.metadata == undefined || this.mediaInfo.metadata.sectionDuration == undefined || this.mediaInfo.metadata.sectionStartTimeInMedia == undefined) {
        if (debug_console_log) { console.log('<< Exiting playerTarget.getMediaDuration with null') ; } ;
        return null;
      }
      if (debug_console_log) { console.log('<< Exiting playerTarget.getMediaDuration with sectionDuration') ; } ;
      return this.mediaInfo.metadata.sectionDuration;
    } else {
      if (debug_console_log) { console.log('<< Exiting playerTarget.getMediaDuration with duration') ; } ;
      return this.remotePlayer.duration;
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.getMediaDuration') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.updateDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.updateDisplay ') ; } ;
    let castSession = cast.framework.CastContext.getInstance().getCurrentSession();
    if (castSession && castSession.getMediaSession() && castSession.getMediaSession().media) {
      let media = castSession.getMediaSession();
      let mediaInfo = media.media;

      // image placeholder for video view
      var vi = document.getElementById('video_image');
      if (mediaInfo.metadata && mediaInfo.metadata.images && mediaInfo.metadata.images.length > 0) {
        vi.src = mediaInfo.metadata.images[0].url;
      }

      // playerstate view
      document.getElementById('playerstate').style.display = 'block';
      document.getElementById('playerstatebg').style.display = 'block';
      document.getElementById('video_image_overlay').style.display = 'block';

      let mediaTitle = '';
      let mediaEpisodeTitle = '';
      let mediaSubtitle = '';

      if (mediaInfo.metadata) {
        mediaTitle = mediaInfo.metadata.title;
        mediaEpisodeTitle = mediaInfo.metadata.episodeTitle;
        // Append episode title if present
        mediaTitle = mediaEpisodeTitle ? mediaTitle + ': ' + mediaEpisodeTitle : mediaTitle;
        // Do not display mediaTitle if not defined.
        mediaTitle = (mediaTitle) ? mediaTitle + ' ' : '';
        mediaSubtitle = mediaInfo.metadata.subtitle;
        mediaSubtitle = (mediaSubtitle) ? mediaSubtitle + ' ' : '';
      }

      if (DEMO_MODE) {
        document.getElementById('playerstate').innerHTML =
          (ENABLE_LIVE ? 'Live Content ' : 'Sample Video ') + media.playerState + ' on Chromecast';

        // media_info view
        document.getElementById('media_title').innerHTML = (ENABLE_LIVE ? 'Live Content' : 'Sample Video');
        document.getElementById('media_subtitle').innerHTML = '';
      } else {
        document.getElementById('playerstate').innerHTML =
          mediaTitle + media.playerState + ' on ' +
          castSession.getCastDevice().friendlyName;

        // media_info view
        document.getElementById('media_title').innerHTML = mediaTitle;
        document.getElementById('media_subtitle').innerHTML = mediaSubtitle;
      }

      // live information
      if (mediaInfo.streamType == chrome.cast.media.StreamType.LIVE) {
        this.liveSeekableRange = media.liveSeekableRange;

        let live_indicator = document.getElementById('live_indicator');
        live_indicator.style.display = 'block';

        // Display indicator if current time is close to the end of
        // the seekable range.
        if (this.liveSeekableRange && (Math.abs(media.getEstimatedTime() - this.liveSeekableRange.end) < LIVE_INDICATOR_BUFFER)) {
          live_indicator.src = "imagefiles/live_indicator_active.png";
        } else {
          live_indicator.src = "imagefiles/live_indicator_inactive.png";
        }
      } else {
        document.getElementById('live_indicator').style.display = 'none';
      }
    } else {
      // playerstate view
      document.getElementById('playerstate').style.display = 'none';
      document.getElementById('playerstatebg').style.display = 'none';
      document.getElementById('video_image_overlay').style.display = 'none';

      // media_info view
      document.getElementById('media_title').innerHTML = "";
      document.getElementById('media_subtitle').innerHTML = "";
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.updateDisplay ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.updateCurrentTimeDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.updateCurrentTimeDisplay ') ; } ;
    this.playerHandler.setTimeString(document.getElementById('currentTime'), this.playerHandler.getCurrentMediaTime());
    if (debug_console_log) { console.log('<< Exiting playerTarget.updateCurrentTimeDisplay ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.updateDurationDisplay = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.updateDurationDisplay ') ; } ;
    this.playerHandler.setTimeString(document.getElementById('duration'), this.playerHandler.getMediaDuration());
    if (debug_console_log) { console.log('<< Exiting playerTarget.updateDurationDisplay ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.setTimeString = function (element, time) {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.setTimeString ') ; } ;
    let currentTimeString = this.getMediaTimeString(time);

    if (this.isLiveContent) {
      if (currentTimeString == null) {
        element.style.display = 'none';
        return;
      }

      // clock time
      if (this.mediaInfo.metadata && this.mediaInfo.metadata.sectionStartAbsoluteTime !== undefined) {
        element.style.display = 'flex';
        element.innerHTML = this.getClockTimeString(time + this.mediaInfo.metadata.sectionStartAbsoluteTime);
      } else {
        // media time
        element.style.display = 'flex';
        element.innerHTML = currentTimeString;
      }
    } else {
      if (currentTimeString !== null) {
        element.style.display = 'flex';
        element.innerHTML = currentTimeString;
      } else {
        element.style.display = 'none';
      }
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.setTimeString ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.setVolume = function (volumeSliderPosition) {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.setVolume ') ; } ;
    var currentVolume = this.remotePlayer.volumeLevel;
    var p = document.getElementById('audio_bg_level');
    if (volumeSliderPosition < FULL_VOLUME_HEIGHT) {
      p.style.height = volumeSliderPosition + 'px';
      p.style.marginTop = -volumeSliderPosition + 'px';
      currentVolume = volumeSliderPosition / FULL_VOLUME_HEIGHT;
    } else {
      currentVolume = 1;
    }
    this.remotePlayer.volumeLevel = currentVolume;
    this.remotePlayerController.setVolumeLevel();
    if (debug_console_log) { console.log('<< Exiting playerTarget.setVolume ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.mute = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.mute ') ; } ;
    if (!this.remotePlayer.isMuted) {
      this.remotePlayerController.muteOrUnmute();
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.mute ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.unMute = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.unMute ') ; } ;
    if (this.remotePlayer.isMuted) {
      this.remotePlayerController.muteOrUnmute();
    }
    if (debug_console_log) { console.log('<< Exiting playerTarget.unMute ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.isMuted = function () {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.isMuted ') ; } ;
    if (debug_console_log) { console.log('<< Exiting playerTarget.isMuted with value remotePlayer.isMuted') ; } ;
    return this.remotePlayer.isMuted;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  playerTarget.seekTo = function (time) {
    if (debug_console_log) { console.log('>>--- Entered playerTarget.seekTo ') ; } ;
    this.remotePlayer.currentTime = time;
    this.remotePlayerController.seek();
    if (debug_console_log) { console.log('<< Exiting playerTarget.seekTo ') ; } ;
  }.bind(this); // yes the .bind(this); is attached to the closing brace

  // -------------------------------------------------------------------
  // the action statements start here for playerTarget
  this.playerHandler.setTarget(playerTarget);

  // Setup remote player properties on setup
  if (this.remotePlayer.isMuted) {
    this.playerHandler.mute();
  }
  this.enableProgressBar(this.remotePlayer.canSeek);
  // The remote player may have had a volume set from previous playback
  var currentVolume = this.remotePlayer.volumeLevel * FULL_VOLUME_HEIGHT;
  var p = document.getElementById('audio_bg_level');
  p.style.height = currentVolume + 'px';
  p.style.marginTop = -currentVolume + 'px';

  // Show media_control
  document.getElementById('media_control').style.opacity = 0.7;

  this.hideFullscreenButton();

  // If resuming a session, take the remote properties and continue the existing
  // playback. Otherwise, load local content.
  if (cast.framework.CastContext.getInstance().getCurrentSession().getSessionState() == cast.framework.SessionState.SESSION_RESUMED) {
    if (debug_console_log) { console.log('Resuming session'); } ;
    this.playerHandler.prepareToPlay();

    // New media has been loaded so the previous ad markers should
    // be removed.
    this.removeAdMarkers();
    this.updateAdMarkers();
  } else {
    this.playerHandler.load();
  }
};

/**
 * Callback when media is loaded in local player
 */
CastPlayer.prototype.onMediaLoadedLocally = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.onMediaLoadedLocally ') ; } ;
  var localPlayer = document.getElementById('video_element');
  localPlayer.currentTime = this.currentMediaTime;

  if (debug_console_log) { console.log('CastPlayer.prototype.onMediaLoadedLocally ABOUT TO CALL this.playerHandler.prepareToPlay') ; } ;
  this.playerHandler.prepareToPlay();
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.onMediaLoadedLocally ') ; } ;
};

/* ------------------------------------------------------------------------------------------------------------------------------------------ */
/**
 * Select a media content
 * @param {number} mediaIndex A number for media index
 */
CastPlayer.prototype.selectMedia = function (mediaIndex) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.selectMedia with mediaIndex=' + mediaIndex); } ;

  window.scrollTo({ top: 0, behavior: 'smooth' }); // scroll to the top of the page "smoothly"
  // window.scrollTo(0, 0); // scroll to the top of the page
  // window.scrollTo(0, document.body.scrollHeight); // scroll to bottom of page
  
  this.currentMediaIndex = mediaIndex;
  // Clear currentMediaInfo when playing content from the sender.
  this.playerHandler.currentMediaInfo = undefined;

  // Set video image (thumbnail)
  var vi = document.getElementById('video_image');
  if (this.mediaContents[mediaIndex]['thumb'] !== '') {
    vi.src = this.mediaContents[mediaIndex]['thumb'];
  // vi.src = MEDIA_SOURCE_ROOT + this.mediaContents[mediaIndex]['thumb'];
    if (debug_console_log) { console.log('this.mediaContents[mediaIndex] Set this.mediaContents[mediaIndex] thumbnail address to ' + this.mediaContents[mediaIndex]['thumb']); } ;
  } else {
    vi.src = standard_video_thumb;
    if (debug_console_log) { console.log('this.mediaContents[mediaIndex] Set this.mediaContents[mediaIndex] thumbnail address to ' + standard_video_thumb); } ;
  }

  // Reset progress bar
  var pi = document.getElementById('progress_indicator');
  pi.style.marginLeft = '0px';
  var progress = document.getElementById('progress');
  progress.style.width = '0px';

  let seekable_window = document.getElementById('seekable_window');
  let unseekable_overlay = document.getElementById('unseekable_overlay');
  seekable_window.style.width = PROGRESS_BAR_WIDTH;
  unseekable_overlay.style.width = '0px';

  // Stop timer and reset time displays
  if (debug_console_log) { console.log('this.mediaContents[mediaIndex] ABOUT TO CALL stopProgressTimer'); } ;
  this.stopProgressTimer();
  if (debug_console_log) { console.log('this.mediaContents[mediaIndex] about to reset currentMediaTime'); } ;
  this.currentMediaTime = 0;
  this.playerHandler.setTimeString(document.getElementById('currentTime'), 0);
  this.playerHandler.setTimeString(document.getElementById('duration'), 0);

  if (debug_console_log) { console.log('this.mediaContents[mediaIndex] about to set playerState = PLAYER_STATE.IDLE'); } ;
  this.playerState = PLAYER_STATE.IDLE;
  if (debug_console_log) { console.log('this.mediaContents[mediaIndex] ABOUT TO CALL playerHandler.play()'); } ;
  this.playerHandler.play(); // commenting this line out stops autoplay, but does not load the thumbnail or title etc
  // if (debug_console_log) { console.log('In selectMedia, pausing using playerHandler.pause()'); } ;
  // this.playerHandler.pause(); // lets see if adding this line causes it to pause immediately, therefore not autoplaying
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.selectMedia'); } ;
};
/* ------------------------------------------------------------------------------------------------------------------------------------------ */

/**
 * Media seek function
 * @param {Event} event An event object from seek
 */
CastPlayer.prototype.seekMedia = function (event) {
  var dpsM;
  var tpsM;
  dpsM = new Date();
  tpsM = dpsM.toLocaleTimeString();
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Entered CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Entered CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Entered CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Entered CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Entered CastPlayer.prototype.seekMedia')  ; } ;
  if (this.mediaDuration == null || (cast.framework.CastContext.getInstance().getCurrentSession() && !this.remotePlayer.canSeek)) {
    if (debug_console_log) { console.log('Error - Not seekable'); } ;
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.seekMedia upon error not seekable')  ; } ;
    return;
  }

  if (this.isLiveContent && !this.liveSeekableRange) {
    if (debug_console_log) { console.log('Live content has no seekable range.'); } ;
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.seekMedia upon error no seekable range') ; } ;
    return;
  }

  var position = parseInt(event.offsetX, 10);
  var pi = document.getElementById('progress_indicator');
  var progress = document.getElementById('progress');
  let seekTime = 0;
  let pp = 0;
  let pw = 0;
  if (event.currentTarget.id == 'progress_indicator') {
    seekTime = parseInt(this.currentMediaTime + this.mediaDuration * position / PROGRESS_BAR_WIDTH, 10);
    pp = parseInt(pi.style.marginLeft, 10) + position;
    pw = parseInt(progress.style.width, 10) + position;
  } else {
    seekTime = parseInt(position * this.mediaDuration / PROGRESS_BAR_WIDTH, 10);
    pp = position;
    pw = position;
  }

  if (this.playerState === PLAYER_STATE.PLAYING ||
    this.playerState === PLAYER_STATE.PAUSED) {
    this.currentMediaTime = seekTime;
    progress.style.width = pw + 'px';
    pi.style.marginLeft = pp + 'px';
  }

  if (this.isLiveContent) {
    seekTime += this.mediaInfo.metadata.sectionStartTimeInMedia;
  }

  this.playerHandler.seekTo(seekTime);
  dpsM = new Date();
  tpsM = dpsM.toLocaleTimeString();
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Exiting CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Exiting CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Exiting CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Exiting CastPlayer.prototype.seekMedia')  ; } ;
  if (debug_console_log) { console.log(tpsM + '@@@@@@@@@@@@@@@@ Exiting CastPlayer.prototype.seekMedia')  ; } ;
};

/**
 * Set current player volume
 * @param {Event} mouseEvent
 */
CastPlayer.prototype.setVolume = function (mouseEvent) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.setVolume')  ; } ;
  var p = document.getElementById('audio_bg_level');
  var pos = 0;
  if (mouseEvent.currentTarget.id === 'audio_bg_track') {
    pos = FULL_VOLUME_HEIGHT - parseInt(mouseEvent.offsetY, 10);
  } else {
    pos = parseInt(p.clientHeight, 10) - parseInt(mouseEvent.offsetY, 10);
  }
  this.playerHandler.setVolume(pos);
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.setVolume') ; } ;
};

/**
 * Starts the timer to increment the media progress bar
 */
CastPlayer.prototype.startProgressTimer = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.startProgressTimer')  ; } ;
  this.stopProgressTimer();

  // Start progress timer
  this.timer = setInterval(this.incrementMediaTimeHandler, TIMER_STEP);
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.startProgressTimer')  ; } ;
};

/**
 * Stops the timer to increment the media progress bar
 */
CastPlayer.prototype.stopProgressTimer = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.stopProgressTimer')  ; } ;
  if (this.timer) {
    clearInterval(this.timer);
    this.timer = null;
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.stopProgressTimer')  ; } ;
};

/**
 * Increment media current time depending on remote or local playback
 */
CastPlayer.prototype.incrementMediaTime = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.incrementMediaTime')  ; } ;
  // First sync with the current player's time
  this.currentMediaTime = this.playerHandler.getCurrentMediaTime();
  this.mediaDuration = this.playerHandler.getMediaDuration();

  this.playerHandler.updateDurationDisplay();

  if (this.mediaDuration == null || this.currentMediaTime < this.mediaDuration || this.isLiveContent) {
    this.playerHandler.updateCurrentTimeDisplay();
    this.updateProgressBarByTimer();
  } else if (this.mediaDuration > 0) {
    this.endPlayback();
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.incrementMediaTime')  ; } ;
};

/**
 * Update progress bar and currentTime based on timer
 */
CastPlayer.prototype.updateProgressBarByTimer = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.updateProgressBarByTimer')  ; } ;
  var progressBar = document.getElementById('progress');
  var pi = document.getElementById('progress_indicator');

  // Live situation where the progress and duration is unknown.
  if (this.mediaDuration == null) {
    if (!this.isLiveContent) {
      if (debug_console_log) { console.log('Error - Duration is not defined for a VOD stream.'); } ;
    }

    progressBar.style.width = '0px';
    document.getElementById('skip').style.display = 'none';
    pi.style.display = 'none';

    let seekable_window = document.getElementById('seekable_window');
    let unseekable_overlay = document.getElementById('unseekable_overlay');
    seekable_window.style.width = '0px';
    unseekable_overlay.style.width = '0px';
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateProgressBarByTime with media duration = null')  ; } ;
    return;
  } else {
    pi.style.display = '';
  }

  if (isNaN(parseInt(progressBar.style.width, 10))) {
    progressBar.style.width = '0px';
  }

  // Prevent indicator from exceeding the max width. Happens during
  // short media when each progress step is large
  var pp = Math.floor(PROGRESS_BAR_WIDTH * this.currentMediaTime / this.mediaDuration);
  if (pp > PROGRESS_BAR_WIDTH) {
    pp = PROGRESS_BAR_WIDTH;
  } else if (pp < 0) {
    pp = 0;
  }

  progressBar.style.width = pp + 'px';
  pi.style.marginLeft = pp + 'px';

  let seekable_window = document.getElementById('seekable_window');
  let unseekable_overlay = document.getElementById('unseekable_overlay');
  if (this.isLiveContent) {
    if (this.liveSeekableRange) {
      // Use the liveSeekableRange to draw the seekable and unseekable windows
      let seekableMediaPosition = Math.max(this.mediaInfo.metadata.sectionStartTimeInMedia, this.liveSeekableRange.end) -
        this.mediaInfo.metadata.sectionStartTimeInMedia;
      let seekableWidth = Math.floor(PROGRESS_BAR_WIDTH * seekableMediaPosition / this.mediaDuration);
      if (seekableWidth > PROGRESS_BAR_WIDTH) {
        seekableWidth = PROGRESS_BAR_WIDTH;
      } else if (seekableWidth < 0) {
        seekableWidth = 0;
      }
      seekable_window.style.width = seekableWidth + 'px';

      let unseekableMediaPosition = Math.max(this.mediaInfo.metadata.sectionStartTimeInMedia, this.liveSeekableRange.start) -
        this.mediaInfo.metadata.sectionStartTimeInMedia;
      let unseekableWidth = Math.floor(PROGRESS_BAR_WIDTH * unseekableMediaPosition / this.mediaDuration);
      if (unseekableWidth > PROGRESS_BAR_WIDTH) {
        unseekableWidth = PROGRESS_BAR_WIDTH;
      } else if (unseekableWidth < 0) {
        unseekableWidth = 0;
      }
      unseekable_overlay.style.width = unseekableWidth + 'px';
    } else {
      // Nothing is seekable if no liveSeekableRange
      seekable_window.style.width = '0px';
      unseekable_overlay.style.width = PROGRESS_BAR_WIDTH + 'px';
    }
  } else {
    // Default to everything seekable
    seekable_window.style.width = PROGRESS_BAR_WIDTH + 'px';
    unseekable_overlay.style.width = '0px';
  }

  if (pp >= PROGRESS_BAR_WIDTH && !this.isLiveContent) {
    this.endPlayback();
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateProgressBarByTimer')  ; } ;
};

/**
 *  End playback. Called when media ends.
 */
CastPlayer.prototype.endPlayback = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.endPlayback')  ; } ;
  this.currentMediaTime = 0;
  this.stopProgressTimer();
  this.playerState = PLAYER_STATE.IDLE;
  this.playerHandler.updateDisplay();

  document.getElementById('play').style.display = 'block';
  document.getElementById('pause').style.display = 'none';
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.endPlayback')  ; } ;
};

/**
 * @param {?number} timestamp Linux timestamp
 * @return {?string} media time string. Null if time is invalid.
 */
CastPlayer.prototype.getMediaTimeString = function (timestamp) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.getMediaTimeString')  ; } ;
  if (timestamp == undefined || timestamp == null) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.getMediaTimeString with returnvalue null')  ; } ;
    return null;
  }

  let isNegative = false;
  if (timestamp < 0) {
    isNegative = true;
    timestamp *= -1;
  }

  let hours = Math.floor(timestamp / 3600);
  let minutes = Math.floor((timestamp - (hours * 3600)) / 60);
  let seconds = Math.floor(timestamp - (hours * 3600) - (minutes * 60));

  if (hours < 10) hours = '0' + hours;
  if (minutes < 10) minutes = '0' + minutes;
  if (seconds < 10) seconds = '0' + seconds;

  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.getMediaTimeString with returnvalue nhours,mins,secs')  ; } ;
  return (isNegative ? '-' : '') + hours + ':' + minutes + ':' + seconds;
};

/**
 * @param {number} timestamp Linux timestamp
 * @return {?string} ClockTime string. Null if time is invalid.
 */
CastPlayer.prototype.getClockTimeString = function (timestamp) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.getClockTimeString')  ; } ;
  if (!timestamp) {
    if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.getClockTimeString with return value 0:00:00')  ; } ;
    return "0:00:00";
  }
  
  let date = new Date(timestamp * 1000);
  let hours = date.getHours();
  let minutes = date.getMinutes();
  let seconds = date.getSeconds();
  let ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  // Hour '0' should be '12'
  hours = hours ? hours : 12;
  minutes = ('0' + minutes).slice(-2);
  seconds = ('0' + seconds).slice(-2);
  let clockTime = hours + ':' + minutes + ':' + seconds + ' ' + ampm;
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.getClockTimeString with return value clockTime')  ; } ;
  return clockTime;
};

/**
 * Updates Ad markers in UI
 */
CastPlayer.prototype.updateAdMarkers = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.updateAdMarkers')  ; } ;
  let castSession = cast.framework.CastContext.getInstance().getCurrentSession();
  if (!castSession) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateAdMarkers due to !castSession')  ; } ;
    return;
  }

  let media = castSession.getMediaSession();
  if (!media){
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateAdMarkers due to !media')  ; } ;
    return;
  }

  let mediaInfo = media.media;
  if (!mediaInfo) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateAdMarkers due to !mediaInfo')  ; } ;
    return;
  }

  let breaks = mediaInfo.breaks;
  let contentDuration = mediaInfo.duration;

  if (!breaks) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateAdMarkers due to !breaks')  ; } ;
    return;
  }

  for (var i = 0; i < breaks.length; i++) {
    let adBreak = breaks[i];

    // Server-side stitched Ads (embedded) are skipped when the position is beyond
    // the duration, so they shouldn't be shown with an ad marker on the UI.
    if (adBreak.position > contentDuration && adBreak.isEmbedded) {
      continue;
    }

    // Place marker if not already set in position
    if (!document.getElementById('ad' + adBreak.position)) {
      var div = document.getElementById('progress')
      div.innerHTML += '<div class="adMarker" id="ad' + adBreak.position +
        '" style="margin-left: ' +
        this.adPositionToMargin(adBreak.position, contentDuration) + 'px"></div>';
    }
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.updateAdMarkers')  ; } ;
};

/**
 * Remove Ad markers in UI
 */
CastPlayer.prototype.removeAdMarkers = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.removeAdMarkers')  ; } ;
  document.querySelectorAll('.adMarker').forEach(function (adMarker) {
    adMarker.remove();
  });
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.removeAdMarkers')  ; } ;
};

/**
 * Position of the ad marker from the margin
 */
CastPlayer.prototype.adPositionToMargin = function (position, contentDuration) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.adPositionToMargin')  ; } ;
  // Post-roll
  if (position == -1) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.adPositionToMargin with value position==-1 PROGRESS_BAR_WIDTH')  ; } ;
    return PROGRESS_BAR_WIDTH;
  }

  // Client stitched Ads (not embedded) beyond the duration, will play at the
  // end of the content.
  if (position > contentDuration) {
    if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.adPositionToMargin with value position > contentDuration PROGRESS_BAR_WIDTH')  ; } ;
    return PROGRESS_BAR_WIDTH;
  }

  // Convert Ad position to margin
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.adPositionToMargin with value (PROGRESS_BAR_WIDTH * position) / contentDuration')  ; } ;
  return (PROGRESS_BAR_WIDTH * position) / contentDuration;
};

/**
 * Handle BREAK_CLIP_ID_CHANGED event
 */
CastPlayer.prototype.onBreakClipIdChanged = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.onBreakClipIdChanged')  ; } ;
  // Hide skip button when switching to a new breakClip
  document.getElementById('skip').style.display = 'none';
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.onBreakClipIdChanged')  ; } ;
};

/**
 * Disable progress bar if playing a break.
 */
CastPlayer.prototype.isPlayingBreak = function (isPlayingBreak) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.isPlayingBreak')  ; } ;
  this.enableProgressBar(!isPlayingBreak);
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.isPlayingBreak')  ; } ;
};

/**
 * Handle WHEN_SKIPPABLE_CHANGED event
 */
CastPlayer.prototype.onWhenSkippableChanged = function (whenSkippable) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.onWhenSkippableChanged')  ; } ;
  this.whenSkippable = whenSkippable;
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.onWhenSkippableChanged')  ; } ;
};

/**
 * Handle CURRENT_BREAK_CLIP_TIME_CHANGED event
 */
CastPlayer.prototype.onCurrentBreakClipTimeChanged = function (currentBreakClipTime) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.onCurrentBreakClipTimeChanged')  ; } ;
  // Unskippable
  if (this.whenSkippable == undefined || this.whenSkippable < 0) {
    // Hide skip button
    document.getElementById('skip').style.display = 'none';
  }
  // Skippable
  else if (this.whenSkippable !== undefined || currentBreakClipTime >= this.whenSkippable) {
    // Show skip button
    document.getElementById('skip').style.display = 'block';
  }
  // Not ready to be skipped
  else {
    // Hide skip button
    document.getElementById('skip').style.display = 'none';
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.onCurrentBreakClipTimeChanged')  ; } ;
};

/**
 * Skip the current Ad
 */
CastPlayer.prototype.skipAd = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.skipAd')  ; } ;
  this.remotePlayerController.skipAd();
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.skipAd')  ; } ;
}

/**
 * Enable/disable progress bar
 */
CastPlayer.prototype.enableProgressBar = function (enable) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.enableProgressBar')  ; } ;
  let progress = document.getElementById('progress');
  let progress_indicator = document.getElementById('progress_indicator');
  let seekable_window = document.getElementById('seekable_window');

  if (enable) {
    // Enable UI
    progress.style.backgroundImage = "url('./imagefiles/timeline_bg_progress.png')";
    progress.style.cursor = "pointer";
    seekable_window.style.cursor = "pointer";
    progress_indicator.style.cursor = "pointer";
    progress_indicator.draggable = true;

    // Add listeners
    progress.addEventListener('click', this.seekMediaListener);
    seekable_window.addEventListener('click', this.seekMediaListener);
    progress_indicator.addEventListener('dragend', this.seekMediaListener);
  } else {
    // Disable UI
    progress.style.backgroundImage = "url('./imagefiles/timeline_bg_buffer.png')";
    progress.style.cursor = "default";
    seekable_window.style.cursor = "default";
    progress_indicator.style.cursor = "default";
    progress_indicator.draggable = false;

    // Remove listeners
    progress.removeEventListener('click', this.seekMediaListener);
    seekable_window.removeEventListener('click', this.seekMediaListener);
    progress_indicator.removeEventListener('dragend', this.seekMediaListener);
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.enableProgressBar')  ; } ;
}

/**
 * Request full screen mode
 */
CastPlayer.prototype.requestFullScreen = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.requestFullScreen')  ; } ;
  // Supports most browsers and their versions
  var element = document.getElementById('video_element');
  var requestMethod =
    element['requestFullScreen'] || element['webkitRequestFullScreen'];

  if (requestMethod) {
    // Native full screen.
    requestMethod.call(element);
    if (debug_console_log) { console.log('Requested fullscreen'); } ;
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.requestFullScreen')  ; } ;
};

/**
 * Exit full screen mode
 */
CastPlayer.prototype.cancelFullScreen = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.cancelFullScreen')  ; } ;
  // Supports most browsers and their versions.
  var requestMethod =
    document['cancelFullScreen'] || document['webkitCancelFullScreen'];

  if (requestMethod) {
    requestMethod.call(document);
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.cancelFullScreen')  ; } ;
};

/**
 * Exit fullscreen mode by escape
 */
CastPlayer.prototype.fullscreenChangeHandler = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.fullscreenChangeHandler')  ; } ;
  this.fullscreen = !this.fullscreen;
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.fullscreenChangeHandler')  ; } ;
};

/**
 * Show expand/collapse fullscreen button
 */
CastPlayer.prototype.showFullscreenButton = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.showFullscreenButton')  ; } ;
  if (this.fullscreen) {
    document.getElementById('fullscreen_expand').style.display = 'none';
    document.getElementById('fullscreen_collapse').style.display = 'block';
  } else {
    document.getElementById('fullscreen_expand').style.display = 'block';
    document.getElementById('fullscreen_collapse').style.display = 'none';
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.showFullscreenButton')  ; } ;
};

/**
 * Hide expand/collapse fullscreen button
 */
CastPlayer.prototype.hideFullscreenButton = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.showFullscreenButton')  ; } ;
  document.getElementById('fullscreen_expand').style.display = 'none';
  document.getElementById('fullscreen_collapse').style.display = 'none';
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.showFullscreenButton')  ; } ;
};

/**
 * Show the media control
 */
CastPlayer.prototype.showMediaControl = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.showMediaControl')  ; } ;
  document.getElementById('media_control').style.opacity = 0.7;
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.showMediaControl')  ; } ;
};

/**
 * Hide the media control
 */
CastPlayer.prototype.hideMediaControl = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.hideMediaControl')  ; } ;
  let context = cast.framework.CastContext.getInstance();
  if (context && context.getCurrentSession()) {
    // Do not hide controls during an active cast session.
    document.getElementById('media_control').style.opacity = 0.7;
  } else {
    document.getElementById('media_control').style.opacity = 0;
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.hideMediaControl')  ; } ;
};

/**
 * Show the volume slider
 */
CastPlayer.prototype.showVolumeSlider = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.showVolumeSlider')  ; } ;
  if (!this.playerHandler.isMuted()) {
    document.getElementById('audio_bg').style.opacity = 1;
    document.getElementById('audio_bg_track').style.opacity = 1;
    document.getElementById('audio_bg_level').style.opacity = 1;
    document.getElementById('audio_indicator').style.opacity = 1;
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.showVolumeSlider')  ; } ;
};

/**
 * Hide the volume slider
 */
CastPlayer.prototype.hideVolumeSlider = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.hideVolumeSlider')  ; } ;
  document.getElementById('audio_bg').style.opacity = 0;
  document.getElementById('audio_bg_track').style.opacity = 0;
  document.getElementById('audio_bg_level').style.opacity = 0;
  document.getElementById('audio_indicator').style.opacity = 0;
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.hideVolumeSlider')  ; } ;
};

/**
 * Reset the volume slider
 */
CastPlayer.prototype.resetVolumeSlider = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.resetVolumeSlider')  ; } ;
  var volumeTrackHeight = document.getElementById('audio_bg_track').clientHeight;
  var defaultVolumeSliderHeight = DEFAULT_VOLUME * volumeTrackHeight;
  document.getElementById('audio_bg_level').style.height =
    defaultVolumeSliderHeight + 'px';
  document.getElementById('audio_on').style.display = 'block';
  document.getElementById('audio_off').style.display = 'none';
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.resetVolumeSlider')  ; } ;
};

/**
 * Initialize UI components and add event listeners
 */
CastPlayer.prototype.initializeUI = function () {
  var diUI;
  var tiUI;
  diUI = new Date();
  tiUI = diUI.toLocaleTimeString();
  if (debug_console_log) { console.log(tiUI + '***** Entered CastPlayer.prototype.initializeUI')  ; } ;
  if (debug_console_log) { console.log(tiUI + '***** Entered CastPlayer.prototype.initializeUI')  ; } ;
  if (debug_console_log) { console.log(tiUI + '***** Entered CastPlayer.prototype.initializeUI')  ; } ;
  if (debug_console_log) { console.log(tiUI + '***** Entered CastPlayer.prototype.initializeUI')  ; } ;
  if (debug_console_log) { console.log(tiUI + '***** Entered CastPlayer.prototype.initializeUI')  ; } ;
  // Set initial values for title and subtitle.
  document.getElementById('media_title').innerHTML =
    this.mediaContents[0]['title'];                                // initialize to zero'th element which is first item in array
  document.getElementById('media_subtitle').innerHTML =
    this.mediaContents[this.currentMediaIndex]['subtitle'];
  document.getElementById('seekable_window').addEventListener(
    'click', this.seekMediaListener);
  document.getElementById('progress').addEventListener(
    'click', this.seekMediaListener);
  document.getElementById('progress_indicator').addEventListener(
    'dragend', this.seekMediaListener);
  document.getElementById('skip').addEventListener(
    'click', this.skipAd.bind(this));
  document.getElementById('audio_on').addEventListener(
    'click', this.playerHandler.mute.bind(this.playerHandler));
  document.getElementById('audio_off').addEventListener(
    'click', this.playerHandler.unMute.bind(this.playerHandler));
  document.getElementById('audio_bg').addEventListener(
    'mouseover', this.showVolumeSlider.bind(this));
  document.getElementById('audio_on').addEventListener(
    'mouseover', this.showVolumeSlider.bind(this));
  document.getElementById('audio_bg_level').addEventListener(
    'mouseover', this.showVolumeSlider.bind(this));
  document.getElementById('audio_bg_track').addEventListener(
    'mouseover', this.showVolumeSlider.bind(this));
  document.getElementById('audio_bg_level').addEventListener(
    'click', this.setVolume.bind(this));
  document.getElementById('audio_bg_track').addEventListener(
    'click', this.setVolume.bind(this));
  document.getElementById('audio_bg').addEventListener(
    'mouseout', this.hideVolumeSlider.bind(this));
  document.getElementById('audio_on').addEventListener(
    'mouseout', this.hideVolumeSlider.bind(this));
  document.getElementById('main_video').addEventListener(
    'mouseover', this.showMediaControl.bind(this));
  document.getElementById('main_video').addEventListener(
    'mouseout', this.hideMediaControl.bind(this));
  document.getElementById('media_control').addEventListener(
    'mouseover', this.showMediaControl.bind(this));
  document.getElementById('media_control').addEventListener(
    'mouseout', this.hideMediaControl.bind(this));
  document.getElementById('fullscreen_expand').addEventListener(
    'click', this.requestFullScreen.bind(this));
  document.getElementById('fullscreen_collapse').addEventListener(
    'click', this.cancelFullScreen.bind(this));
  document.addEventListener(
    'fullscreenchange', this.fullscreenChangeHandler.bind(this), false);
  document.addEventListener(
    'webkitfullscreenchange', this.fullscreenChangeHandler.bind(this), false);

  // Enable play/pause buttons
  document.getElementById('play').addEventListener(
    'click', this.playerHandler.play.bind(this.playerHandler));
  document.getElementById('pause').addEventListener(
    'click', this.playerHandler.pause.bind(this.playerHandler));

  document.getElementById('progress_indicator').draggable = true;

  // 2020.01.23 try to Enable FF/RW buttons
  if (debug_console_log) { console.log('Start adding Event Listener and Binding for FF and RW buttons')  ; } ;
  document.getElementById('rw_5').addEventListener('click', this.playerHandler.RW_5.bind(this.playerHandler));
																						 
  document.getElementById('rw_15').addEventListener('click', this.playerHandler.RW_15.bind(this.playerHandler));
  document.getElementById('rw_30').addEventListener('click', this.playerHandler.RW_30.bind(this.playerHandler));
  document.getElementById('rw_60').addEventListener('click', this.playerHandler.RW_60.bind(this.playerHandler));
  document.getElementById('rw_120').addEventListener('click', this.playerHandler.RW_120.bind(this.playerHandler));
  document.getElementById('rw_180').addEventListener('click', this.playerHandler.RW_180.bind(this.playerHandler));
  document.getElementById('ff_5').addEventListener('click', this.playerHandler.FF_5.bind(this.playerHandler));
  document.getElementById('ff_15').addEventListener('click', this.playerHandler.FF_15.bind(this.playerHandler));
  document.getElementById('ff_30').addEventListener('click', this.playerHandler.FF_30.bind(this.playerHandler));
  document.getElementById('ff_60').addEventListener('click', this.playerHandler.FF_60.bind(this.playerHandler));
  document.getElementById('ff_120').addEventListener('click', this.playerHandler.FF_120.bind(this.playerHandler));
  document.getElementById('ff_180').addEventListener('click', this.playerHandler.FF_180.bind(this.playerHandler));
  if (debug_console_log) { console.log('Finished adding Event Listener and Binding for FF and RW buttons')  ; } ;
  
  /*
  // Set up feature radio buttons
  let noneRadio = document.getElementById('none');
  noneRadio.onclick = function () {
    ENABLE_LIVE = false;
    ENABLE_ADS = false;
    if (debug_console_log) { console.log("Features have been removed"); } ;
  }
  let adsRadio = document.getElementById('ads');
  adsRadio.onclick = function () {
    ENABLE_LIVE = false;
    ENABLE_ADS = true;
    if (debug_console_log) { console.log("Ads have been enabled"); } ;
  }
  let liveRadio = document.getElementById('live');
  liveRadio.onclick = function () {
    ENABLE_LIVE = true;
    ENABLE_ADS = false;
    if (debug_console_log) { console.log("Live has been enabled"); } ;
  }

  if (ENABLE_ADS) {
    if (ENABLE_LIVE) {
      if (debug_console_log) { console.log.error('Only one ADS feature can be enabled at a time. Enabling ads.'); } ;
    }
    adsRadio.checked = true;
    if (debug_console_log) { console.log("Ads are enabled"); } ;
  } else if (ENABLE_LIVE) {
    liveRadio.checked = true;
    if (debug_console_log) { console.log("ADS Live is enabled"); } ;
  } else {
    noneRadio.checked = true;
    if (debug_console_log) { console.log("No ADS features are enabled"); } ;
  }
*/
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.initializeUI')  ; } ;
};

/**
 * Add video links div's to UI for media JSON contents
 */
CastPlayer.prototype.addVideoList = function () {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.prototype.addVideoList')  ; } ;
  this.mediaContents = mediaJSON['categories'][0]['videos']; // initialize this.mediaContents object to the first video in  mediaJSON['categories']['Movies]['videos']
  var ni = document.getElementById('video_list');
  var folder_name_tracker = null;
  var details_id = null;
  var details_id_name = null;
  var details_counter = 0;
  var tmpstring = '';
  var filediv = null;
  var filedivIdName = null;
  if (debug_console_log) { console.log("Start creating HTML5-only <details><summary> and <div> elements, of the form:"); } ;
  if (debug_console_log) { console.log("<details id=xxx>") } ;
  if (debug_console_log) { console.log("   <summary>folder name</summary>") } ;
  if (debug_console_log) { console.log("   <other divs, one for each file>") } ;
  if (debug_console_log) { console.log("</details>") } ;
  // ASSUME THAT THE JSON FILE IS PRE_SORTED INTO FOLDERNAME ORDER, to track changes in folder names
  // ASSUME THAT THE JSON FILE IS PRE_SORTED INTO FOLDERNAME ORDER, to track changes in folder names
  // ASSUME THAT THE JSON FILE IS PRE_SORTED INTO FOLDERNAME ORDER, to track changes in folder names
  for (var i = 0; i < this.mediaContents.length; i++) {                 // iterate every JSON entry
    if (folder_name_tracker !== this.mediaContents[i]['folder']) {      // change of folder. depends folder_name_tracker being initialized to null
        folder_name_tracker = this.mediaContents[i]['folder'];          // is a new folder
        details_counter = details_counter + 1                           // increment counter for a new <details> name
        details_id_name = 'details_id_name_' + details_counter          // create a new <details> name to assign to the element's ID
        details_id = document.createElement('details');                 // create a <details> element, recieve back a details_id
        details_id.setAttribute('id', details_id_name);                 // assign a name to the <details> the element's ID
        tmpstring = '<summary style="color:blue;text-align:left;font-size:large;">' + folder_name_tracker + '</summary>';   // create some text for the element's <summary>
        //if (debug_console_log) { console.log(tmpstring); } ;
        details_id.innerHTML = tmpstring;                               // assign text into the <summary> innerHTML
        ni.appendChild(details_id);                                     // append the <details> element to the parent "video_list" div "ni."
        //if (debug_console_log) { console.log("Added new folder <details> child to element <video_list> containing innerHTML " + tmpstring); } ;
    };                                                                  // we are now ready to create and assign assign "file" div's to the prevailing <details> element
    // create a "file entry" div and append it as a child of the prevailing <details> element which was created as a part of folder-change detection
    filediv = document.createElement('div');
    filedivIdName = 'thumb' + i + 'Div';
    filediv.setAttribute('id', filedivIdName);
    filediv.setAttribute('class', 'highlight_on_hover');
    if (debug_console_log) { 
       // tmpstring = '<div class="lineitem">' + '<div class="lineitem_lefttext">' + this.mediaContents[i]['title']  + '</div><div class="lineitem_righttext">' + encodeURI(this.mediaContents[i]['sources'][0]) + '</div></div>' ;
	   tmpstring = '<div class="lineitem">' + '<div class="lineitem_lefttext">' + this.mediaContents[i]['title']  + " [" + this.mediaContents[i]['resolution'] + "][" + this.mediaContents[i]['video_codec']  + "/" +  this.mediaContents[i]['audio_codec'] + "][" + this.mediaContents[i]['duration_str'] + "]" + '</div><div class="lineitem_righttext">' + encodeURI(this.mediaContents[i]['sources'][0]) + '</div></div>' ;
    } else {
	   tmpstring = '<div class="lineitem">' + '<div class="lineitem_lefttext">' + this.mediaContents[i]['title']  + " [" + this.mediaContents[i]['resolution'] + "][" + this.mediaContents[i]['video_codec']  + "/" +  this.mediaContents[i]['audio_codec'] + "][" + this.mediaContents[i]['duration_str'] + "]" + '</div></div>' ;
    }
    filediv.innerHTML = tmpstring;
	//if (debug_console_log) { console.log(tmpstring); } ;
    filediv.addEventListener('click', this.selectMedia.bind(this, i));
    details_id.appendChild(filediv);
   // if (debug_console_log) { console.log("Added new file <div> child to <details> element containing innerHTML " + tmpstring); } ;
  };
  if (debug_console_log) { console.log("Finished creating <details><summary> and <div> element. Folders=" + details_counter + " JSON entries=" + this.mediaContents.length); } ;
  if (debug_console_log) { console.log('<< Exiting CastPlayer.prototype.addVideoList')  ; } ;
};

/**
 * Makes human-readable message from chrome.cast.Error
 * @param {chrome.cast.Error} error
 * @return {string} error message
 */
CastPlayer.getErrorMessage = function (error) {
  if (debug_console_log) { console.log('>>--- Entered CastPlayer.getErrorMessage')  ; } ;
  switch (error.code) {
    case chrome.cast.ErrorCode.API_NOT_INITIALIZED:
      return 'The API is not initialized.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.CANCEL:
      return 'The operation was canceled by the user' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.CHANNEL_ERROR:
      return 'A channel to the receiver is not available.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.EXTENSION_MISSING:
      return 'The Cast extension is not available.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.INVALID_PARAMETER:
      return 'The parameters to the operation were not valid.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.RECEIVER_UNAVAILABLE:
      return 'No receiver was compatible with the session request.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.SESSION_ERROR:
      return 'A session could not be created, or a session was invalid.' +
        (error.description ? ' :' + error.description : '');
    case chrome.cast.ErrorCode.TIMEOUT:
      return 'The operation timed out.' +
        (error.description ? ' :' + error.description : '');
    default:
      return error;
  }
  if (debug_console_log) { console.log('<< Exiting CastPlayer.getErrorMessage')  ; } ;
};

// now some final action code for this .js file.
let castPlayer = new CastPlayer();
window['__onGCastApiAvailable'] = function (isAvailable) {
  if (isAvailable) {
    castPlayer.initializeCastPlayer();
  }
};
