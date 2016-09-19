var fs = require('fs');
//var wget = require('wget-improved');
var wget = require('node-wget');

fs.readFile('links.txt', function(err, data) {
    if(err) 
      throw err;
    var images = data.toString().split("\n");
    downloadImages(images);
});

function downloadImages(images) {
  for (i in images) {
    images[i] = images[i].replace('\r',''); 

    for (j = 1; j<5; j++) {
      var imageId = 'B0' + parseInt(j) + '.jp2';
      
      var source = images[i] + imageId;
      var fileName = getOutputFileName(images[i]) + '-' + imageId;

      if (!fileDoesExist(fileName)) {
        var tempName = fileName; 

        wget({
            url: source,
            dest: createFolder(fileName),
            dry: true
            }, function(err, data) {        // data: { headers:{...}, filepath:'...' } 
                console.log('--- dry run data:');
                console.log(data); // '/tmp/package.json' 
            }
        );

        /*var download = wget.download(source, tempName);

        download.on('error', function(err) {
          console.log('Error on: ' + err);
        });
        download.on('end', function(output) {
          console.log(download.output);
        });*/
      } 
    }
  }
}

function getOutputFileName(url) {
  var parts = url.split('/');
  
  var result = parts[4] + '-' + parts[5] + '-' + parts[6] + '-' + parts[7] + '-' + parts[8]+ '-' + parts[9]+ '-' + parts[10];

  return result;
}

function createFolder(fileName) {
  if (!fileDoesExist(fileName)) {
    fs.mkdirSync(fileName);
  }

  return fileName;
}

function fileDoesExist(fileName) {
  fs.stat(fileName, function(err, fileStat) {
    if (err) {
      if (err.code == 'ENOENT') {
        return false;
      }
    } else {
      return true;
    }
  });
}

/*
fs.stat('Desktop', function(err, fileStat) {
  if (err) {
    if (err.code == 'ENOENT') {
      console.log('Does not exist.');
    }
  } else {
    if (fileStat.isFile()) {
      console.log('File found.');
    } else if (fileStat.isDirectory()) {
      console.log('Directory found.');
    }
  }
});*/


/*
var source = 'http://sentinel-s2-l1c.s3.amazonaws.com/tiles/22/L/DK/2016/7/25/0/B01.jp2';
var outputFile = '22-L-DK-2016-7-25-0-B01.jp2';

var download = wget.download(source, outputFile);

download.on('error', function(err) {
    console.log(err);
});
download.on('start', function(fileSize) {
    console.log(fileSize);
});
download.on('end', function(output) {
    console.log(output);
});
download.on('progress', function(progress) {
    // code to show progress bar
});*/