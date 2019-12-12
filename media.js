'use strict';
/**
* Hardcoded media json objects acceptable to the Google Chromecast Sender (chrome) example
*/
let mediaJSON = {
  'categories': [{
    'name':   'Movies',
    'videos': [
      // ----- START of folder(0) / ... files=13 
      {
        'title'      : '0.source.FF.h264_nvenc',
        'subtitle'   : 'http://10.0.0.6/mp4library/0.source.FF.h264_nvenc.tesst.mp4',
        'sources'    : ['http://10.0.0.6/mp4library/0.source.FF.h264_nvenc.test.mp4',],
        'thumb'      : '',
        'duration'   : 600,
        'resolution' : '1920×1080',
        'folder'     : '/',
      },
      // ----- END   of folder(62) /Series/YesMinister-YesPrimeMinister/ ... files=37 
     ]
  }]
};
export { mediaJSON }
